
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
  late final LifecycleRunner _lifecycle;

  late Map<String, Object?> _acceptedSeed;

  bool _observerRegistered = false;

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
    _lifecycle = LifecycleRunner(
      host: _host,
      isMounted: () => mounted,
      onMountSettled: () => _loading.value = false,
    )
      ..hooks = widget.lifecycle
      ..deferMountForSkeleton = widget.skeleton != null;
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
    _lifecycle.visibilityChanged(_isVisible());
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
    if (!identical(widget.lifecycle, oldWidget.lifecycle)) {
      _lifecycle
        ..hooks = widget.lifecycle
        ..deferMountForSkeleton = widget.skeleton != null;
      if (widget.lifecycle.isNotEmpty && !_observerRegistered) {
        WidgetsBinding.instance.addObserver(this);
        _observerRegistered = true;
      } else if (widget.lifecycle.isEmpty && _observerRegistered) {
        WidgetsBinding.instance.removeObserver(this);
        _observerRegistered = false;
      }
      _lifecycle.reconcile();
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
