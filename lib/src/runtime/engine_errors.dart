import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/impl/flutter_error_observer.dart';

import 'log/engine_log.dart';

/// Process-wide error-observer holder; installed once at boot.
///
/// Every unexpected-engine-error site reports through [report], so the
/// installed observer is the single app-side hook for structured engine
/// errors. The engine's debug log line is emitted here, before the observer
/// — swapping the observer redirects external reporting, never the log.
abstract final class EngineErrors {
  static SduiErrorObserver observer = const FlutterErrorObserver();

  /// Reports [error], guaranteeing observation can never take the engine
  /// down with it — observation must not alter control flow.
  static void report(SduiError error) {
    EngineLog.error(
      error.error,
      error.stack ?? StackTrace.current,
      tag: switch (error.scope) {
        SduiErrorScope.screenLoad => 'screen',
        SduiErrorScope.action => 'action',
        SduiErrorScope.nodeBuild => 'widget',
        SduiErrorScope.templateCompile => 'screen',
        SduiErrorScope.scopeReseed => 'scope',
      },
    );
    try {
      observer.onError(error);
    } catch (_) {
      // A throwing observer is an app bug; swallowing here keeps the render
      // and action paths alive.
    }
  }

  /// Restores the default for test isolation.
  static void reset() => observer = const FlutterErrorObserver();
}
