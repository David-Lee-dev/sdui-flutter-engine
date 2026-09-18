import 'package:flutter/foundation.dart' show kDebugMode, setEquals;
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';

import 'runtime/driver/driver_registry.dart';
import 'runtime/engine_host.dart';
import 'runtime/engine_registries.dart';
import 'runtime/interpreter/building/node_builder.dart';
import 'runtime/log/engine_log.dart';
import 'runtime/telemetry/telemetry.dart';
import 'runtime/util/engine_metrics.dart';
import 'runtime/widget/factory.dart';
import 'runtime/wrapper/scope/scope.dart';

/// Mounts a server template as a reactive widget tree.
///
/// Parsing, compilation, and validation are memoized because they depend only
/// on [template] and the declared [rootData] keys. Widget assembly still runs on
/// each build for normal reconciliation. Runtime services and registries remain
/// stable and isolated for the lifetime of this mount.
final class EngineRunner extends StatefulWidget {
  const EngineRunner({
    super.key,
    required this.template,
    this.screenId,
    this.screenViewId,
    this.rootData = const {},
    this.modalTemplates = const {},
    this.navigate,
    this.toast,
    this.host,
    this.errorBuilder,
    this.resolveExitReason,
    this.surfaceType,
    this.modalId,
  });

  /// The structural template received from the server.
  final Map<String, Object?> template;

  /// The screen this mount belongs to, for dwell/scroll telemetry.
  ///
  /// `null` for a mount that is not an observable surface at all (a bare test
  /// mount). A modal body carries the *opening screen's* id together with
  /// [surfaceType] and [modalId], so its events stay attributable to the
  /// screen the user is actually on (TELEMETRY.md §2, "모달" row).
  /// When `null`, this mount emits no telemetry at all.
  final String? screenId;

  /// The current visit's identifier (TELEMETRY.md §2), fresh per activation.
  ///
  /// For a screen it is the `screen_view_id` issued by `ScreenPage`; for a
  /// modal body it is that modal's own `surface_view_id`, issued by
  /// `ModalFrame`. Either way this mount only carries it.
  final String? screenViewId;

  /// The application-provided seed for the root binding scope.
  final Map<String, Object?> rootData;

  /// Maps modal identifiers to raw templates available from this screen.
  final Map<String, Object?> modalTemplates;

  /// The application-provided navigation handle, if available.
  final NavigateHandle? navigate;

  /// The application-provided toast handle, if available.
  final ToastHandle? toast;

  /// The opening mount's host when this root renders a modal body.
  ///
  /// Modal overlays live outside the opening subtree and cannot inherit its
  /// [EngineHostScope]. Explicit propagation keeps nested close operations on
  /// the correct modal stack. A `null` value creates a new top-level host.
  final EngineHost? host;

  /// Builds the fallback UI for a mount-level compile/validate failure — the
  /// "engine cannot come up at all" case (no directive exists to render),
  /// reachable in production through version skew when the server ships a
  /// template an older client's engine cannot compile.
  ///
  /// Defaults to a bare-text fallback so the engine still renders standalone.
  /// `lib/core` must not depend on `lib/app`, so the app supplies its real
  /// error screen through this seam instead of a direct reference.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Reports why this visit is ending, when the mount's owner knows better
  /// than this widget can see (TELEMETRY.md §7 `exit_reason`).
  ///
  /// Local visibility only ever explains "covered" and "tab switched away".
  /// Whether the user went *back* or *onward*, and whether an external deep
  /// link pushed them out, lives in the router — which the engine must not
  /// know about. So the owner supplies it: `ScreenPage` resolves it from the
  /// app's navigation flow, `ModalFrame` from how the modal was closed.
  /// Returning `null` means "cannot tell", and no `exit_reason` is emitted —
  /// a wrong one silently corrupts drop-off analysis.
  final String? Function()? resolveExitReason;

  /// The kind of surface this mount is, when it is not a plain screen.
  ///
  /// Only `'modal'` today. Absent for screens, which are the implicit default.
  final String? surfaceType;

  /// The template-facing modal identifier, when this mount is a modal body.
  final String? modalId;

  @override
  State<EngineRunner> createState() => _EngineRunnerState();
}

