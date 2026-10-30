import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../contract/screen_loader.dart';
import '../engine_runner.dart';
import '../runtime/engine_host.dart';
import '../runtime/transition/transition_origin.dart';
import '../contract/error_observer.dart';
import '../runtime/engine_errors.dart';
import '../runtime/engine_presentation.dart';
import '../runtime/telemetry/screen_visit.dart';
import 'go_router_navigate.dart';
import 'screen_cache.dart';
import 'sdui_state.dart';

/// Builds the widget shown while a screen's template is loading.
typedef SduiLoadingBuilder = Widget Function(BuildContext context);

/// Builds the widget shown when loading failed; call [retry] to reload.
typedef SduiErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// Hosts one server-driven screen: load template -> mount the engine.
///
/// This is the default page the generic route uses. Override the loading and
/// error surfaces via [loadingBuilder] / [errorBuilder], or replace the page
/// entirely by registering your own route for a screen id.
///
/// The page owns the visit's telemetry identity: each successful load issues
/// a fresh `screen_view_id`, records `screen_view`, and hands the id to
/// [EngineRunner] — which measures dwell/scroll and emits the matching
/// `screen_leave` (mirroring how the modal frame owns its surface's view).
final class SduiScreenPage extends StatefulWidget {
  const SduiScreenPage({
    super.key,
    required this.screenId,
    required this.loader,
    this.params = const {},
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String screenId;
  final ScreenLoader loader;

  /// Route query parameters, forwarded into the engine's root scope state
  /// (they override `_state` defaults with the same key).
  final Map<String, Object?> params;

  final SduiLoadingBuilder? loadingBuilder;
  final SduiErrorBuilder? errorBuilder;

  @override
  State<SduiScreenPage> createState() => _SduiScreenPageState();
}

final class _SduiScreenPageState extends State<SduiScreenPage> {
  /// The in-flight load; results from an abandoned load (retry pressed) are
  /// ignored by identity comparison.
  Future<LoadedScreen>? _pending;

  LoadedScreen? _loaded;
  Object? _error;

  /// The current visit's `screen_view_id` — issued per successful load.
  String? _screenViewId;

  /// Revalidates a cache hit for the next open; `null` after a load.
  VoidCallback? _refresh;

  @override
  void initState() {
    super.initState();
    // An engine page hands over the entry its transition was decided from;
    // direct use reads the cache.
    final snapshot = context.getInheritedWidgetOfExactType<ScreenSnapshot>();
    final cached = snapshot != null && snapshot.screenId == widget.screenId
        ? snapshot.screen
        : SduiState.cache.peek(widget.screenId);
    if (cached == null) {
      _load();
      return;
    }
    _loaded = cached.screen;
    _screenViewId = ScreenVisit.begin(widget.screenId).id;
    final cache = SduiState.cache;
    _refresh = () => cache.refresh(widget.screenId, widget.loader);
  }

  void _load() {
    final future = widget.loader.load(widget.screenId);
    _pending = future;
    future.then(
      (screen) {
        if (!mounted || !identical(future, _pending)) return;
        final visit = ScreenVisit.begin(widget.screenId);
        setState(() {
          _loaded = screen;
          _error = null;
          _screenViewId = visit.id;
        });
      },
      onError: (Object error, StackTrace stack) {
        if (!mounted || !identical(future, _pending)) return;
        EngineErrors.report(
          SduiError(
            scope: SduiErrorScope.screenLoad,
            error: error,
            stack: stack,
            screenId: widget.screenId,
          ),
        );
        setState(() {
          _error = error;
          _loaded = null;
        });
      },
    );
  }

  void _retry() {
    setState(() {
      _loaded = null;
      _error = null;
    });
    _load();
  }

  ToastHandle _toastHandle() => ToastHandle((message, variant) {
    final presenter = SduiState.toastPresenter;
    if (presenter != null) {
      presenter(context, message, variant);
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  });

  Widget _loading(BuildContext context) =>
      widget.loadingBuilder?.call(context) ??
      EnginePresentation.value.loadingBuilder?.call(context) ??
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _errorView(BuildContext context, Object error) =>
      widget.errorBuilder?.call(context, error, _retry) ??
      EnginePresentation.value.loadErrorBuilder?.call(context, error, _retry) ??
      Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _retry,
            child: Text('Failed to load — tap to retry\n$error'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) return _errorView(context, error);
    final loaded = _loaded;
    if (loaded == null) return _loading(context);

    return _AfterTransition(
      onSettled: _refresh,
      child: Listener(
        onPointerDown: (event) {
          final navigator = Navigator.maybeOf(context);
          if (navigator != null) {
            TransitionOrigins.of(navigator).pointerDown(event);
          }
        },
        child: EngineRunner(
          screenId: widget.screenId,
          screenViewId: _screenViewId,
          rootData: widget.params,
          template: loaded.template,
          modalTemplates: loaded.modals,
          navigate: goRouterNavigateHandle(GoRouter.of(context)),
          toast: _toastHandle(),
          errorBuilder: (context, error) => _errorView(context, error),
        ),
      ),
    );
  }
}

/// Calls [onSettled] once, when the enclosing route's entrance transition has
/// completed, so its work (the cache refresh decodes on this isolate) never
/// lands inside the transition. Without a route animation, or with one that
/// already completed, it runs after the first frame. A page that leaves
/// before its transition completes (popped mid-push) runs it on dispose, so
/// every open still revalidates once.
///
/// The route lookup lives in this element, not the page, so route status
/// changes rebuild only this pass-through.
class _AfterTransition extends StatefulWidget {
  const _AfterTransition({required this.onSettled, required this.child});

  final VoidCallback? onSettled;
  final Widget child;

  @override
  State<_AfterTransition> createState() => _AfterTransitionState();
}

class _AfterTransitionState extends State<_AfterTransition> {
  Animation<double>? _animation;
  bool _settled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settled || widget.onSettled == null) return;
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _animation)) return;
    _animation?.removeStatusListener(_onStatus);
    _animation = animation;
    animation?.addStatusListener(_onStatus);
    // A pushed route's animation proxy only follows its controller after the
    // first frame, so the status is read then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = _animation;
      if (current == null || current.status == AnimationStatus.completed) {
        _settle();
      }
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _settle();
  }

  void _settle() {
    if (_settled) return;
    _settled = true;
    _animation?.removeStatusListener(_onStatus);
    widget.onSettled?.call();
  }

  @override
  void dispose() {
    _settle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
