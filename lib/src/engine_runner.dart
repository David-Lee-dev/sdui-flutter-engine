import 'package:flutter/foundation.dart' show kDebugMode, setEquals;
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';

import 'runtime/driver/driver_registry.dart';
import 'runtime/engine_host.dart';
import 'contract/error_observer.dart';
import 'runtime/engine_errors.dart';
import 'runtime/engine_presentation.dart';
import 'runtime/engine_subtree.dart';
import 'runtime/engine_registries.dart';
import 'engine.dart';
import 'runtime/directive_subtree.dart';
import 'runtime/interpreter/building/node_builder.dart';
import 'runtime/log/engine_log.dart';
import 'runtime/telemetry/visit_observer.dart';
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

class _EngineRunnerState extends State<EngineRunner> {
  /// Registries retained for the full mount lifetime.
  final EngineRegistries _registries = EngineRegistries();

  /// Cached compilation output, refreshed only for structural input changes.
  late Directive _directive;

  /// Runtime services retained so the modal stack remains stable across builds.
  EngineHost? _engineHost;

  /// The current compilation failure, cleared after successful recompilation.
  Object? _compileError;

  @override
  void initState() {
    super.initState();
    // Lower runtime modules (the modal frame) mount nested engines through
    // this seam instead of importing the runner — see [EngineSubtree].
    DirectiveSubtree.builder ??= NodeBuilder.build;
    EngineSubtree.builder ??= (request) => EngineRunner(
      template: request.template,
      rootData: request.rootData,
      host: request.host,
      screenId: request.screenId,
      screenViewId: request.screenViewId,
      surfaceType: request.surfaceType,
      modalId: request.modalId,
      resolveExitReason: request.resolveExitReason,
    );
    _tryCompile();
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
      EngineErrors.report(
        SduiError(
          scope: SduiErrorScope.templateCompile,
          error: error,
          stack: stack,
          screenId: widget.screenId,
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
    // Registries are pre-seeded with the built-in language; a mount still
    // forces the runtime catalogs once so directly-registered customs (bare
    // test mounts) are present in the snapshot below.
    WidgetFactory.ensureRegistered();
    DriverRegistry.ensureRegistered();
    final catalog = Engine.catalog;
    if (catalog == null) _warnUninitialized();
    final result = Compile.build(
      widget.template,
      widget.rootData.keys.toSet(),
      // A bare mount (no Engine.initialize) validates against the live
      // runtime snapshot, so directly-registered custom motions/functions
      // still pass — only the frozen boot catalog is missing.
      catalog: catalog ?? Engine.snapshotCatalog(),
    );
    if (kDebugMode) EngineLog.screen.compiled(result.nodeCount, sw!.elapsed);
    return result.directive;
  }

  @override
  void dispose() {
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
    // Visit measurement (dwell/scroll/screen_leave) is the observer's job —
    // the runner only mounts. Transparent when the mount has no identity.
    return VisitObserver(
      screenId: widget.screenId,
      screenViewId: widget.screenViewId,
      surfaceType: widget.surfaceType,
      modalId: widget.modalId,
      resolveExitReason: widget.resolveExitReason,
      child: EngineMetrics(
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

  /// Captures the nearest overlay, or returns `null` when none is available.
  OverlayHandle? _captureOverlay(BuildContext context) {
    final overlay = Overlay.maybeOf(context);
    return overlay == null ? null : OverlayHandle(overlay);
  }

  /// Builds the user-facing fallback for a mount-level compilation failure.
  ///
  /// Warned once per process: compiling without [Engine.initialize] means a
  /// registry-snapshot catalog — motion/function validation is off and the
  /// `net` command has no client. Intended only for bare test mounts; in an
  /// app this is a boot-order bug, so it must not stay silent.
  static bool _warnedUninitialized = false;

  static void _warnUninitialized() {
    if (_warnedUninitialized) return;
    _warnedUninitialized = true;
    EngineLog.warn(
      'EngineRunner mounted without Engine.initialize — no NetworkClient is '
      'configured and the catalog is an unfrozen snapshot. Call '
      'Sdui.initialize (or Engine.initialize) before mounting screens.',
    );
  }

  /// Detailed diagnostics are reported by [_tryCompile]. Precedence:
  /// mount-local [EngineRunner.errorBuilder], then the boot-injected
  /// [SduiPresentation.screenErrorBuilder], then a neutral text fallback so
  /// the engine still renders standalone.
  Widget _errorBoundary(BuildContext context) {
    final builder =
        widget.errorBuilder ?? EnginePresentation.value.screenErrorBuilder;
    if (builder != null) return builder(context, _compileError!);
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('This screen could not be loaded.', textAlign: TextAlign.center),
      ),
    );
  }
}
