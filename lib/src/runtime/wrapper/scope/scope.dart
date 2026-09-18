import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, setEquals;
import 'package:flutter/widgets.dart' hide Action;

import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import '../../environment/_base.dart';
import '../../environment/scope/commit_scheduler.dart';
import '../../environment/scope/json_value.dart';
import '../../environment/scope/scope_environment.dart';
import '../../engine_host.dart';
import '../../log/engine_log.dart';
import '../../telemetry/telemetry.dart';
import '../../widget/contract/action_sink.dart';
import 'action_host.dart';
import 'skeleton_scope.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';

class _ScopeLayer extends InheritedWidget {
  const _ScopeLayer({required this.env, required super.child});

  final Environment env;

  static Environment? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScopeLayer>()?.env;

  @override
  bool updateShouldNotify(_ScopeLayer oldWidget) => env != oldWidget.env;
}

class _ActionLayer extends InheritedWidget {
  const _ActionLayer({required this.host, required super.child});

  final ActionHost host;

  static ActionHost? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ActionLayer>()?.host;

  @override
  bool updateShouldNotify(_ActionLayer oldWidget) => host != oldWidget.host;
}

/// Introduces a state and action boundary into the widget tree.
class Scope extends StatefulWidget {
  const Scope({
    super.key,
    required this.config,
    required this.child,
    this.actions = const {},
    this.lifecycle = const [],
    this.skeleton,
  });

  Scope.ofState(Map<String, Object?> state, {super.key, required this.child})
    : config = ScopeConfig(state: state),
      actions = const {},
      lifecycle = const [],
      skeleton = null;

  final ScopeConfig config;

  final Map<String, Action> actions;

  final List<LifecycleHook> lifecycle;

  /// Placeholder displayed while this scope's mount actions are completing.
  final Widget? skeleton;

  final Widget child;

  /// Returns the nearest engine environment visible from [context].
  static Environment? envOf(BuildContext context) => _ScopeLayer.of(context);

  /// Inserts [env] without creating another state or action owner.
  static Widget provideEnv({required Environment env, required Widget child}) =>
      _ScopeLayer(env: env, child: child);

  /// Returns the nearest action host visible from [context].
  static ActionHost? actionHost(BuildContext context) =>
      _ActionLayer.of(context);

  @override
  ScopeState createState() => ScopeState();
}

/// Coordinates a [Scope] environment, action host, and lifecycle hooks.
class ScopeState extends State<Scope> with WidgetsBindingObserver {
  late final ScopeEnvironment _env;
  late final ActionHost _host;
  late final ValueNotifier<bool> _loading;

  late Map<String, Object?> _acceptedSeed;

  final List<Timer> _lifecycleTimers = [];

  bool _lifecycleStarted = false;

  bool _observerRegistered = false;

  bool _wasObscured = false;

  bool _inBackground = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.config.state;
    _acceptedSeed = JsonValue.normalizeObject(seed);
    _env = ScopeEnvironment(seed, scheduler: FlutterCommitScheduler());
    _host = ActionHost(actions: widget.actions, env: _env);
    _loading = ValueNotifier(
      widget.skeleton != null &&
          widget.lifecycle.any(
            (hook) => hook.trigger == LifecycleTrigger.mount,
          ),
    );
    if (widget.lifecycle.isNotEmpty) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _env.parent = _ScopeLayer.of(context);
    _host.parent = _ActionLayer.of(context);
    _host.host = EngineHostScope.of(context);
    final telemetry = TelemetryScope.maybeOf(context);
    _host
      ..screenId = telemetry?.screenId
      ..screenViewId = telemetry?.screenViewId;

