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

  static final _broken = Expando<bool>('EngineErrors.broken');

  /// Runs paint- or tick-time [fn] on behalf of [owner], where no build-time
  /// node boundary can catch it.
  ///
  /// The first throw marks [owner] broken for good and is reported once as a
  /// [SduiErrorScope.nodeBuild] error at [path]; from then on every call
  /// returns [fallback] without running [fn], so a failing painter or ticker
  /// does not report every frame.
  static T isolate<T>(
    Object owner,
    String? path,
    T Function() fn, {
    required T fallback,
  }) {
    if (_broken[owner] == true) return fallback;
    try {
      return fn();
    } catch (error, stack) {
      _broken[owner] = true;
      report(
        SduiError(
          scope: SduiErrorScope.nodeBuild,
          error: error,
          stack: stack,
          nodePath: path,
        ),
      );
      return fallback;
    }
  }

  /// Restores the default for test isolation.
  static void reset() => observer = const FlutterErrorObserver();
}
