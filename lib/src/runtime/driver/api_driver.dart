import 'package:sdui_engine/src/dependency/api_client.dart';

import '_base.dart';
import 'driver_error.dart';

class _UnconfiguredApiClient implements ApiClient {
  const _UnconfiguredApiClient();
  @override
  Future<ApiResult> execute({
    required String query,
    required Map<String, Object?> variables,
    String? correlationId,
  }) => throw StateError(
    'ApiClient not configured — register ApiDriver(client: …) at app boot.',
  );
}

/// Executes an API command and converts reported service failures to [DriverError].
class ApiDriver extends Driver {
  const ApiDriver({ApiClient client = const _UnconfiguredApiClient()})
    : _client = client;

  final ApiClient _client;

  @override
  String get type => 'api';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final query = ctx.params['query'];
    if (query is! String || query.isEmpty) {
      throw ArgumentError.value(
        ctx.params['query'],
        'query',
        'api requires a non-empty "query"',
      );
    }
    final rawVars = ctx.params['variables'];
    final variables = rawVars is Map
        ? rawVars.map((k, v) => MapEntry('$k', v))
        : const <String, Object?>{};
    if (ctx.isCancelled) return null;
    final result = await _client.execute(
      query: query,
      variables: variables,
      correlationId: ctx.correlationId,
    );
    final errorCode = result.errorCode;
    if (errorCode == ApiResult.handledErrorCode) {
      // The app's boundary layer already dealt with this failure globally.
      throw const DriverError(DriverError.handled);
    }
    if (errorCode != null) {
      throw DriverError(errorCode, result.errorMessage);
    }
    return result.data;
  }
}
