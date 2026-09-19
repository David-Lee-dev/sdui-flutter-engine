import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/external_command.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/external_driver.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _FakeCommand extends ExternalCommand {
  _FakeCommand({this.type = 'external', this.result, this.error});

  @override
  final String type;
  final Object? result;
  final Object? error;
  CommandInvocation? invocation;

  @override
  Future<Object?> run(CommandInvocation invocation) async {
    this.invocation = invocation;
    if (error != null) throw error!;
    return result;
  }
}

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

DriverContext _ctx(
  Map<String, Object?> params, {
  Object? event,
  bool cancelled = false,
  void Function() Function(void Function())? onOwnerDispose,
}) => DriverContext(
  params: params,
  state: _NoState(),
  event: event,
  isCancelled: () => cancelled,
  onOwnerDispose: onOwnerDispose,
);

void main() {
  group('ExternalDriver', () {
    test('onDispose 등록이 소유 스코프의 dispose 체인에 연결된다', () async {
      final registered = <void Function()>[];
      void Function()? received;
      final driver = ExternalDriver(
        _HookCommand((invocation) async {
          received = invocation.onDispose(() {});
          return null;
        }),
      );

      await driver.run(
        _ctx(const {}, onOwnerDispose: (cleanup) {
          registered.add(cleanup);
          return () => registered.remove(cleanup);
        }),
      );

      expect(registered, hasLength(1));
      received!(); // 정상 종료 시 등록 해제
      expect(registered, isEmpty);
    });

    test("type returns the wrapped command's type", () {
      final driver = ExternalDriver(_FakeCommand(type: 'app_external'));

      expect(driver.type, 'app_external');
    });

    test("run returns the command's return value", () async {
      final driver = ExternalDriver(_FakeCommand(result: {'id': 7}));

      expect(await driver.run(_ctx(const {})), {'id': 7});
    });

    test('CommandDismissed becomes a dismissed DriverError', () async {
      final driver = ExternalDriver(
        _FakeCommand(error: const CommandDismissed()),
      );

      await expectLater(
        driver.run(_ctx(const {})),
        throwsA(
          isA<DriverError>().having(
            (e) => e.code,
            'code',
            DriverError.dismissed,
          ),
        ),
      );
    });

    test('CommandFailure preserves code, message, and data', () async {
      const data = {'retryable': true};
      final driver = ExternalDriver(
        _FakeCommand(
          error: const CommandFailure(
            'service_unavailable',
            message: 'Try again later',
            data: data,
          ),
        ),
      );

      await expectLater(
        driver.run(_ctx(const {})),
        throwsA(
          isA<DriverError>()
              .having((e) => e.code, 'code', 'service_unavailable')
              .having((e) => e.message, 'message', 'Try again later')
              .having((e) => e.data, 'data', data),
        ),
      );
    });

    test('generic errors propagate unchanged', () async {
      final error = StateError('unexpected');
      final driver = ExternalDriver(_FakeCommand(error: error));

      await expectLater(driver.run(_ctx(const {})), throwsA(same(error)));
    });

    test('passes params, event, and cancellation through', () async {
      final command = _FakeCommand();
      final driver = ExternalDriver(command);
      final params = <String, Object?>{'resolved': 'value'};
      final event = <String, Object?>{'source': 'button'};

      await driver.run(_ctx(params, event: event, cancelled: true));

      expect(command.invocation?.params, same(params));
      expect(command.invocation?.event, same(event));
      expect(command.invocation?.isCancelled, isTrue);
    });
  });
}

final class _HookCommand extends ExternalCommand {
  const _HookCommand(this._run);
  final Future<Object?> Function(CommandInvocation) _run;
  @override
  String get type => 'hook';
  @override
  Future<Object?> run(CommandInvocation invocation) => _run(invocation);
}
