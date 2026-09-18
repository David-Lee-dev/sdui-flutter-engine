/// Carries either API response data or a domain error reported by an [ApiClient].
class ApiResult {
  const ApiResult({this.data, this.errorCode, this.errorMessage});

  /// Reserved [errorCode] value an [ApiClient] returns when a request failed
  /// at the shared gateway boundary (401/404/429/5xx/no-response) and the
  /// app's boundary layer already fully handled it — clearing the token,
  /// routing, or showing a notice, as applicable.
  ///
  /// This lives on the contract rather than the app's driver implementation
  /// because both sides need it: the app-side [ApiClient] produces it, and
  /// the engine's `ApiDriver` maps it onto `DriverError.handled` so the
  /// failure never reaches a template's `_error` branch.
  static const handledErrorCode = 'BOUNDARY_HANDLED';

  final Object? data; // success payload → handler `$data`
  final String? errorCode; // non-null → failure; becomes DriverError.code
  final String? errorMessage;
}

/// Executes the application’s configured API operation.
abstract class ApiClient {
  Future<ApiResult> execute({
    required String query,
    required Map<String, Object?> variables,
    String? correlationId,
  });
}
