import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';

// Its own file: the level is process-wide state that other log tests change.
void main() {
  test('기본 최소 레벨은 info다 (debug는 configure로 켠다)', () {
    final lines = <String>[];
    EngineLog.configure(colors: false, output: lines.add);

    EngineLog.net('debug line');
    EngineLog.warn('warn line');
    expect(lines, hasLength(1));
    expect(lines.single, contains('warn line'));

    EngineLog.configure(minLevel: LogLevel.debug);
    EngineLog.net('debug line');
    expect(lines.last, contains('debug line'));
  });
}
