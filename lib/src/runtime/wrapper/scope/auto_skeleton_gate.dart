import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import '../../environment/scope/scope_environment.dart';
import '../../log/engine_log.dart';
import 'action_host.dart';

/// One scope's part in automatic skeletons (`_skeleton: auto`).
///
/// An automatic skeleton marks what its mount hooks write as pending on the
/// owning scopes until each hook settles, or its watchdog releases them. A
/// scope under a still-loading automatic skeleton holds its lifecycle until
/// that skeleton settles, keeping the parent-then-child mount order of a
/// hand-drawn skeleton. A scope inside a placeholder loop row never runs
/// hooks.
final class AutoSkeletonGate {
  AutoSkeletonGate({
    required this.placeholder,
    required bool Function() auto,
    required this.loading,
    required ActionHost host,
    required Iterable<AutoSkeletonGate> Function() ancestors,
    required VoidCallback onReady,
  }) : _auto = auto,
       _host = host,
       _ancestors = ancestors,
       _onReady = onReady {
    if (placeholder) _placeholders++;
    if (loading.value) {
      _loadingScopes++;
      loading.addListener(_loadingChanged);
    }
  }

  /// Whether the scope is a stand-in loop row.
  final bool placeholder;

  /// The scope's loading flag: its mount hooks have not all settled.
  final ValueNotifier<bool> loading;

  /// Whether the scope currently draws an automatic skeleton.
  final bool Function() _auto;

  final ActionHost _host;

  /// The gates of the scopes above, nearest first, walked lazily.
  final Iterable<AutoSkeletonGate> Function() _ancestors;

  /// Starts the scope's lifecycle once the skeletons it waits on settle.
  final VoidCallback _onReady;

  /// How long an automatic skeleton waits on mount hooks before revealing.
  static const _watchdogDelay = Duration(seconds: 15);

  /// How many placeholder-row scopes are mounted, so scopes skip the
  /// ancestor walk for [inert] while there are none. Process-wide; it
  /// returns to zero as those scopes dispose.
  static int _placeholders = 0;

  /// How many scopes are still loading, so scopes skip the ancestor walk
  /// for a loading automatic skeleton while no other one is. Process-wide;
  /// it returns to zero as scopes settle or dispose.
  static int _loadingScopes = 0;

  /// The keys each mount hook writes, on the scope that owns them, until the
  /// hook settles.
  final Map<String, ({ScopeEnvironment owner, Set<String> keys})> _awaited = {};

  Timer? _watchdog;

  bool _placed = false;

  bool _inert = false;

  /// The loading flags of ancestor automatic skeletons the lifecycle waits
  /// on, or `null` once it may start.
  List<ValueNotifier<bool>>? _waitingOn;

  /// Whether the scope sits in a placeholder loop row and never runs hooks,
  /// even ones a later template update gives it.
  bool get inert => _inert;

  /// Whether the lifecycle waits on a loading automatic skeleton above.
  bool get waiting => _waitingOn != null;

  /// Whether the lifecycle may not start yet (or ever).
  bool get holds => _inert || waiting;

  void _loadingChanged() {
    if (!loading.value) _uncount();
  }

  /// [loading] goes only from true to false, so a scope is counted in
  /// [_loadingScopes] exactly while it is loading.
  void _uncount() {
    _loadingScopes--;
    loading.removeListener(_loadingChanged);
  }

  /// Settles where the scope sits, once it is first wired.
  void place() {
    if (_placed) return;
    _placed = true;
    _inert = _placeholders > 0 && _ancestors().any((gate) => gate.placeholder);
  }

  /// Runs once, before the lifecycle first starts: an inert scope stops
  /// loading, an automatic skeleton pends what [hooks] write on mount, and
  /// the scope waits on the loading automatic skeletons above it.
  void prepare(List<LifecycleHook> hooks) {
    if (_inert) {
      loading.value = false;
      return;
    }
    if (_auto()) _pendMountWrites(hooks);
    _waitForAncestors();
  }

  /// After a reparent (a `GlobalKey` move), waits on the loading automatic
  /// skeletons above the new place, if any.
  void moved() {
    if (!waiting) return;
    _stopWaiting();
    _waitForAncestors();
  }

  /// Arms an automatic skeleton's watchdog as its lifecycle starts, not
  /// while it still waits.
  void armWatchdog() {
    if (_auto() && loading.value && _watchdog == null) {
      _watchdog = Timer(_watchdogDelay, _watchdogFired);
    }
  }

  void _waitForAncestors() {
    // No other scope is loading, so none above can be.
    if (_loadingScopes == (loading.value ? 1 : 0)) return;
    final flags = [
      for (final gate in _ancestors())
        if (gate._auto() && gate.loading.value) gate.loading,
    ];
    if (flags.isEmpty) return;
    _waitingOn = flags;
    for (final flag in flags) {
      flag.addListener(_ancestorLoadingChanged);
    }
  }

  void _pendMountWrites(List<LifecycleHook> hooks) {
    for (final hook in hooks) {
      if (hook.trigger != LifecycleTrigger.mount) continue;
      final resolved = _host.resolve(hook.action);
      if (resolved == null || resolved.action.writes.isEmpty) continue;
      resolved.owner.pend(resolved.action.writes);
      _awaited[hook.action] = (
        owner: resolved.owner,
        keys: resolved.action.writes,
      );
    }
  }

  void _ancestorLoadingChanged() {
    final waiting = _waitingOn;
    if (waiting == null || waiting.any((flag) => flag.value)) return;
    _stopWaiting();
    _onReady();
  }

  void _stopWaiting() {
    for (final flag in _waitingOn ?? const <ValueNotifier<bool>>[]) {
      flag.removeListener(_ancestorLoadingChanged);
    }
    _waitingOn = null;
  }

  /// Releases what one mount hook [action] still holds as it settles.
  void mountActionSettled(String action) {
    final awaited = _awaited.remove(action);
    awaited?.owner.settle(awaited.keys);
  }

  /// Releases everything once all mount hooks have settled.
  void mountSettled() {
    _settleAwaited();
    loading.value = false;
  }

  /// Releases what the stalled mount hooks still hold: their keys, and the
  /// nested scopes waiting to start.
  void _watchdogFired() {
    if (!loading.value) return;
    EngineLog.warn(
      'auto skeleton: mount hooks did not settle within '
      '${_watchdogDelay.inSeconds}s — revealing '
      '${_awaited.values.expand((entry) => entry.keys).join(', ')} and '
      'starting nested scopes.',
      tag: 'scope',
    );
    mountSettled();
  }

  void _settleAwaited() {
    _watchdog?.cancel();
    for (final entry in _awaited.values) {
      entry.owner.settle(entry.keys);
    }
    _awaited.clear();
  }

  /// Keys pended on an ancestor outlive the scope, so they are released
  /// here and never stay pending.
  void dispose() {
    _settleAwaited();
    _stopWaiting();
    if (placeholder) _placeholders--;
    if (loading.value) _uncount();
  }
}
