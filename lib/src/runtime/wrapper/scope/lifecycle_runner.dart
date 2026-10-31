import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import '../../log/engine_log.dart';
import '../../telemetry/telemetry.dart';
import '../../widget/contract/action_sink.dart';
import 'action_host.dart';

/// Runs a scope's lifecycle hooks — the mount/render/interval/remount/dispose
/// state machine, extracted from the scope widget so it has one job and can
/// be exercised without mounting a widget tree.
///
/// The owning [State] stays responsible for what only a widget can know:
/// visibility (context) and app-lifecycle observation (a
/// [WidgetsBindingObserver] mixin) — both forward here.
final class LifecycleRunner {
  LifecycleRunner({
    required ActionHost host,
    required bool Function() isMounted,
    required void Function() onMountSettled,
  }) : _host = host,
       _isMounted = isMounted,
       _onMountSettled = onMountSettled;

  final ActionHost _host;

  /// The owning widget's `mounted` — timers must not fire into a dead scope.
  final bool Function() _isMounted;

  /// Called once every mount-triggered flow settles (skeleton -> content).
  final void Function() _onMountSettled;

  /// The current hook table — kept in sync by the owner (initState and
  /// widget updates), so `dispose` hooks fire even for a scope that was
  /// never visible.
  List<LifecycleHook> hooks = const [];

  /// Whether mount flows await behind a skeleton (deferred awaitable path).
  bool deferMountForSkeleton = false;

  /// Whether the owner's presence slot is exiting: no hook fires and
  /// visibility changes are ignored, so leaving and coming back fires no
  /// `remount`. Disposal still fires `dispose` hooks.
  bool suspended = false;

  final List<Timer> _timers = [];

  /// Settles the pending mount load; `null` when none is pending.
  void Function()? _settleMount;

  /// Bounds the pending mount load; outlives [reconcile].
  Timer? _watchdog;
  bool _started = false;
  bool _wasObscured = false;
  bool _inBackground = false;

  /// Reacts to the owner's visibility: the first sighting starts the hooks;
  /// later obscured -> visible transitions fire `remount`.
  void visibilityChanged(bool visible) {
    if (hooks.isEmpty || suspended) return;
    if (!_started) {
      _started = true;
      _wasObscured = !visible;
      _start();
      return;
    }
    if (!visible) {
      _wasObscured = true;
    } else if (_wasObscured) {
      _wasObscured = false;
      fireByTrigger(LifecycleTrigger.remount);
    }
  }

