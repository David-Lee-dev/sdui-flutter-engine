import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dependency/screen_loader.dart';
import '../engine_runner.dart';
import '../runtime/engine_host.dart';

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
  late Future<LoadedScreen> _screen;

  @override
  void initState() {
    super.initState();
    _screen = widget.loader.load(widget.screenId);
  }

  void _retry() {
    final next = widget.loader.load(widget.screenId);
    setState(() {
      _screen = next;
    });
  }

  NavigateHandle _navigateHandle(GoRouter router) => NavigateHandle(
    push: (location) => router.push<Object?>(location),
    go: router.go,
    pop: ([result]) {
      if (router.canPop()) router.pop(result);
    },
  );

  ToastHandle _toastHandle() => ToastHandle(
    (message, variant) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message))),
  );

  Widget _loading(BuildContext context) =>
      widget.loadingBuilder?.call(context) ??
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _error(BuildContext context, Object error) =>
      widget.errorBuilder?.call(context, error, _retry) ??
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
    final router = GoRouter.of(context);
    return FutureBuilder<LoadedScreen>(
      future: _screen,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loading(context);
        }
        if (snapshot.hasError) {
          return _error(context, snapshot.error!);
        }
        return EngineRunner(
          screenId: widget.screenId,
          rootData: widget.params,
          template: snapshot.data!.template,
          modalTemplates: snapshot.data!.modals,
          navigate: _navigateHandle(router),
          toast: _toastHandle(),
          errorBuilder: (context, error) => _error(context, error),
        );
      },
    );
  }
}
