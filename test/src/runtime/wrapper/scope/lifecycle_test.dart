import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';

/// 발화된 액션의 `tag` 인자를 기록하는 테스트 driver — lifecycle 발화 시점·횟수를 관찰한다.
class _RecordDriver extends Driver {
  const _RecordDriver(this.log);

  final List<String> log;

  @override
  String get type => 'record';

  @override
  Future<Object?> run(DriverContext ctx) async {
    log.add('${ctx.params['tag']}');
    return null;
  }
}

ScopeDirective _compileScope(Map<String, Object?> scopeConfig) =>
    TemplateCompiler.buildDirectiveTree(
          TemplateParser.buildUiTree({
            '_type': 'text',
            'value': 'x',
            '_scope': scopeConfig,
          }),
        )
        as ScopeDirective;

Widget _scopeForApp(Map<String, Object?> scopeConfig) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(
    TemplateParser.buildUiTree({
      '_type': 'text',
      'value': 'x',
      '_scope': scopeConfig,
    }),
  ),
);

Widget _scoped(Map<String, Object?> scopeConfig) => Directionality(
  textDirection: TextDirection.ltr,
  child: _scopeForApp(scopeConfig),
);

void main() {
  group('TemplateCompiler', () {
    group('_compileLifecycle', () {
      test('훅을 LifecycleHook으로 — trigger·action·delay·every 채운다', () {
        final scope = _compileScope({
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
            {'on': 'interval', 'action': 'poll', 'every': 5000, 'delay': 100},
          ],
        });
        expect(scope.lifecycle, hasLength(2));
        expect(scope.lifecycle[0].trigger, LifecycleTrigger.mount);
        expect(scope.lifecycle[0].action, 'load');
        expect(scope.lifecycle[0].delay, Duration.zero);
        expect(scope.lifecycle[1].trigger, LifecycleTrigger.interval);
        expect(scope.lifecycle[1].every, const Duration(milliseconds: 5000));
        expect(scope.lifecycle[1].delay, const Duration(milliseconds: 100));
      });

      test('_lifecycle 없으면 빈 리스트', () {
        expect(
          _compileScope({'_state': <String, Object?>{}}).lifecycle,
          isEmpty,
        );
      });

      test('미지 트리거는 마운트-치명', () {
        expect(
          () => _compileScope({
            '_lifecycle': [
              {'on': 'nope', 'action': 'a'},
            ],
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });

      test('빈/비문자열 action은 치명', () {
        expect(
          () => _compileScope({
            '_lifecycle': [
              {'on': 'mount', 'action': ''},
            ],
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });

      test('interval은 양수 every 필수', () {
        expect(
          () => _compileScope({
            '_lifecycle': [
              {'on': 'interval', 'action': 'a'},
            ],
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });

      test('every는 interval 전용', () {
        expect(
          () => _compileScope({
            '_lifecycle': [
              {'on': 'mount', 'action': 'a', 'every': 100},
            ],
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });

      test('명시적 null·비-리스트는 치명', () {
        expect(
          () => _compileScope({'_lifecycle': null}),
          throwsA(isA<InvalidTemplateException>()),
        );
        expect(
          () => _compileScope({
            '_lifecycle': {'on': 'mount'},
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });
    });
  });

  group('ScopeState lifecycle 발화', () {
    tearDown(DriverRegistry.reset);

    Map<String, Object?> remountScopeConfig() => {
      '_action': {
        'on_remount': {'_type': 'record', 'tag': 'remount'},
      },
      '_lifecycle': [
        {'on': 'remount', 'action': 'on_remount'},
      ],
    };

    testWidgets('opaque route를 push 후 pop하면 remount가 한 번 발화한다', (tester) async {
      final log = <String>[];
      final navigatorKey = GlobalKey<NavigatorState>();
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: _scopeForApp(remountScopeConfig()),
        ),
      );

      unawaited(
        navigatorKey.currentState!.push<void>(
          MaterialPageRoute(builder: (_) => const SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(log, ['remount']);
    });

    testWidgets('중첩 Navigator 바깥 root route 복귀에도 remount가 발화한다', (
      tester,
    ) async {
      final log = <String>[];
      final rootNavigatorKey = GlobalKey<NavigatorState>();
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => _scopeForApp(remountScopeConfig()),
            ),
          ),
        ),
      );

      unawaited(
        rootNavigatorKey.currentState!.push<void>(
          MaterialPageRoute(builder: (_) => const SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(log, ['remount']);
    });

    testWidgets('TickerMode 비활성 branch가 다시 활성화되면 remount가 발화한다', (
      tester,
    ) async {
      final log = <String>[];
      late StateSetter setHostState;
      var tickerEnabled = true;
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setHostState = setState;
              return TickerMode(
                enabled: tickerEnabled,
                child: _scopeForApp(remountScopeConfig()),
              );
            },
          ),
        ),
      );

      setHostState(() => tickerEnabled = false);
      await tester.pump();
      setHostState(() => tickerEnabled = true);
      await tester.pump();

      expect(log, ['remount']);
    });

    testWidgets('이미 가려진 상태에서 mount해도 remount는 발화하지 않는다', (tester) async {
      final log = <String>[];
      DriverRegistry.register(_RecordDriver(log));

      await tester.pumpWidget(
        MaterialApp(
          home: TickerMode(
            enabled: false,
            child: _scopeForApp(remountScopeConfig()),
          ),
        ),
      );

      expect(log, isEmpty);
    });

    testWidgets('mount는 paint 전, render는 첫 프레임 후 순서로 발화', (tester) async {
      final log = <String>[];
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        _scoped({
          '_action': {
            'on_mount': {'_type': 'record', 'tag': 'mount'},
            'on_render': {'_type': 'record', 'tag': 'render'},
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'on_mount'},
            {'on': 'render', 'action': 'on_render'},
          ],
        }),
      );
      expect(log, ['mount', 'render']);
    });

    testWidgets('dispose는 트리 이탈 시 발화(그 전엔 안 함)', (tester) async {
      final log = <String>[];
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        _scoped({
          '_action': {
            'bye': {'_type': 'record', 'tag': 'bye'},
          },
          '_lifecycle': [
            {'on': 'dispose', 'action': 'bye'},
          ],
        }),
      );
      expect(log, isEmpty);

      await tester.pumpWidget(const SizedBox());
      expect(log, ['bye']);
    });

    testWidgets('interval은 every마다 반복하고 dispose로 멈춘다', (tester) async {
      final log = <String>[];
      DriverRegistry.register(_RecordDriver(log));
      await tester.pumpWidget(
        _scoped({
          '_action': {
            'tick': {'_type': 'record', 'tag': 'tick'},
          },
          '_lifecycle': [
            {'on': 'interval', 'action': 'tick', 'every': 1000},
          ],
        }),
      );
      await tester.pump(const Duration(milliseconds: 10)); // delay 0 첫 발화
      await tester.pump(const Duration(seconds: 1)); // periodic 1
      await tester.pump(const Duration(seconds: 1)); // periodic 2
      final ticks = log.length;
      expect(ticks, greaterThanOrEqualTo(2));

      await tester.pumpWidget(const SizedBox()); // dispose → 타이머 취소
      await tester.pump(const Duration(seconds: 2));
      expect(log.length, ticks); // 더 이상 안 늘어남
    });

    testWidgets('interval 발화는 디버그 로그를 남기지 않는다 (mount는 남긴다)', (tester) async {
      // `testWidgets` restores foundation debug vars at body end, so `debugPrint`
      // is swapped back in a `finally` — not `addTearDown`, which runs too late.
      final original = debugPrint;
      final lines = <String>[];
      EngineLog.configure(minLevel: LogLevel.debug, colors: false);
      addTearDown(
        () => EngineLog.configure(minLevel: LogLevel.debug, colors: true),
      );
      debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
      final recorded = <String>[];
      try {
        DriverRegistry.register(_RecordDriver(recorded));
        await tester.pumpWidget(
          _scoped({
            '_action': {
              'boot': {'_type': 'record', 'tag': 'boot'},
              'tick': {'_type': 'record', 'tag': 'tick'},
            },
            '_lifecycle': [
              {'on': 'mount', 'action': 'boot'},
              {'on': 'interval', 'action': 'tick', 'every': 1000},
            ],
          }),
        );
        await tester.pump(
          const Duration(milliseconds: 10),
        ); // mount + interval 첫 발화
        await tester.pump(const Duration(seconds: 1)); // periodic 1
        await tester.pump(const Duration(seconds: 1)); // periodic 2
        await tester.pumpWidget(const SizedBox()); // dispose → 타이머 취소
      } finally {
        debugPrint = original;
      }

      // mount 액션은 정상적으로 로그를 남긴다 — 로깅 자체는 켜져 있음을 보장.
      expect(lines.any((line) => line.contains('boot')), isTrue);
      // interval 액션(발화·설정 모두)은 어떤 엔진 로그도 남기지 않는다.
      expect(lines.any((line) => line.contains('tick')), isFalse);
    });

    group('lifecycle 재조정 (②c — 훅 표가 바뀌면 다시 세운다)', () {
      testWidgets('empty→nonempty 교체 시 새 mount 훅이 발화한다', (tester) async {
        final log = <String>[];
        DriverRegistry.register(_RecordDriver(log));
        // 처음엔 lifecycle 없음
        await tester.pumpWidget(_scoped(const {'_state': <String, Object?>{}}));
        expect(log, isEmpty);

        // 같은 위치에 lifecycle이 추가된 config로 교체
        await tester.pumpWidget(
          _scoped(const {
            '_action': {
              'go': {'_type': 'record', 'tag': 'mount'},
            },
            '_lifecycle': [
              {'on': 'mount', 'action': 'go'},
            ],
          }),
        );
        await tester.pump();
        expect(log, ['mount']); // 재조정이 새 훅을 시작
      });

      testWidgets('interval 훅을 제거하면 옛 타이머가 멈춘다 (누수·유령 발화 방지)', (tester) async {
        final log = <String>[];
        DriverRegistry.register(_RecordDriver(log));
        await tester.pumpWidget(
          _scoped(const {
            '_action': {
              'tick': {'_type': 'record', 'tag': 'tick'},
            },
            '_lifecycle': [
              {'on': 'interval', 'action': 'tick', 'every': 1000},
            ],
          }),
        );
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump(const Duration(seconds: 1));
        final ticks = log.length;
        expect(ticks, greaterThan(0));

        // lifecycle이 사라진 config로 교체 — 옛 interval 타이머가 재조정으로 취소돼야 한다.
        await tester.pumpWidget(_scoped(const {'_state': <String, Object?>{}}));
        await tester.pump(const Duration(seconds: 3));
        expect(log.length, ticks); // 더 안 늘어남
      });
    });
  });
}
