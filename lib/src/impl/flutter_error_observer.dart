import 'package:flutter/foundation.dart';

import '../contract/error_observer.dart';

/// Package default [SduiErrorObserver]: [FlutterError.reportError].
///
/// Preserves the engine's classic reporting so apps that install nothing see
/// exactly the previous behavior (errors surface through
/// [FlutterError.onError] with `library: 'engine'`). The engine's own debug
/// log line is emitted before any observer runs and is not this class's job.
final class FlutterErrorObserver extends SduiErrorObserver {
  const FlutterErrorObserver();

  @override
  void onError(SduiError error) {
    // A failed screen load is an operational condition (network down, server
    // error), not an engine defect — it gets the error surface and the
    // structured observer, but must not masquerade as a framework error.
    // Custom observers see every scope and decide for themselves.
    if (error.scope == SduiErrorScope.screenLoad) return;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error.error,
        stack: error.stack,
        library: 'engine',
        context: ErrorDescription(switch (error.scope) {
          SduiErrorScope.screenLoad => 'loading screen ${error.screenId}',
          SduiErrorScope.action => 'running an action command',
          SduiErrorScope.nodeBuild =>
            'rendering SDUI node at ${error.nodePath}',
          SduiErrorScope.templateCompile =>
            'compiling screen ${error.screenId}',
          SduiErrorScope.scopeReseed => 'reseeding a Scope',
        }),
      ),
    );
  }
}
