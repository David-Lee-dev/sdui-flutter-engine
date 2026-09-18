import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/network_client.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/net_driver.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

class _FakeNetworkClient implements NetworkClient {
  _FakeNetworkClient(this.result);

  final NetworkResult result;
  NetworkRequest? lastRequest;
  int calls = 0;

  @override
  Future<NetworkResult> send(NetworkRequest request) async {
    calls++;
    lastRequest = request;
    return result;
  }
}

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

DriverContext _ctx(
  Map<String, Object?> params, {
  bool cancelled = false,
  String? correlationId,
}) => DriverContext(
  params: params,
  state: _NoState(),
  isCancelled: () => cancelled,
  invocation: correlationId == null
      ? null
      : ActionInvocation(invocationId: correlationId, origin: ActionOrigin.tap),
);

void main() {
  group('NetDriver', () {
    late _FakeNetworkClient client;
    late NetDriver driver;

    setUp(() {
      client = _FakeNetworkClient(const NetworkResult());
      driver = NetDriver(client: client);
    });

    group('run', () {
      test('성공하면 data를 반환한다', () async {
        final data = <String, Object?>{
          'viewer': <String, Object?>{'id': 'user-1'},
        };
        client = _FakeNetworkClient(NetworkResult(data: data));
        driver = NetDriver(client: client);

        expect(await driver.run(_ctx({'op': 'Viewer'})), data);
      });

      test('커맨드 필드를 해석 없이 그대로 전달한다', () async {
        final fields = <String, Object?>{
          'op': 'Viewer',
          'params': <String, Object?>{'id': 'user-1'},
          'method': 'GET', // 엔진이 모르는 키 — 구현체 어휘도 통과한다
          'path': '/viewer',
        };

        await driver.run(_ctx(Map.of(fields)));

        expect(client.lastRequest!.fields, fields);
      });

      test('protocol 키는 클라이언트 선택에만 쓰고 전달하지 않는다', () async {
        final rest = _FakeNetworkClient(const NetworkResult());
        driver = NetDriver(client: client, protocols: {'rest': rest});

        await driver.run(_ctx({'protocol': 'rest', 'op': 'Viewer'}));

        expect(client.calls, 0);
        expect(rest.calls, 1);
        expect(rest.lastRequest!.fields, {'op': 'Viewer'});
      });

      test('미등록 protocol이면 ArgumentError를 던지고 호출하지 않는다', () async {
        await expectLater(
          driver.run(_ctx({'protocol': 'rest', 'op': 'Viewer'})),
          throwsArgumentError,
        );
        expect(client.calls, 0);
      });

      test('DriverContext correlationId를 요청에 싣는다', () async {
        await driver.run(_ctx({'op': 'Viewer'}, correlationId: 'invocation-1'));

        expect(client.lastRequest!.correlationId, 'invocation-1');
      });

      test('errorCode가 있으면 DriverError를 던진다', () async {
        client = _FakeNetworkClient(
          const NetworkResult(
            errorCode: 'DUP_NICK',
            errorMessage: '이미 사용 중인 닉네임입니다.',
          ),
        );
        driver = NetDriver(client: client);

        await expectLater(
          driver.run(_ctx({'op': 'UpdateNickname'})),
          throwsA(
            isA<DriverError>()
                .having((error) => error.code, 'code', 'DUP_NICK')
                .having(
                  (error) => error.message,
                  'message',
                  '이미 사용 중인 닉네임입니다.',
                ),
          ),
        );
      });

      test('errorCode가 BOUNDARY_HANDLED면 DriverError.handled를 던진다', () async {
        client = _FakeNetworkClient(
          const NetworkResult(errorCode: NetworkResult.handledErrorCode),
        );
        driver = NetDriver(client: client);

        await expectLater(
          driver.run(_ctx({'op': 'Viewer'})),
          throwsA(
            isA<DriverError>().having(
              (error) => error.code,
              'code',
              DriverError.handled,
            ),
          ),
        );
      });

      test('owner가 이미 사라졌으면 null을 반환하고 호출하지 않는다', () async {
        final result = await driver.run(_ctx({'op': 'Viewer'}, cancelled: true));

        expect(result, isNull);
        expect(client.calls, 0);
      });

      test('기본 client가 설정되지 않았으면 StateError를 던진다', () async {
        await expectLater(
          const NetDriver().run(_ctx({'op': 'Viewer'})),
          throwsStateError,
        );
      });
    });
  });
}
