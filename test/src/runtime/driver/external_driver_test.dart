import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/external_command.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/external_driver.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _FakeCommand implements ExternalCommand {
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
}) => DriverContext(
  params: params,
  state: _NoState(),
  event: event,
  isCancelled: () => cancelled,
);

void main() {
  group('ExternalDriver', () {
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
