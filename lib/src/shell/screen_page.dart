import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../contract/screen_loader.dart';
import '../engine_runner.dart';
import '../runtime/engine_host.dart';
import '../contract/error_observer.dart';
import '../runtime/engine_errors.dart';
import '../runtime/engine_presentation.dart';
import '../runtime/telemetry/screen_visit.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
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

  NavigateHandle _navigateHandle(GoRouter router) => NavigateHandle(
    push: (location) => router.push<Object?>(location),
    go: router.go,
    pop: ([result]) {
      if (router.canPop()) router.pop(result);
    },
  );

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

    final router = GoRouter.of(context);
    return EngineRunner(
      screenId: widget.screenId,
      screenViewId: _screenViewId,
      rootData: widget.params,
      template: loaded.template,
      modalTemplates: loaded.modals,
      navigate: _navigateHandle(router),
      toast: _toastHandle(),
      errorBuilder: (context, error) => _errorView(context, error),
    );
  }
}