    if (widget.lifecycle.isEmpty) return;
    final visible = _isVisible();
    if (!_lifecycleStarted) {
      _lifecycleStarted = true;
      _wasObscured = !visible;
      _startLifecycle();
      return;
    }
    if (!visible) {
      _wasObscured = true;
    } else if (_wasObscured) {
      _wasObscured = false;
      _fireByTrigger(LifecycleTrigger.remount);
    }
  }

  void _startLifecycle() {
    final mountFutures = <Future<void>>[];
    for (final hook in widget.lifecycle) {
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
          if (widget.skeleton == null) {
            _fire(hook);
          } else if (hook.delay > Duration.zero) {
            // A delayed mount fire uses a cancellable timer (tracked for dispose)
            // rather than Future.delayed, whose timer cannot be cancelled and
            // would outlive a scope torn down before the delay elapses.
            final completer = Completer<void>();
            mountFutures.add(completer.future);
            _lifecycleTimers.add(
              Timer(hook.delay, () {
                if (!mounted) {
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
              mounted
                  ? _host.handleAwaitable(
                      hook.action,
                      invocation: _invocation(hook.trigger),
                    )
                  : Future.value(),
            );
          }
        case LifecycleTrigger.render:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fire(hook);
          });
        case LifecycleTrigger.interval:
          _startInterval(hook);
        case LifecycleTrigger.remount:
        case LifecycleTrigger.dispose:
          break;
      }
    }
    if (mountFutures.isNotEmpty) {
      Future.wait(mountFutures).then((_) {
        if (mounted) _loading.value = false;
      });
    }
  }

  void _reconcileLifecycle() {
    for (final timer in _lifecycleTimers) {
      timer.cancel();
    }
    _lifecycleTimers.clear();
    _lifecycleStarted = false;
    if (widget.lifecycle.isNotEmpty && !_observerRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    } else if (widget.lifecycle.isEmpty && _observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _observerRegistered = false;
    }
    if (widget.lifecycle.isNotEmpty) {
      _lifecycleStarted = true;
      _startLifecycle();
    }
  }

  void _fire(LifecycleHook hook) {
    if (hook.delay > Duration.zero) {
      _lifecycleTimers.add(
        Timer(hook.delay, () {
          if (mounted) {
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
    // Interval ticks are high-frequency and low-signal, so each firing runs with
    // engine logging suppressed — otherwise every tick floods the console with
    // its action/state lines. Setup itself is not logged (see _startLifecycle).
    _lifecycleTimers.add(
      Timer(hook.delay, () {
        if (!mounted) return;
        EngineLog.runSilently(
          () => _host.handle(
            hook.action,
            invocation: _invocation(LifecycleTrigger.interval),
          ),
        );
        _lifecycleTimers.add(
          Timer.periodic(every, (_) {
            if (mounted) {
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

  void _fireByTrigger(LifecycleTrigger trigger) {
    for (final hook in widget.lifecycle) {
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

  bool _isVisible() {
    // ModalRoute는 transparent route도 감지하고, TickerMode는 root overlay에
    // 가려진 nested Navigator와 inactive go_router branch를 감지한다.
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return isCurrentRoute && TickerMode.of(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _inBackground = true;
    } else if (state == AppLifecycleState.resumed && _inBackground) {
      _inBackground = false;
      _fireByTrigger(LifecycleTrigger.remount);
    }
  }

  @override
  void didUpdateWidget(Scope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _host.actions = widget.actions;
    if (!identical(widget.lifecycle, oldWidget.lifecycle)) {
      _reconcileLifecycle();
    }
    final newSeed = widget.config.state;
    if (JsonValue.structurallyEqual(_acceptedSeed, newSeed)) return;
    final declared = _env.declaredKeys.toSet();
    if (!setEquals(newSeed.keys.toSet(), declared)) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError(
            'Scope state keyset changed on reseed '
            '(declared: $declared, incoming: ${newSeed.keys.toSet()}). '
            'Schema changes need a remount — key the Scope/template by revision. '
            'Keeping the old state.',
          ),
          library: 'engine',
          context: ErrorDescription('reseeding a Scope'),
        ),
      );
      return;
    }
    _acceptedSeed = JsonValue.normalizeObject(newSeed);
    _env.syncState(newSeed);
  }

  @override
  void dispose() {
    // Dispose hooks need a live host; invalidation follows their dispatch.
    _fireByTrigger(LifecycleTrigger.dispose);
    for (final timer in _lifecycleTimers) {
      timer.cancel();
    }
    if (_observerRegistered) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _host.dispose();
    _env.dispose();
    _loading.dispose();
    super.dispose();
  }

  void set(String key, Object? value) => _env.set(key, value);

  @override
  Widget build(BuildContext context) {
    final child = widget.skeleton == null
        ? widget.child
        : SkeletonScope(
            loading: _loading,
            skeleton: widget.skeleton!,
            child: widget.child,
          );
    return _ScopeLayer(
      env: _env,
      child: _ActionLayer(host: _host, child: child),
    );
  }
}