  /// Forwarded from the owner's [WidgetsBindingObserver]: returning from
  /// background fires `remount`.
  void appLifecycleChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _inBackground = true;
    } else if (state == AppLifecycleState.resumed && _inBackground) {
      _inBackground = false;
      fireByTrigger(LifecycleTrigger.remount);
    }
  }

  /// Replaces the hook table (the scope's directive changed): cancels every
  /// pending timer and restarts from scratch when the new table is non-empty.
  /// A pending mount load that the new table no longer awaits settles.
  void reconcile() {
    _cancelTimers();
    _started = false;
    var awaitsMount = false;
    if (hooks.isNotEmpty && !suspended) {
      _started = true;
      awaitsMount = _start();
    }
    if (!awaitsMount) _settleMount?.call();
  }

  /// Fires `dispose` hooks (the host must still be live) and stops timers.
  void dispose() {
    suspended = false;
    fireByTrigger(LifecycleTrigger.dispose);
    _cancelTimers();
    _watchdog?.cancel();
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Starts the hooks; returns whether a mount load awaits them.
  bool _start() {
    final mountFutures = <Future<void>>[];
    for (final hook in hooks) {
      if (kDebugMode &&
          (hook.trigger == LifecycleTrigger.mount ||
              hook.trigger == LifecycleTrigger.render)) {
        EngineLog.scope.lifecycle(
          hook.trigger.name,
          hook.action,
          delay: hook.delay > Duration.zero ? hook.delay : null,
        );
      }
      switch (hook.trigger) {
        case LifecycleTrigger.mount:
          if (!deferMountForSkeleton) {
            _fire(hook);
          } else if (hook.delay > Duration.zero) {
            // A delayed mount fire uses a cancellable timer (tracked for
            // dispose) rather than Future.delayed, whose timer cannot be
            // cancelled and would outlive a scope torn down before the delay
            // elapses.
            final completer = Completer<void>();
            mountFutures.add(completer.future);
            _timers.add(
              Timer(hook.delay, () {
                if (!_isMounted() || suspended) {
                  completer.complete();
                  return;
                }
                _host
                    .handleAwaitable(
                      hook.action,
                      invocation: _invocation(hook.trigger),
                    )
                    .whenComplete(completer.complete);
              }),
            );
          } else {
            mountFutures.add(
              _isMounted()
                  ? _host.handleAwaitable(
                      hook.action,
                      invocation: _invocation(hook.trigger),
                    )
                  : Future.value(),
            );
          }
        case LifecycleTrigger.render:
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (_isMounted()) _fire(hook);
          });
        case LifecycleTrigger.interval:
          _startInterval(hook);
        case LifecycleTrigger.remount:
        case LifecycleTrigger.dispose:
          break;
      }
    }
    if (mountFutures.isEmpty) return false;
    final settle = _settleMount ?? _awaitMount();
    Future.wait(mountFutures).then((_) => settle());
    return true;
  }

  /// Opens a pending mount load. A hung mount flow must not keep the skeleton
  /// forever: the watchdog settles it, and a late response still updates the
  /// content in place.
  void Function() _awaitMount() {
    late final void Function() settle;
    settle = () {
      if (!identical(_settleMount, settle)) return;
      _settleMount = null;
      _watchdog?.cancel();
      _watchdog = null;
      if (_isMounted()) _onMountSettled();
    };
    _watchdog = Timer(mountWatchdog, () {
      if (!_isMounted()) return;
      EngineLog.warn(
        'mount hooks did not settle within '
        '${mountWatchdog.inSeconds} s; showing the content',
        tag: 'scope',
      );
      settle();
    });
    return _settleMount = settle;
  }

  /// How long mount flows may hold the skeleton before it gives way.
  static const mountWatchdog = Duration(seconds: 8);

  void _fire(LifecycleHook hook) {
    if (suspended) return;
    if (hook.delay > Duration.zero) {
      _timers.add(
        Timer(hook.delay, () {
          if (_isMounted() && !suspended) {
            _host.handle(hook.action, invocation: _invocation(hook.trigger));
          }
        }),
      );
    } else {
      _host.handle(hook.action, invocation: _invocation(hook.trigger));
    }
  }

  void _startInterval(LifecycleHook hook) {
    final every = hook.every!;
    // Interval ticks are high-frequency and low-signal, so each firing runs
    // with engine logging suppressed — otherwise every tick floods the
    // console with its action/state lines. Setup itself is not logged (see
    // [_start]).
    _timers.add(
      Timer(hook.delay, () {
        if (!_isMounted()) return;
        if (!suspended) {
          EngineLog.runSilently(
            () => _host.handle(
              hook.action,
              invocation: _invocation(LifecycleTrigger.interval),
            ),
          );
        }
        _timers.add(
          Timer.periodic(every, (_) {
            if (_isMounted() && !suspended) {
              EngineLog.runSilently(
                () => _host.handle(
                  hook.action,
                  invocation: _invocation(LifecycleTrigger.interval),
                ),
              );
            }
          }),
        );
      }),
    );
  }

  /// Fires every hook of [trigger] (remount and dispose have no scheduling
  /// of their own beyond each hook's `delay`).
  void fireByTrigger(LifecycleTrigger trigger) {
    for (final hook in hooks) {
      if (hook.trigger == trigger) _fire(hook);
    }
  }

  ActionInvocation _invocation(LifecycleTrigger trigger) => ActionInvocation(
    invocationId: Telemetry.newId(),
    origin: switch (trigger) {
      LifecycleTrigger.mount => ActionOrigin.mount,
      LifecycleTrigger.render => ActionOrigin.render,
      LifecycleTrigger.remount => ActionOrigin.remount,
      LifecycleTrigger.interval => ActionOrigin.interval,
      LifecycleTrigger.dispose => ActionOrigin.dispose,
    },
  );
}
