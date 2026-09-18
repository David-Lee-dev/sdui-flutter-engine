import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';

void main() {
  test('configure(output:)가 로그 라인을 앱 소유 sink로 보낸다', () {
    final lines = <String>[];
    EngineLog.configure(minLevel: LogLevel.debug, colors: false, output: lines.add);
    addTearDown(
      // A closure, not `debugPrint` itself: the global is swappable and must
      // be read at call time by later capture-style tests.
      () => EngineLog.configure(
        minLevel: LogLevel.debug,
        colors: true,
        output: (line) => debugPrint(line),
      ),
    );

    EngineLog.net('hello');

    expect(lines, hasLength(1));
    expect(lines.single, contains('hello'));
  });

  late DebugPrintCallback originalDebugPrint;
  late List<String> lines;

  setUp(() {
    originalDebugPrint = debugPrint;
    lines = [];
    debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
    EngineLog.configure(minLevel: LogLevel.trace, colors: false);
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
    EngineLog.configure(minLevel: LogLevel.debug, colors: true);
  });

  test('different tags keep the message column aligned', () {
    EngineLog.net('net-message');
    EngineLog.state.commit(const {'key': 1});
    EngineLog.action.start('action-message');

    expect(lines, hasLength(3));
    final starts = [
      lines[0].indexOf('net-message'),
      lines[1].indexOf('key 1'),
      lines[2].indexOf('action-message'),
    ];
    expect(starts.toSet(), hasLength(1));
  });

  test('minimum level suppresses debug and info', () {
    EngineLog.configure(minLevel: LogLevel.warn, colors: false);

    EngineLog.net('debug-message');
    EngineLog.action.start('info-message');
    EngineLog.widget.unknownProps('text', const ['bad'], r'$');

    expect(lines, hasLength(1));
    expect(lines.single, contains('ignored prop(s)'));
  });

  test('tag filter suppresses other tags', () {
    EngineLog.configure(
      minLevel: LogLevel.debug,
      colors: false,
      tags: const {'driver'},
    );

    EngineLog.net('hidden');
    EngineLog.driver.start('net', const {'query': 'viewer'});

    expect(lines, hasLength(1));
    expect(lines.single, contains('[driver]'));
  });

  test('colors can be disabled', () {
    EngineLog.net('plain-message');

    expect(lines.single, isNot(contains('\x1B')));
  });

  test('colors wrap labels but leave the message in terminal default', () {
    EngineLog.configure(minLevel: LogLevel.debug, colors: true);

    EngineLog.net('default-message');

    final line = lines.single;
    expect(line, contains('\x1B[36mDEBUG\x1B[0m'));
    expect(line, contains('\x1B[2m[net]   \x1B[0m'));
    expect(line, endsWith('  default-message'));
  });

  test('runSilently suppresses logs emitted during its body', () {
    EngineLog.action.start('before');
    EngineLog.runSilently(() {
      EngineLog.action.start('inside');
      EngineLog.state.commit(const {'silent': 1});
    });
    EngineLog.action.start('after');

    expect(lines.any((line) => line.contains('inside')), isFalse);
    expect(lines.any((line) => line.contains('silent 1')), isFalse);
    expect(lines.any((line) => line.contains('before')), isTrue);
    expect(lines.any((line) => line.contains('after')), isTrue);
  });

  test('runSilently keeps suppressing across async gaps in its body', () async {
    await EngineLog.runSilently(() async {
      await Future<void>.delayed(Duration.zero);
      EngineLog.action.start('async-inside');
    });

    expect(lines.any((line) => line.contains('async-inside')), isFalse);
  });

  test('summarize compacts collections and long strings', () {
    expect(EngineLog.summarize(const [1, 2, 3]), '[3]');
    expect(EngineLog.summarize(const {'one': 1, 'two': 2}), '{one, two}');

    final summary = EngineLog.summarize(List.filled(100, 'x').join());
    expect(summary, hasLength(81));
    expect(summary, endsWith('…'));
  });
}
