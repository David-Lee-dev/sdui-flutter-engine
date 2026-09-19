/// Where in the engine an [SduiError] was raised.
enum SduiErrorScope {
  /// The app's [ScreenLoader] threw while loading a screen.
  screenLoad,

  /// The screen template failed to compile (parse/compile/validate).
  templateCompile,

  /// A single node's build failed and was degraded in place (node isolation).
  nodeBuild,

  /// An action command threw an unexpected error (not a domain
  /// `DriverError`, which routes to the template's `_error` flows instead).
  action,

  /// A scope rejected a reseed whose keyset changed (schema drift).
  scopeReseed,
}

/// One engine error, structured for app-side observation.
///
/// Carrier type only — what to do with it (crash-report, log, count) is the
/// [SduiErrorObserver] implementation's decision.
final class SduiError {
  const SduiError({
    required this.scope,
    required this.error,
    this.stack,
    this.screenId,
    this.nodePath,
  });

  final SduiErrorScope scope;

  final Object error;

  final StackTrace? stack;

  /// The screen the error belongs to, when the raising site knows it.
  final String? screenId;

  /// The template path of the failing node ([SduiErrorScope.nodeBuild]).
  final String? nodePath;
}

/// [optional seam] Receives every unexpected engine error, structured.
///
/// The engine's internal error reporting converges here: template compile
/// failures, degraded node builds, unexpected action errors, and rejected
/// scope reseeds all pass through the installed observer. The package
/// default (`FlutterErrorObserver`) preserves the classic behavior — engine
/// log plus [FlutterError.reportError] — so installing nothing changes
/// nothing. Replace it via `Sdui.initialize(errorObserver: ...)` to route
/// engine errors into the app's own crash reporting without string-matching
/// the global Flutter error channel.
///
/// Domain failures are not errors and never arrive here: a `DriverError` /
/// `CommandFailure` routes to the template's `_error[code]` flow by design.
abstract class SduiErrorObserver {
  const SduiErrorObserver();

  /// Called on the raising site's stack; must not throw.
  void onError(SduiError error);
}
