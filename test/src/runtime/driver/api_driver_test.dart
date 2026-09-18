import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/api_client.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/api_driver.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient(this.result);

  final ApiResult result;
  String? lastQuery;
  Map<String, Object?>? lastVariables;
  String? lastCorrelationId;
  int calls = 0;

  @override
  Future<ApiResult> execute({
    required String query,
    required Map<String, Object?> variables,
    String? correlationId,
  }) async {
    calls++;
    lastQuery = query;
    lastVariables = variables;
    lastCorrelationId = correlationId;
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
  group('ApiDriver', () {
    late _FakeApiClient client;
    late ApiDriver driver;

    setUp(() {
      client = _FakeApiClient(const ApiResult());
      driver = ApiDriver(client: client);
    });

    group('run', () {
      test('성공하면 data를 반환한다', () async {
        final data = <String, Object?>{
          'viewer': <String, Object?>{'id': 'user-1'},
        };
        client = _FakeApiClient(ApiResult(data: data));
        driver = ApiDriver(client: client);

        expect(
          await driver.run(_ctx({'query': 'query { viewer { id } }'})),
          data,
        );
      });

      test('query와 resolved variables를 그대로 전달한다', () async {
        const query = r'''query Viewer($id: ID!) {
  viewer(id: $id) { id nickname }
}''';
        final variables = <String, Object?>{'id': 'user-1', 'active': true};

        await driver.run(_ctx({'query': query, 'variables': variables}));

        expect(client.lastQuery, same(query));
        expect(client.lastVariables, variables);
      });

      test('variables가 없으면 빈 map을 전달한다', () async {
        await driver.run(_ctx({'query': 'query { viewer { id } }'}));

        expect(client.lastVariables, isEmpty);
      });

      test('DriverContext correlationId를 API client에 전달한다', () async {
        await driver.run(
          _ctx({'query': 'Viewer'}, correlationId: 'invocation-1'),
        );

        expect(client.lastCorrelationId, 'invocation-1');
      });

      test('errorCode가 있으면 DriverError를 던진다', () async {
        client = _FakeApiClient(
          const ApiResult(
            errorCode: 'DUP_NICK',
            errorMessage: '이미 사용 중인 닉네임입니다.',
          ),
        );
        driver = ApiDriver(client: client);

        await expectLater(
          driver.run(_ctx({'query': 'mutation { updateNickname }'})),
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
        client = _FakeApiClient(
          const ApiResult(errorCode: ApiResult.handledErrorCode),
        );
        driver = ApiDriver(client: client);

        await expectLater(
          driver.run(_ctx({'query': 'query { viewer { id } }'})),
          throwsA(
            isA<DriverError>().having(
              (error) => error.code,
              'code',
              DriverError.handled,
            ),
          ),
        );
      });

      test('query가 없거나 비어 있으면 ArgumentError를 던지고 호출하지 않는다', () async {
        await expectLater(driver.run(_ctx({})), throwsArgumentError);
        await expectLater(driver.run(_ctx({'query': ''})), throwsArgumentError);

        expect(client.calls, 0);
      });

      test('owner가 이미 사라졌으면 null을 반환하고 호출하지 않는다', () async {
        final result = await driver.run(
          _ctx({'query': 'query { viewer { id } }'}, cancelled: true),
        );

        expect(result, isNull);
        expect(client.calls, 0);
      });

      test('기본 client가 설정되지 않았으면 StateError를 던진다', () async {
        await expectLater(
          const ApiDriver().run(_ctx({'query': 'query{x}'})),
          throwsStateError,
        );
      });
    });
  });
}
