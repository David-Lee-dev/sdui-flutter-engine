/// One `net` command call, exactly as the template wrote it.
///
/// [fields] is the command node minus the engine-owned flow keys
/// (`_when`/`_dedupe`/`_then`/`_error`/`_dismiss`/`_always`) and the
/// `protocol` selector, with `${}` expressions already resolved. The engine
/// does not interpret any of it — which keys a request needs (`op`, `path`,
/// `method`, `params`, …) is the [NetworkClient] implementation's own
/// vocabulary, shared between it and the templates that call it.
class NetworkRequest {
  const NetworkRequest({required this.fields, this.correlationId});

  final Map<String, Object?> fields;

  /// Correlates engine telemetry with the app's own request logging.
  final String? correlationId;
}

/// Carries either response data or a domain error reported by a [NetworkClient].
class NetworkResult {
  const NetworkResult({this.data, this.errorCode, this.errorMessage});

  /// Reserved [errorCode] value a [NetworkClient] returns when a request
  /// failed at the shared boundary (401/404/429/5xx/no-response) and the
  /// app's boundary layer already fully handled it — clearing the token,
  /// routing, or showing a notice, as applicable.
  ///
  /// This lives on the contract rather than the app's implementation because
  /// both sides need it: the app-side [NetworkClient] produces it, and the
  /// engine's `NetDriver` maps it onto `DriverError.handled` so the failure
  /// never reaches a template's `_error` branch.
  static const handledErrorCode = 'BOUNDARY_HANDLED';

  final Object? data; // success payload → handler `$data`
  final String? errorCode; // non-null → failure; becomes DriverError.code
  final String? errorMessage;
}

/// Executes the application's network calls for the template `net` command.
///
/// The engine is transport-blind: it forwards the request verbatim and routes
/// the [NetworkResult] envelope (`data` → `$data`, `errorCode` → `_error`
/// branches). GraphQL, REST, gRPC — the implementation decides, including
/// which request fields it requires; report a malformed request through
/// [NetworkResult.errorCode] so templates can handle it.
abstract class NetworkClient {
  Future<NetworkResult> send(NetworkRequest request);
}
