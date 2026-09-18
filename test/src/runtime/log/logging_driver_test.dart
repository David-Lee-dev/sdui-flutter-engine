import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/log/logging_driver.dart';

final class _FakeDriver extends Driver {
  _FakeDriver({this.result, this.error});

  final Object? result;
  final Object? error;

  @override
  String get type => 'fake';

  @override
  Future<Object?> run(DriverContext ctx) async {
    if (error != null) throw error!;
    return result;
  }
}

final class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

void main() {
  late DebugPrintCallback originalDebugPrint;
  late List<String> lines;
  late DriverContext context;

  setUp(() {
    originalDebugPrint = debugPrint;
    lines = [];
    debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
    EngineLog.configure(minLevel: LogLevel.debug, colors: false);
    context = DriverContext(
      params: const {'id': 1},
      state: _NoState(),
      isCancelled: () => false,
    );
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
    EngineLog.configure(minLevel: LogLevel.debug, colors: true);
  });

  test('passes through the result and emits start and ok', () async {
    final result = <String, Object?>{'ok': true};
    final driver = LoggingDriver(_FakeDriver(result: result));

    expect(await driver.run(context), same(result));
    expect(lines, hasLength(2));
    expect(lines[0], contains('fake ▶'));
    expect(lines[1], contains('fake ◀ ok'));
  });

  test('emits fail and rethrows', () async {
    final error = StateError('broken');
    final driver = LoggingDriver(_FakeDriver(error: error));

    await expectLater(driver.run(context), throwsA(same(error)));
    expect(lines, hasLength(2));
    expect(lines[0], contains('fake ▶'));
    expect(lines[1], contains('fake ✗'));
  });
}