class _EngineRunnerState extends State<EngineRunner>
    with WidgetsBindingObserver {
  /// Registries retained for the full mount lifetime.
  final EngineRegistries _registries = EngineRegistries();

  /// Cached compilation output, refreshed only for structural input changes.
  late Directive _directive;

  /// Runtime services retained so the modal stack remains stable across builds.
  EngineHost? _engineHost;

  /// The current compilation failure, cleared after successful recompilation.
  Object? _compileError;

  // --- Dwell + scroll telemetry (TELEMETRY.md §3 item 6, §7 screen_leave) --
  //
  // Only active when widget.screenId/screenViewId are non-null — a modal
  // body or a bare test mount (most existing EngineRunner tests) leaves both
  // null and every hook below short-circuits to a no-op.

  /// Foreground time for the current visit. Runs only while this mount is
  /// both visible (not covered/offstage — see [_isVisible]) and the app
  /// itself is foregrounded; background time must not count as dwell.
  final Stopwatch _dwell = Stopwatch();

  /// This mount's own visibility, independent of [EngineRunner.screenId]'s
  /// owning `ScreenPage` — a kept-alive tab branch mounts one [EngineRunner]
  /// per tab, and each detects its own activation/deactivation.
  bool _visible = false;

  bool _appForeground = true;

  /// Whether this visit ever actually ran the dwell clock. Guards
  /// [_emitLeave] against firing for a visit that mounted already-offstage
  /// (a kept-alive tab prefetch) and never became visible.
  bool _trackedAnyForeground = false;

  bool _leaveEmittedForVisit = false;

  double _maxScrollPct = 0;
  bool _reachedEnd = false;
  int _scrollSessions = 0;

  /// Identifies the one vertical scrollable this visit's depth is measured
  /// against — see [_handleScrollNotification].
  BuildContext? _primaryScrollContext;

  @override
  void initState() {
    super.initState();
    _tryCompile();
    if (widget.screenId != null) WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.screenId == null) return;
    final visible = _isVisible(context);
    final was = _visible;
    _visible = visible;
    _updateDwellRunning();
    if (was && !visible) {
      _emitLeave(
        exitReason:
            widget.resolveExitReason?.call() ?? _inferExitReason(context),
      );
    }
  }

  /// Mirrors `ScreenPage._isVisible` (`app/routing/screen_page.dart`): a
  /// go_router `IndexedStack` tab branch wraps its inactive content in
  /// `Offstage` + `TickerMode(enabled: false)`, not Flutter's `Visibility`.
  bool _isVisible(BuildContext context) =>
      (ModalRoute.of(context)?.isCurrent ?? true) && TickerMode.of(context);

  /// The attribution this mount can make on its own, used only when
  /// [EngineRunner.resolveExitReason] had nothing to say.
  ///
  /// A covering route reads as `push` whether it is another screen or an
  /// app-owned page (the in-app webview): from here they are the same event —
  /// something was pushed over this screen.
  String? _inferExitReason(BuildContext context) {
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return 'push';
    if (!TickerMode.of(context)) return 'tab';
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.screenId == null) return;
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _appForeground) return;
    _appForeground = foreground;
    _updateDwellRunning();
  }

  /// Starts or stops the dwell clock so it only ever accumulates time this
  /// mount was both visible and the app was foregrounded.
  void _updateDwellRunning() {
    final shouldRun = _visible && _appForeground;
    if (shouldRun == _dwell.isRunning) return;
    if (shouldRun) {
      _dwell.start();
      _trackedAnyForeground = true;
    } else {
      _dwell.stop();
    }
  }

  @override
  void didUpdateWidget(EngineRunner old) {
    super.didUpdateWidget(old);
    // Compilation depends on template identity and declared keys. Value-only
    // changes flow through the root scope without recompiling.
    if (!identical(widget.template, old.template) ||
        !setEquals(widget.rootData.keys.toSet(), old.rootData.keys.toSet())) {
      setState(_tryCompile);
    }
    // A new screen_view_id means a new visit for an otherwise-kept-alive
    // mount (tab switched back to) — the old visit's leave was already
    // emitted by the visibility-loss path in [didChangeDependencies]; this
    // just resets the counters so the new visit starts from zero.
    if (widget.screenViewId != null &&
        widget.screenViewId != old.screenViewId) {
      _resetVisitMetrics();
      _updateDwellRunning();
    }
  }

  void _resetVisitMetrics() {
    _dwell
      ..stop()
      ..reset();
    _trackedAnyForeground = false;
    _leaveEmittedForVisit = false;
    _maxScrollPct = 0;
    _reachedEnd = false;
    _scrollSessions = 0;
    _primaryScrollContext = null;
  }

  /// Emits `screen_leave` for the current visit at most once. A visit that
  /// never ran the dwell clock (mounted already-offstage and never became
  /// visible) has nothing meaningful to report and is skipped.
  void _emitLeave({String? exitReason}) {
    if (_leaveEmittedForVisit || !_trackedAnyForeground) return;
    _leaveEmittedForVisit = true;
    if (_dwell.isRunning) _dwell.stop();
    Telemetry.record(
      'screen_leave',
      screenId: widget.screenId,
      screenViewId: widget.screenViewId,
      properties: {
        'foreground_ms': _dwell.elapsedMilliseconds,
        'max_depth': _depthBucket(_maxScrollPct),
        'reached_end': _reachedEnd,
        'scroll_sessions': _scrollSessions,
        if (exitReason != null) 'exit_reason': exitReason,
        if (widget.surfaceType != null) 'surface_type': widget.surfaceType,
        if (widget.modalId != null) 'modal_id': widget.modalId,
      },
    );
  }

  static int _depthBucket(double pct) {
    if (pct >= 100) return 100;
    if (pct >= 90) return 90;
    if (pct >= 75) return 75;
    if (pct >= 50) return 50;
    if (pct >= 25) return 25;
    return 0;
  }

  /// Tracks scroll depth for `screen_leave`'s `max_depth`/`reached_end`/
  /// `scroll_sessions` (TELEMETRY.md §3 "스크롤 깊이의 범위").
  ///
  /// A single listener at the mount root sees every descendant scrollable via
  /// bubbling, which is also the trap: sibling scrollables are all reported
  /// at `depth == 0`, and a horizontal carousel bubbles the same as the
  /// screen's real vertical list. Horizontal notifications are rejected
  /// outright, and the first vertical scrollable to report a scroll start
  /// becomes this visit's "primary" — every other vertical scrollable's
  /// notifications are ignored, so a carousel mixed in with the real list
  /// cannot inflate depth toward a false 100%.
  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;

    if (notification is ScrollStartNotification) {
      _primaryScrollContext ??= notification.context;
      if (notification.context != _primaryScrollContext) return false;
      _scrollSessions++;
    } else if (notification.context != _primaryScrollContext) {
      return false;
    }

    if (metrics.maxScrollExtent > 0) {
      final pct = (metrics.pixels / metrics.maxScrollExtent * 100).clamp(
        0.0,
        100.0,
      );
      if (pct > _maxScrollPct) _maxScrollPct = pct;
    }
    if (metrics.extentAfter <= 0.5) _reachedEnd = true;

    return false; // Observe only — let the notification keep bubbling.
  }

  /// Compiles the template and records failures for the mount error boundary.
  ///
  /// Failures are reported through Flutter diagnostics before the fallback UI
  /// is rendered. A successful compilation clears any previous error.
  void _tryCompile() {
    try {
      _directive = _compile();
      _compileError = null;
    } catch (error, stack) {
      _compileError = error;
      if (kDebugMode) EngineLog.screen.compileFailed(error);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'engine',
          context: ErrorDescription('compiling an EngineRunner template'),
        ),
      );
    }
  }

  /// Parses, compiles, and validates the current template.
  ///
  /// Template defects propagate to [_tryCompile] for mount-level isolation.
  Directive _compile() {
    final sw = kDebugMode ? (Stopwatch()..start()) : null;
    if (kDebugMode) EngineLog.screen.compiling();
    // Seed the compile-time schema registries from the runtime catalog before
    // validating: the validator reads them but no longer touches the factory.
    WidgetFactory.ensureRegistered();
    DriverRegistry.ensureRegistered();
    final result = Compile.build(widget.template, widget.rootData.keys.toSet());
    if (kDebugMode) EngineLog.screen.compiled(result.nodeCount, sw!.elapsed);
    return result.directive;
  }

  @override
  void dispose() {
    if (widget.screenId != null) {
      WidgetsBinding.instance.removeObserver(this);
      // A full unmount while still visible closes out the visit; one already
      // closed via visibility loss (tab switch) is a no-op via the guard.
      // The context cannot be consulted here, so the cause comes from the
      // owner — falling back to `background` only when the app itself was no
      // longer foregrounded, which is the one cause this mount can be sure of.
      if (_visible) {
        _emitLeave(
          exitReason:
              widget.resolveExitReason?.call() ??
              (_appForeground ? null : 'background'),
        );
      }
    }
    // Only a host created by this root owns its overlay. Modal bodies inherit an
    // overlay whose lifetime is controlled by the opening mount.
    if (widget.host == null) _engineHost?.overlay?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compilation failures render a mount fallback because no directive exists.
    if (_compileError != null) return _errorBoundary(context);
    // A single inherited scale keeps dimensional property resolution consistent
    // throughout the mount.
    final scale = EngineMetrics.scaleForWidth(MediaQuery.sizeOf(context).width);
    // Modal bodies share services and the opening stack but fork registries so
    // their anchor and focus identifiers remain a separate logical screen.
    final host = _engineHost ??= widget.host != null
        ? widget.host!.forkForModalBody(_registries)
        : EngineHost(
            registries: _registries,
            modalTemplates: widget.modalTemplates,
            overlay: _captureOverlay(context),
            navigate: widget.navigate,
            toast: widget.toast,
            screenId: widget.screenId,
          );
    if (kDebugMode) {
      EngineLog.screen.mount(widget.template['_type']?.toString() ?? 'unknown');
    }
    return _withTelemetry(
      EngineMetrics(
        scale: scale,
        child: EngineRegistryScope(
          // Widgets always receive this root's isolated registries.
          registries: _registries,
          child: EngineHostScope(
            host: host,
            child: _buildRootScope(),
          ),
        ),
      ),
    );
  }

  /// Publishes [EngineRunner.screenId]/[screenViewId] via [TelemetryScope] and
  /// installs the root scroll listener that feeds [_handleScrollNotification].
  /// A no-op wrapper — bare [child] — for a mount with no screen identity
  /// (modal bodies, and most existing engine tests).
  /// Mounts the compiled tree with [EngineRunner.rootData] merged into the
  /// ROOT scope's state.
  ///
  /// Route/query parameters arrive as [EngineRunner.rootData]. Templates read
  /// them with plain `${key}` bindings, so they must live in the root scope's
  /// own state — and OVERRIDE a declared `_state` default for the same key
  /// (screens routinely declare `id: null` and expect `/screen?id=1` to fill
  /// it). A parent-layer seed cannot do that: the root `_scope` state would
  /// shadow it.
  Widget _buildRootScope() {
    final directive = _directive;
    if (directive is ScopeDirective) {
      return Scope(
        config: ScopeConfig(
          state: {...directive.config.state, ...widget.rootData},
        ),
        actions: directive.actions,
        lifecycle: directive.lifecycle,
        skeleton: directive.skeleton == null
            ? null
            : NodeBuilder.build(directive.skeleton!),
        child: NodeBuilder.build(directive.child),
      );
    }
    // No root `_scope` — expose rootData through a plain state layer.
    return Scope.ofState(widget.rootData, child: NodeBuilder.build(directive));
  }

  Widget _withTelemetry(Widget child) {
    final screenId = widget.screenId;
    final screenViewId = widget.screenViewId;
    if (screenId == null || screenViewId == null) return child;
    return TelemetryScope(
      screenId: screenId,
      screenViewId: screenViewId,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: child,
      ),
    );
  }

  /// Captures the nearest overlay, or returns `null` when none is available.
  OverlayHandle? _captureOverlay(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    return overlay == null ? null : OverlayHandle(overlay);
  }

  /// Builds the user-facing fallback for a mount-level compilation failure.
  ///
  /// Detailed diagnostics are reported by [_tryCompile]. Defers to
  /// [EngineRunner.errorBuilder] when the app supplied one; otherwise falls
  /// back to bare text so the engine still renders standalone.
  Widget _errorBoundary(BuildContext context) {
    final builder = widget.errorBuilder;
    if (builder != null) return builder(context, _compileError!);
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('화면을 불러올 수 없어요.', textAlign: TextAlign.center),
      ),
    );
  }
}
