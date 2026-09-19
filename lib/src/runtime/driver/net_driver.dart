import 'package:sdui_engine/src/contract/network_client.dart';

import '_base.dart';
import 'driver_error.dart';

class _UnconfiguredNetworkClient implements NetworkClient {
  const _UnconfiguredNetworkClient();
  @override
  Future<NetworkResult> send(NetworkRequest request) => throw StateError(
    'NetworkClient not configured — register NetDriver(client: …) at app boot.',
  );
}

/// Executes a `net` command by forwarding it to the app's [NetworkClient].
///
/// The engine owns only the envelope: it strips the `protocol` selector,
/// passes every remaining command field through verbatim, and routes the
/// [NetworkResult] (`data` → `$data`, `errorCode` → `_error` branches,
/// [NetworkResult.handledErrorCode] → silent [DriverError.handled]). Request
/// vocabulary — `op`, `path`, whatever the client defines — is opaque here.
class NetDriver extends Driver {
  const NetDriver({
    NetworkClient client = const _UnconfiguredNetworkClient(),
    Map<String, NetworkClient> protocols = const {},
  }) : _client = client,
       _protocols = protocols;

  /// Default client, used when a command names no `protocol`.
  final NetworkClient _client;

  /// Named clients selected by the command's `protocol` field — lets one app
  /// mix transports (`protocol: rest` next to a GraphQL default).
  final Map<String, NetworkClient> _protocols;

  @override
  String get type => 'net';

  // Network calls are the long-running commands worth latency spans.
  @override
  bool get measured => true;

  @override
  Future<Object?> run(DriverContext ctx) async {
    final protocol = ctx.params['protocol'];
    NetworkClient client = _client;
    if (protocol != null) {
      if (protocol is! String || !_protocols.containsKey(protocol)) {
        throw ArgumentError.value(
          protocol,
          'protocol',
          'unknown net protocol — configured: ${_protocols.keys.join(', ')}',
        );
      }
      client = _protocols[protocol]!;
    }

    final fields = <String, Object?>{...ctx.params}..remove('protocol');
    if (ctx.isCancelled) return null;
    final result = await client.send(
      NetworkRequest(fields: fields, correlationId: ctx.correlationId),
    );
    final errorCode = result.errorCode;
    if (errorCode == NetworkResult.handledErrorCode) {
      // The app's boundary layer already dealt with this failure globally.
      throw const DriverError(DriverError.handled);
    }
    if (errorCode != null) {
      throw DriverError(errorCode, result.errorMessage);
    }
    return result.data;
  }
}
