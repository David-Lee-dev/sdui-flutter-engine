/// Represents an expected command failure that action flows can branch on by [code].
class DriverError implements Exception {
  const DriverError(this.code, [this.message, this.data]);

  /// The reserved code a driver throws to signal a user dismissal/cancellation
  /// (e.g. a modal closed via its backdrop) rather than a failure.
  ///
  /// The action host routes this to a command's `_dismiss` flow instead of
  /// `_error`, and treats it as a normal outcome (no error report) when the
  /// command has no `_dismiss` handler.
  static const dismissed = 'DISMISSED';

  /// The reserved code a driver throws to signal a boundary failure the app
  /// already fully handled outside the template (e.g. a gateway 401 that
  /// cleared the token and routed to `/login`, or a 429 that showed a shared
  /// notice).
  ///
  /// The action host skips both `_then` and `_error` for this code and does
  /// not report it — the failure was already dealt with once, globally.
  /// `_always` still runs, since it is cleanup rather than a failure branch.
  static const handled = 'BOUNDARY_HANDLED';

  final String code;

  final String? message;

  final Object? data;

  @override
  String toString() =>
      'DriverError($code${message == null ? '' : ': $message'})';
}
