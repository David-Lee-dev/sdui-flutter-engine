import 'dart:async';

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/widgets.dart' hide Action;

import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import '../../environment/_base.dart';
import '../../environment/scope/commit_scheduler.dart';
import '../../environment/scope/json_value.dart';
import '../../environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import '../../engine_errors.dart';
import '../../engine_host.dart';
import '../../log/engine_log.dart';
import '../../telemetry/telemetry.dart';
import 'action_host.dart';
import 'lifecycle_runner.dart';
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
    this.autoSkeleton = false,
  }) : placeholder = false;

  Scope.ofState(
    Map<String, Object?> state, {
    super.key,
    required this.child,
    this.placeholder = false,
  }) : config = ScopeConfig(state: state),
       actions = const {},
       lifecycle = const [],
       skeleton = null,
       autoSkeleton = false;

  final ScopeConfig config;

  final Map<String, Action> actions;

  final List<LifecycleHook> lifecycle;

  /// Placeholder displayed while this scope's mount actions are completing.
  final Widget? skeleton;

  /// Whether [child] draws its own skeleton: each node reading a key the
  /// mount hooks write shows a bone until that key is first written.
  final bool autoSkeleton;

  /// Whether this is a stand-in loop row drawn while the loop's source is
  /// pending: every key reads as pending and nested scopes never start.
  final bool placeholder;

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
  late final LifecycleRunner _lifecycle;

  late Map<String, Object?> _acceptedSeed;

  bool _observerRegistered = false;

  /// How long an automatic skeleton waits on mount hooks before revealing.
  static const _watchdogDelay = Duration(seconds: 15);

  /// The keys each mount hook writes, on the scope that owns them, until the
  /// hook settles.
  final Map<String, ({ScopeEnvironment owner, Set<String> keys})> _awaited = {};

  Timer? _watchdog;

  bool _hooksPrepared = false;

  /// Whether this scope sits in a placeholder loop row and never runs hooks.
  bool _inert = false;

  /// The loading flags of ancestor automatic skeletons this scope's
  /// lifecycle waits on, or `null` once it may start.
  List<ValueNotifier<bool>>? _waitingOn;

  bool _visible = true;

  bool get _skeletal => widget.skeleton != null || widget.autoSkeleton;

  @override
  void initState() {
    super.initState();
    final seed = widget.config.state;
    _acceptedSeed = JsonValue.normalizeObject(seed);
    _env = ScopeEnvironment(
      seed,
      scheduler: FlutterCommitScheduler(),
      placeholder: widget.placeholder,
    );
    _host = ActionHost(actions: widget.actions, env: _env);
    _loading = ValueNotifier(
      _skeletal &&
          widget.lifecycle.any(
            (hook) => hook.trigger == LifecycleTrigger.mount,
          ),
    );
    _lifecycle =
        LifecycleRunner(
            host: _host,
            isMounted: () => mounted,
            onMountSettled: _mountSettled,
          )
          ..hooks = widget.lifecycle
          ..deferMountForSkeleton = _skeletal
          ..onMountActionSettled = _mountActionSettled;
    if (widget.lifecycle.isNotEmpty) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _env.parent = _ScopeLayer.of(context);
    final telemetry = TelemetryScope.maybeOf(context);
    _host.wire(
      parent: _ActionLayer.of(context),
      host: EngineHostScope.of(context),
      screenId: telemetry?.screenId,
      screenViewId: telemetry?.screenViewId,
    );

    if (widget.lifecycle.isEmpty) return;
    _visible = _isVisible();
    if (!_hooksPrepared) {
      _hooksPrepared = true;
      _prepareHooks();
    }
    if (_inert || _waitingOn != null) return;
    _startLifecycle();
  }

  /// Forwards visibility to the lifecycle; the first call starts it, and an
  /// automatic skeleton arms its watchdog then, not while it still waits.
  void _startLifecycle() {
    if (widget.autoSkeleton && _loading.value && _watchdog == null) {
      _watchdog = Timer(_watchdogDelay, _watchdogFired);
    }
    _lifecycle.visibilityChanged(_visible);
  }

  /// Runs once the scope is wired, before its lifecycle first starts.
  ///
  /// A scope inside a placeholder row never runs hooks. An automatic skeleton
  /// marks what its mount hooks write as pending on the owning scopes, and a
  /// scope under a still-loading automatic skeleton starts after it, keeping
  /// the parent-then-child mount order of a hand-drawn skeleton.
  void _prepareHooks() {
    final ancestors = <ScopeState>[
      for (
        var scope = context.findAncestorStateOfType<ScopeState>();
        scope != null;
        scope = scope.context.findAncestorStateOfType<ScopeState>()
      )
        scope,
    ];
    if (ancestors.any((scope) => scope.widget.placeholder)) {
      _inert = true;
      _lifecycle.hooks = const [];
      _loading.value = false;
      return;
    }
    if (widget.autoSkeleton) _pendMountWrites();
    final loading = [
      for (final scope in ancestors)
        if (scope.widget.autoSkeleton && scope._loading.value) scope._loading,
    ];
    if (loading.isEmpty) return;
    _waitingOn = loading;
    for (final flag in loading) {
      flag.addListener(_ancestorLoadingChanged);
    }
  }

  void _pendMountWrites() {
    for (final hook in widget.lifecycle) {
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
    if (mounted) _startLifecycle();
  }

  void _stopWaiting() {
    for (final flag in _waitingOn ?? const <ValueNotifier<bool>>[]) {
      flag.removeListener(_ancestorLoadingChanged);
    }
    _waitingOn = null;
  }

  void _mountActionSettled(String action) {
    final awaited = _awaited.remove(action);
    awaited?.owner.settle(awaited.keys);
  }

  void _mountSettled() {
    _settleAwaited();
    _loading.value = false;
  }

  /// Releases what the stalled mount hooks still hold: their keys, and the
  /// nested scopes waiting to start.
  void _watchdogFired() {
    if (!mounted || !_loading.value) return;
    EngineLog.warn(
      'auto skeleton: mount hooks did not settle within '
      '${_watchdogDelay.inSeconds}s — revealing '
      '${_awaited.values.expand((entry) => entry.keys).join(', ')} and '
      'starting nested scopes.',
      tag: 'scope',
    );
    _mountSettled();
  }

  void _settleAwaited() {
    _watchdog?.cancel();
    for (final entry in _awaited.values) {
      entry.owner.settle(entry.keys);
    }
    _awaited.clear();
  }

  bool _isVisible() {
    // ModalRoute also catches transparent routes; TickerMode catches nested
    // Navigators hidden behind the root overlay and inactive go_router
    // branches.
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return isCurrentRoute && TickerMode.of(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _lifecycle.appLifecycleChanged(state);

  @override
  void didUpdateWidget(Scope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _host.actions = widget.actions;
    if (!identical(widget.lifecycle, oldWidget.lifecycle) && !_inert) {
      _lifecycle
        ..hooks = widget.lifecycle
        ..deferMountForSkeleton = _skeletal;
      if (widget.lifecycle.isNotEmpty && !_observerRegistered) {
        WidgetsBinding.instance.addObserver(this);
        _observerRegistered = true;
      } else if (widget.lifecycle.isEmpty && _observerRegistered) {
        WidgetsBinding.instance.removeObserver(this);
        _observerRegistered = false;
      }
      if (_waitingOn == null) _lifecycle.reconcile();
    }
    final newSeed = widget.config.state;
    if (JsonValue.structurallyEqual(_acceptedSeed, newSeed)) return;
    final declared = _env.declaredKeys.toSet();
    if (!setEquals(newSeed.keys.toSet(), declared)) {
      EngineErrors.report(
        SduiError(
          scope: SduiErrorScope.scopeReseed,
          error: StateError(
            'Scope state keyset changed on reseed '
            '(declared: $declared, incoming: ${newSeed.keys.toSet()}). '
            'Schema changes need a remount — key the Scope/template by revision. '
            'Keeping the old state.',
          ),
          screenId: _host.screenId,
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
    _lifecycle.dispose();
    // Keys pended on an ancestor outlive this scope; release them so they
    // never stay pending.
    _settleAwaited();
    _stopWaiting();
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
    final child = widget.skeleton != null
        ? SkeletonScope(
            loading: _loading,
            skeleton: widget.skeleton!,
            child: widget.child,
          )
        : widget.autoSkeleton
        ? SkeletonClock(child: widget.child)
        : widget.child;
    return _ScopeLayer(
      env: _env,
      child: _ActionLayer(host: _host, child: child),
    );
  }
}
