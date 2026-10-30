import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/environment/_base.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/plain_observer.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';
import 'package:sdui_engine/src/runtime/wrapper/scroll_event_wrapper.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/auto_skeleton.dart';

/// 테스트가 직접 끝내는 비동기 driver — `tag`별 [Completer]가 응답을 쥔다.
///
/// 마운트 액션이 "아직 도착 안 한 데이터"를 기다리는 상황을 시간 순서대로 재현한다.
class _GateDriver extends Driver {
  _GateDriver(this.gates, this.calls);

  final Map<String, Completer<Object?>> gates;
  final List<String> calls;

  @override
  String get type => 'gate';

  @override
  Future<Object?> run(DriverContext ctx) {
    final tag = '${ctx.params['tag']}';
    calls.add(tag);
    return (gates[tag] ??= Completer<Object?>()).future;
  }
}

late Map<String, Completer<Object?>> _gates;
late List<String> _calls;

void _open(String tag, [Object? data]) =>
    (_gates[tag] ??= Completer<Object?>()).complete(data);

void _fail(String tag) => (_gates[tag] ??= Completer<Object?>()).completeError(
  const DriverError('boom'),
);

Widget _build(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Future<void> _pump(WidgetTester tester, Map<String, Object?> template) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: _build(template))));

/// The environment visible to the widget showing [text].
Environment _envAt(WidgetTester tester, Finder finder) =>
    Scope.envOf(tester.element(finder))!;

/// A gate command that writes its data into [key] on success.
Map<String, Object?> _load(String tag, String key) => {
  '_type': 'gate',
  'tag': tag,
  '_then': {'_type': 'set', key: r'${data}'},
};

/// A column under an automatic skeleton whose mount hooks each fill one key
/// through a gate named after it.
Map<String, Object?> _screen({
  required Map<String, Object?> state,
  required List<Map<String, Object?>> children,
  Map<String, Object?> extra = const {},
  List<Map<String, Object?>> lifecycle = const [],
}) => {
  '_type': 'column',
  'cross_axis_alignment': 'start',
  '_scope': {
    '_state': state,
    '_action': {
      for (final key in state.keys) 'load_$key': _load(key, key),
      ...extra,
    },
    '_lifecycle': [
      for (final key in state.keys) {'on': 'mount', 'action': 'load_$key'},
      ...lifecycle,
    ],
    '_skeleton': 'auto',
  },
  '_children': children,
};

Finder _maskOf(Finder finder) =>
    find.ancestor(of: finder, matching: find.byType(SkeletonMask));

RenderObject _mask(WidgetTester tester, Finder finder) =>
    tester.renderObject(_maskOf(finder).first);

class _TelemetrySink implements TelemetrySink {
  final events = <TelemetryEvent>[];

  @override
  void record(TelemetryEvent event) => events.add(event);

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) =>
      throw UnimplementedError();
}

const _grace = Duration(milliseconds: 300);
const _fade = Duration(milliseconds: 250);

void main() {
  setUp(() {
    _gates = {};
    _calls = [];
    DriverRegistry.register(_GateDriver(_gates, _calls));
  });

  group('auto skeleton — pending registration', () {
    testWidgets('mount 훅이 set 하는 키를 정의 scope에 pending으로 둔다', (tester) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'a': null, 'b': null, 'c': 0},
          '_action': {
            'load': [
              {
                '_type': 'gate',
                'tag': 'load',
                '_then': {'_type': 'set', 'a': r'${data}'},
                '_error': {
                  '_': {'_type': 'set', 'b': 'x'},
                },
              },
            ],
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {'_type': 'text', 'value': 'static'},
        ],
      });

      final env = _envAt(tester, find.text('static'));
      expect(env.pendingOf('a'), PendState.pending);
      // Only success flows are awaited; the `_error` write of `b` is not.
      expect(env.pendingOf('b'), PendState.none);
      expect(env.pendingOf('c'), PendState.none);

      _open('load', 1);
      await tester.pumpAndSettle();
      expect(env.pendState({'a', 'b'}), PendState.none);
    });

    testWidgets('자식 scope 훅이 조상 action이면 조상 store가 pending을 갖는다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'partners': null},
          '_action': {'load_partners': _load('p', 'partners')},
        },
        '_children': [
          {
            '_type': 'text',
            'value': 'child',
            '_scope': {
              '_state': {'local': null},
              '_lifecycle': [
                {'on': 'mount', 'action': 'load_partners'},
              ],
              '_skeleton': 'auto',
            },
          },
        ],
      });

      final child = _envAt(tester, find.text('child'));
      expect(child.pendingOf('local'), PendState.none);
      expect(child.parent!.pendingOf('partners'), PendState.pending);

      _open('p', const ['x']);
      await tester.pumpAndSettle();
      expect(child.parent!.pendingOf('partners'), PendState.settled);
    });

    testWidgets('mount 실패는 settle로 풀려 seed 값 UI가 남는다', (tester) async {
      await _pump(tester, {
        '_type': 'text',
        'value': r'${a ?? "seed"}',
        '_scope': {
          '_state': {'a': null},
          '_action': {
            'load': {
              ..._load('load', 'a'),
              '_error': {'_': <Object?>[]},
            },
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
      });
      final env = _envAt(tester, find.byType(Text));
      expect(env.pendingOf('a'), PendState.pending);

      _fail('load');
      await tester.pumpAndSettle();

      expect(env.pendingOf('a'), PendState.settled);
      expect(find.text('seed'), findsOneWidget);
    });

    testWidgets('정착 뒤 remount·재실행은 다시 pending으로 돌리지 않는다', (tester) async {
      await _pump(tester, {
        '_type': 'text',
        'value': r'${a}',
        '_scope': {
          '_state': {'a': null},
          '_action': {'load': _load('load', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
            {'on': 'remount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
      });
      _open('load', 'v1');
      await tester.pumpAndSettle();
      final env = _envAt(tester, find.text('v1'));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(_calls, ['load', 'load']);
      expect(env.pendingOf('a'), PendState.settled);
    });

    testWidgets('정착하지 않는 훅은 15초 watchdog가 풀고 진단을 남긴다', (tester) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));

      await _pump(tester, {
        '_type': 'text',
        'value': r'${a ?? "seed"}',
        '_scope': {
          '_state': {'a': null},
          '_action': {'load': _load('load', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
      });
      final env = _envAt(tester, find.byType(Text));

      await tester.pump(const Duration(seconds: 14));
      expect(env.pendingOf('a'), PendState.pending);

      await tester.pump(const Duration(seconds: 1));
      expect(env.pendingOf('a'), PendState.settled);
      expect(lines.where((l) => l.contains('skeleton')), hasLength(1));

      // The hook resolving late must not double-release or throw.
      _open('load', 'late');
      await tester.pumpAndSettle();
      expect(find.text('late'), findsOneWidget);
    });

    testWidgets('pending 영역의 중첩 scope mount는 조상 정착 뒤 한 번만 발화한다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'a': null},
          '_action': {'load': _load('outer', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'text',
            'value': 'inner',
            '_scope': {
              '_action': {
                'go': {'_type': 'gate', 'tag': 'inner'},
              },
              '_lifecycle': [
                {'on': 'mount', 'action': 'go'},
              ],
            },
          },
        ],
      });
      expect(_calls, ['outer']);

      _open('outer', 1);
      await tester.pump();
      await tester.pump();
      expect(_calls, ['outer', 'inner']);

      await tester.pump(const Duration(seconds: 1));
      expect(_calls, ['outer', 'inner']);
      _open('inner');
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — text bones', () {
    testWidgets('pending 텍스트는 grace 동안 실제 크기로 배치만, 뒤엔 bone을 그린다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {
              '_type': 'text',
              'value': r'${a}',
              'style': {'font_size': 20},
            },
          ],
        ),
      );
      final text = find.byType(Text);
      expect(tester.getSize(text).height, greaterThan(0));
      expect(_mask(tester, text), paintsNothing);

      await tester.pump(_grace);
      expect(_mask(tester, text), paints..rrect());

      _open('a', 'ready');
      await tester.pumpAndSettle();
    });

    testWidgets('grace 안의 쓰기는 bone·fade 없이 바로 실제 내용', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {'_type': 'text', 'value': r'${a}'},
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      _open('a', 'fast');
      await tester.pump();
      await tester.pump();

      final text = find.text('fast');
      expect(text, findsOneWidget);
      expect(_mask(tester, text), paints..paragraph());
      expect(_mask(tester, text), isNot(paints..rrect()));
      await tester.pump(_grace);
      expect(_mask(tester, text), isNot(paints..rrect()));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('grace 뒤 공개는 같은 element에서 250ms 동안 bone이 걷힌다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {'_type': 'text', 'value': r'${a}'},
          ],
        ),
      );
      await tester.pump(_grace);
      final before = tester.element(_maskOf(find.byType(Text)));

      _open('a', 'slow');
      await tester.pump();
      await tester.pump();
      await tester.pump(_fade ~/ 2);
      final text = find.text('slow');
      expect(identical(tester.element(_maskOf(text)), before), isTrue);
      expect(
        _mask(tester, text),
        paints
          ..paragraph()
          ..rrect(),
      );

      await tester.pump(_fade);
      expect(_mask(tester, text), paints..paragraph());
      expect(_mask(tester, text), isNot(paints..rrect()));
      expect(identical(tester.element(_maskOf(text)), before), isTrue);
    });

    testWidgets('정적 노드(리터럴 개행 포함)는 pending scope에서도 바로 실제 텍스트', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {'_type': 'text', 'value': 'hello\nworld'},
          ],
        ),
      );
      final text = find.text('hello\nworld');
      expect(text, findsOneWidget);
      expect(_maskOf(text), findsNothing);
      _open('a');
      await tester.pumpAndSettle();
    });

    testWidgets('리터럴 개행이 있는 보간 텍스트는 2줄 bone, 높이는 실제와 같다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'x': null, 'y': null},
          children: [
            {
              '_type': 'text',
              'value':
                  r'${x}원'
                  '\n'
                  r'상위 ${y}%',
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final text = find.byType(Text);
      final pendingHeight = tester.getSize(text).height;
      expect(
        _mask(tester, text),
        paints
          ..rrect()
          ..rrect(),
      );
      expect(
        _mask(tester, text),
        isNot(
          paints
            ..rrect()
            ..rrect()
            ..rrect(),
        ),
      );

      _open('x', 1200);
      _open('y', 3);
      await tester.pumpAndSettle();
      expect(find.text('1200원\n상위 3%'), findsOneWidget);
      expect(tester.getSize(find.byType(Text)).height, pendingHeight);
    });

    testWidgets('데이터가 줄을 정하는 텍스트는 max_lines 줄 수의 bone', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'desc': null},
          children: [
            {'_type': 'text', 'value': r'${desc}', 'max_lines': 2},
            {'_type': 'text', 'value': r'${desc}'},
          ],
        ),
      );
      await tester.pump(_grace);
      final texts = find.byType(Text);
      expect(
        _mask(tester, texts.at(0)),
        paints
          ..rrect()
          ..rrect(),
      );
      expect(_mask(tester, texts.at(1)), paints..rrect());
      expect(
        _mask(tester, texts.at(1)),
        isNot(
          paints
            ..rrect()
            ..rrect(),
        ),
      );
      _open('desc', 'd');
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — per-node reveal', () {
    testWidgets('훅 둘 중 A만 끝나면 A를 읽는 노드만 공개된다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null, 'b': null},
          children: [
            {'_type': 'text', 'value': r'A=${a}'},
            {'_type': 'text', 'value': r'B=${b}'},
          ],
        ),
      );
      await tester.pump(_grace);

      _open('a', 1);
      await tester.pump();
      await tester.pump(_fade * 2);

      expect(find.text('A=1'), findsOneWidget);
      expect(_mask(tester, find.text('A=1')), isNot(paints..rrect()));
      final b = find.byWidgetPredicate(
        (w) => w is Text && (w.data ?? '').startsWith('B='),
      );
      expect(find.text('B='), findsNothing);
      expect(_mask(tester, b), paints..rrect());

      _open('b', 2);
      await tester.pumpAndSettle();
      expect(find.text('B=2'), findsOneWidget);
    });

    testWidgets('null 위 산술로 실패하는 prop은 그 prop만 비워 크기를 지킨다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'w': null},
          children: [
            {
              '_type': 'container',
              'height': 40,
              'width': r'${w * 2}',
              'color': '#FF0000',
            },
          ],
        ),
      );
      final box = find.byType(Container);
      expect(box, findsOneWidget);
      expect(tester.getSize(box).height, 40);
      expect(tester.takeException(), isNull);

      _open('w', 30);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Container)), const Size(60, 40));
    });

    testWidgets('pending 노드는 tap·motion을 걸지 않고, payload만 읽는 노드는 그려지되 입력은 막힌다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          children: [
            {
              '_type': 'text',
              'value': r'${a}',
              '_on': {'tap': 'go'},
              '_motion': 'fade_in',
            },
            {
              '_type': 'text',
              'value': 'payload',
              '_on': {
                'tap': {'do': 'go', 'event': r'${a}'},
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final bone = find.byType(Text).first;
      expect(
        find.ancestor(of: bone, matching: find.byType(InteractionWrapper)),
        findsNothing,
      );
      expect(
        find.ancestor(of: bone, matching: find.byType(MotionWrapper)),
        findsNothing,
      );
      await tester.tap(bone, warnIfMissed: false);
      await tester.pump();
      expect(_calls, isNot(contains('go')));

      final payload = find.text('payload');
      expect(_maskOf(payload), findsNothing);
      expect(
        find.ancestor(of: payload, matching: find.byType(InteractionWrapper)),
        findsOneWidget,
      );
      await tester.tap(payload, warnIfMissed: false);
      await tester.pump();
      expect(_calls, isNot(contains('go')));
      final payloadCore = tester.element(find.byType(RichText).last);

      _open('a', 'ready');
      await tester.pumpAndSettle();
      final ready = find.text('ready');
      expect(
        find.ancestor(of: ready, matching: find.byType(MotionWrapper)),
        findsOneWidget,
      );
      await tester.tap(ready);
      await tester.pump();
      expect(_calls.where((c) => c == 'go'), hasLength(1));
      _open('go');
      await tester.pumpAndSettle();

      // The payload node fires once its payload key arrives, on the same core.
      expect(
        identical(tester.element(find.byType(RichText).last), payloadCore),
        isTrue,
      );
      _gates.remove('go');
      await tester.tap(payload);
      await tester.pump();
      expect(_calls.where((c) => c == 'go'), hasLength(2));
      _open('go');
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — held containers', () {
    testWidgets('payload만 기다리는 비-leaf는 자기 tap만 막고 안의 정적 버튼은 동작한다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
            'inner': {'_type': 'gate', 'tag': 'inner'},
          },
          children: [
            {
              '_type': 'container',
              'width': 200,
              'height': 100,
              'color': '#ff0000',
              'alignment': 'top_left',
              '_on': {
                'tap': {'do': 'go', 'event': r'${a}'},
              },
              '_children': [
                {
                  '_type': 'text',
                  'value': 'inner',
                  '_on': {'tap': 'inner'},
                },
              ],
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final box = tester.getRect(
        find.byWidgetPredicate(
          (w) => w is InteractionWrapper && w.on['tap'] == 'go',
        ),
      );
      expect(box.height, 100);
      final innerCore = tester.element(find.byType(RichText));

      await tester.tap(find.text('inner'));
      await tester.pump();
      expect(_calls, contains('inner'));
      await tester.tapAt(box.bottomCenter - const Offset(0, 5));
      await tester.pump();
      expect(_calls, isNot(contains('go')));

      _open('a', 'ready');
      _open('inner');
      await tester.pumpAndSettle();
      await tester.tapAt(box.bottomCenter - const Offset(0, 5));
      await tester.pump();
      expect(_calls.where((c) => c == 'go'), hasLength(1));
      expect(
        identical(tester.element(find.byType(RichText)), innerCore),
        isTrue,
      );
      _open('go');
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — branches', () {
    testWidgets('pending 조건은 pending 키를 읽는 가지(없으면 else)를 고른다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'items': null, 'user': null},
          children: [
            {
              '_type': 'cond',
              '_children': [
                {
                  '_type': 'text',
                  'value': 'empty',
                  '_if': r'${len(items ?? []) == 0}',
                },
                {'_type': 'text', 'value': r'${items}', '_else': true},
              ],
            },
            {
              '_type': 'text',
              'value': r'${user.name}',
              '_if': r'${user != null}',
            },
          ],
        ),
      );
      expect(find.text('empty'), findsNothing);
      expect(find.byType(SkeletonMask), findsNWidgets(2));

      _open('items', const <Object?>[]);
      _open('user', const {'name': 'kim'});
      await tester.pumpAndSettle();
      expect(find.text('empty'), findsOneWidget);
      expect(find.text('kim'), findsOneWidget);
    });

    testWidgets('_error가 쓰는 키는 기다리지 않아 오류 배너가 아닌 내용 가지가 bone', (tester) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'items': null, 'error': null},
          '_action': {
            'load': {
              '_type': 'gate',
              'tag': 'items',
              '_then': {'_type': 'set', 'items': r'${data}'},
              '_error': {
                '_': {'_type': 'set', 'error': 'failed'},
              },
            },
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'cond',
            '_children': [
              {
                '_type': 'text',
                'value': r'error: ${error}',
                '_if': r'${error != null}',
              },
              {'_type': 'text', 'value': r'${items}', '_else': true},
            ],
          },
        ],
      });
      final env = _envAt(tester, find.byType(Text));
      expect(env.pendingOf('error'), PendState.none);
      expect(find.textContaining('error'), findsNothing);
      expect(find.byType(SkeletonMask), findsOneWidget);
      expect(
        tester.widget<SkeletonMask>(find.byType(SkeletonMask)).pending,
        isTrue,
      );

      _open('items', 'loaded');
      await tester.pumpAndSettle();
      expect(find.text('loaded'), findsOneWidget);
    });

    testWidgets('pending switch는 pending 키를 읽는 첫 case를 고른다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'tier': null},
          children: [
            {
              '_type': 'switch',
              '_value': r'${tier.kind}',
              '_children': [
                {'_type': 'text', 'value': 'basic', '_case': 'basic'},
                {'_type': 'text', 'value': r'${tier.name}', '_case': 'vip'},
                {'_type': 'text', 'value': 'none', '_default': true},
              ],
            },
          ],
        ),
      );
      expect(find.text('none'), findsNothing);
      expect(find.text('basic'), findsNothing);
      expect(find.byType(SkeletonMask), findsOneWidget);

      _open('tier', const {'kind': 'basic'});
      await tester.pumpAndSettle();
      expect(find.text('basic'), findsOneWidget);
    });
  });

  group('auto skeleton — loops', () {
    /// A loop over `items` whose rows are 50-high boxes holding the name.
    Map<String, Object?> rows(Object? wrap, {int? count}) => {
      '_type': 'container',
      'height': 50,
      '_loop': {
        '_in': r'${items}',
        '_key': r'${item.id}',
        '_wrap': wrap,
        '_skeleton': ?count,
      },
      '_children': [
        {'_type': 'text', 'value': r'${item.name}'},
      ],
    };

    List<Map<String, Object?>> items(int n) => [
      for (var i = 0; i < n; i++) {'id': '$i', 'name': 'n$i'},
    ];

    Finder rowsIn(Type container) => find.descendant(
      of: find.byType(container),
      matching: find.byType(Scope),
    );

    testWidgets('_skeleton: 9 grid(3)은 실제 칸 크기의 placeholder 9칸', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            rows({
              '_type': 'grid',
              'cross_axis_count': 3,
              'child_aspect_ratio': 4,
              'shrink_wrap': true,
            }, count: 9),
          ],
        ),
      );
      expect(rowsIn(GridView), findsNWidgets(9));
      expect(find.byType(SkeletonMask), findsNWidgets(9));
      final cell = tester.getSize(rowsIn(GridView).first);

      _open('items', items(9));
      await tester.pumpAndSettle();
      expect(rowsIn(GridView), findsNWidgets(9));
      expect(tester.getSize(rowsIn(GridView).first), cell);
      expect(find.text('n8'), findsOneWidget);
    });

    testWidgets('스크롤 안에서 N이 없으면 placeholder 행이 viewport를 채운다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            {
              '_type': 'sizedbox',
              'height': 400,
              '_children': [rows('list')],
            },
          ],
        ),
      );
      final list = tester.getRect(find.byType(ListView));
      final built = rowsIn(ListView);
      expect(built.evaluate().length, greaterThanOrEqualTo(8));
      expect(
        tester.getRect(built.last).bottom,
        greaterThanOrEqualTo(list.bottom),
      );
      _open('items', items(2));
      await tester.pumpAndSettle();
      expect(rowsIn(ListView), findsNWidgets(2));
    });

    /// A 420-high scroll view inside the automatic skeleton, over [loop].
    Map<String, Object?> scrolled(Map<String, Object?> loop) => _screen(
      state: {'items': null},
      children: [
        {
          '_type': 'sizedbox',
          'height': 420,
          '_child': {'_type': 'single_child_scroll_view', '_child': loop},
        },
      ],
    );

    testWidgets('스크롤 안의 eager 루프도 viewport 높이만큼 행을 그린다', (tester) async {
      await _pump(tester, scrolled(rows('column')));
      await tester.pump();
      final viewport = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .viewportDimension;
      expect(viewport, 420);
      expect(find.byType(SkeletonMask), findsNWidgets((420 / 50).ceil()));
      _open('items', items(1));
      await tester.pumpAndSettle();
      expect(find.text('n0'), findsOneWidget);
    });

    testWidgets('세로 스크롤 안의 row·wrap 루프는 viewport로 세지 않고 경고와 함께 1칸', (
      tester,
    ) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));

      for (final wrap in ['row', 'wrap']) {
        _gates.clear();
        lines.clear();
        await tester.pumpWidget(const SizedBox());
        await _pump(tester, scrolled({...rows(wrap), 'width': 120}));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: wrap);
        expect(find.byType(SkeletonMask), findsOneWidget, reason: wrap);
        expect(
          lines.where((l) => l.contains('_skeleton')),
          hasLength(1),
          reason: wrap,
        );
        _open('items', items(2));
        await tester.pumpAndSettle();
        expect(find.text('n1'), findsOneWidget, reason: wrap);
      }
    });

    testWidgets('스크롤 밖에서 N이 없으면 경고와 함께 1행 / grid는 cross_axis_count칸', (
      tester,
    ) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));

      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            rows('column'),
            rows({'_type': 'grid', 'cross_axis_count': 3, 'shrink_wrap': true}),
          ],
        ),
      );
      expect(rowsIn(GridView), findsNWidgets(3));
      expect(find.byType(SkeletonMask), findsNWidgets(4));
      expect(lines.where((l) => l.contains('_skeleton')), hasLength(2));

      _open('items', items(2));
      await tester.pumpAndSettle();
      expect(find.text('n1'), findsNWidgets(2));
    });

    /// A 400-high scroll view paging `more` and reporting `moved`, over a
    /// loop of [count] 50-high rows.
    Map<String, Object?> paged({int count = 20}) => _screen(
      state: {'items': null},
      extra: {
        'more': {'_type': 'gate', 'tag': 'more'},
        'moved': {'_type': 'gate', 'tag': 'moved'},
      },
      children: [
        {
          '_type': 'sizedbox',
          'height': 400,
          '_on': {'end_reached': 'more', 'scroll': 'moved'},
          '_children': [rows('list', count: count)],
        },
      ],
    );

    testWidgets('placeholder 행이 있는 동안 scroll은 발화하고 end_reached만 막힌다', (
      tester,
    ) async {
      await _pump(tester, paged());
      ScrollPosition position() =>
          tester.state<ScrollableState>(find.byType(Scrollable)).position;
      position().jumpTo(100);
      await tester.pump();
      position().jumpTo(position().maxScrollExtent);
      await tester.pump();
      expect(_calls, ['items', 'moved']);

      // Leaving the end zone while held owes nothing on release.
      position().jumpTo(0);
      await tester.pump();
      _open('items', items(20));
      await tester.pumpAndSettle();
      expect(_calls, isNot(contains('more')));

      position().jumpTo(position().maxScrollExtent);
      await tester.pump();
      expect(_calls.where((c) => c == 'more'), hasLength(1));
      _open('more');
      _open('moved');
      await tester.pumpAndSettle();
    });

    testWidgets('placeholder 동안 끝에 머문 사용자는 공개 직후 end_reached를 한 번 받는다', (
      tester,
    ) async {
      await _pump(tester, paged());
      ScrollPosition position() =>
          tester.state<ScrollableState>(find.byType(Scrollable)).position;
      position().jumpTo(position().maxScrollExtent);
      await tester.pump();
      expect(_calls, isNot(contains('more')));

      _open('items', items(20));
      await tester.pumpAndSettle();
      expect(_calls.where((c) => c == 'more'), hasLength(1));
      _open('more');
      _open('moved');
      await tester.pumpAndSettle();
      expect(_calls.where((c) => c == 'more'), hasLength(1));
    });

    testWidgets('다른 곳에 placeholder 행이 있어도 auto 밖 스크롤의 end_reached는 발화한다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_action': {
            'outer_more': {'_type': 'gate', 'tag': 'outer_more'},
          },
        },
        '_children': [
          {
            '_type': 'sizedbox',
            'height': 200,
            '_on': {'end_reached': 'outer_more'},
            '_child': {
              '_type': 'single_child_scroll_view',
              '_child': {'_type': 'container', 'height': 1000},
            },
          },
          _screen(
            state: {'items': null},
            children: [
              {
                '_type': 'sizedbox',
                'height': 200,
                '_children': [rows('list', count: 5)],
              },
            ],
          ),
        ],
      });
      expect(find.byType(SkeletonRow), findsWidgets);
      final outer = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      outer.position.jumpTo(outer.position.maxScrollExtent);
      await tester.pump();
      expect(_calls, contains('outer_more'));
      _open('outer_more');
      _open('items', items(1));
      await tester.pumpAndSettle();
    });

    testWidgets('_skeleton 없는 lazy list는 viewport를 채우는 유한 행(최대 20)', (
      tester,
    ) async {
      int? childCount() =>
          (tester.widget<ListView>(find.byType(ListView)).childrenDelegate
                  as SliverChildBuilderDelegate)
              .childCount;
      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            {
              '_type': 'sizedbox',
              'height': 400,
              '_children': [rows('list')],
            },
          ],
        ),
      );
      await tester.pump();
      expect(childCount(), (400 / 50).ceil());
      _open('items', items(2));
      await tester.pumpAndSettle();

      _gates.clear();
      await tester.pumpWidget(const SizedBox());
      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            {
              '_type': 'sizedbox',
              'height': 400,
              '_children': [
                {...rows('list'), 'height': 10},
              ],
            },
          ],
        ),
      );
      await tester.pump();
      expect(childCount(), 20);
      _open('items', items(2));
      await tester.pumpAndSettle();
    });

    testWidgets('placeholder 행 안의 중첩 scope는 발화하지 않는다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'items': null},
          children: [
            {
              '_type': 'text',
              'value': r'${item.name}',
              '_loop': {
                '_in': r'${items}',
                '_key': r'${item.id}',
                '_skeleton': 2,
              },
              '_scope': {
                '_action': {
                  'row': {'_type': 'gate', 'tag': 'row'},
                },
                '_lifecycle': [
                  {'on': 'mount', 'action': 'row'},
                ],
              },
            },
          ],
        ),
      );
      expect(find.byType(SkeletonMask), findsNWidgets(2));
      expect(_calls, ['items']);

      _open('items', items(1));
      await tester.pumpAndSettle();
      expect(_calls, ['items', 'row']);
      _open('row');
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — shapes and motion', () {
    testWidgets('icon은 size 원, image는 선언 크기 bone, 크기 없는 image는 경고', (
      tester,
    ) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));

      await _pump(
        tester,
        _screen(
          state: {'p': null},
          children: [
            {'_type': 'icon', 'name': r'${p.icon}', 'size': 32},
            {
              '_type': 'image',
              'src': r'${p.image}',
              'width': 120,
              'height': 80,
            },
            {'_type': 'image', 'src': r'${p.image}'},
          ],
        ),
      );
      await tester.pump(_grace);
      final masks = find.byType(SkeletonMask);
      expect(masks, findsNWidgets(3));
      expect(tester.getSize(masks.at(0)), const Size(32, 32));
      expect(
        tester.renderObject(masks.at(0)),
        paints..rrect(
          rrect: RRect.fromLTRBR(0, 0, 32, 32, const Radius.circular(16)),
        ),
      );
      expect(tester.getSize(masks.at(1)), const Size(120, 80));
      expect(lines.where((l) => l.contains('width/height')), hasLength(1));

      _open('p', const {'icon': 'home'});
      await tester.pumpAndSettle();
    });

    testWidgets('pending 내용과 placeholder 행은 접근성 트리에서 빠지고 공개되면 돌아온다', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        _screen(
          state: {'a': null, 'items': null},
          children: [
            {'_type': 'text', 'value': r'${a}'},
            {
              '_type': 'text',
              'value': 'row label',
              '_loop': {
                '_in': r'${items}',
                '_key': r'${item.id}',
                '_skeleton': 2,
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      expect(find.bySemanticsLabel(RegExp('000000')), findsNothing);
      expect(find.bySemanticsLabel('row label'), findsNothing);

      _open('a', 'ready');
      _open('items', [
        {'id': '0'},
      ]);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('ready'), findsOneWidget);
      expect(find.bySemanticsLabel('row label'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('reduced motion이면 shimmer 없는 정적 bone, 공개는 즉시', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: _build(
                _screen(
                  state: {'a': null},
                  children: [
                    {'_type': 'text', 'value': r'${a}'},
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(_grace);
      final text = find.byType(Text);
      expect(_mask(tester, text), paints..rrect());
      expect(tester.hasRunningAnimations, isFalse);

      _open('a', 'now');
      await tester.pump();
      await tester.pump();
      expect(_mask(tester, find.text('now')), isNot(paints..rrect()));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('서로 다른 노드의 bone은 scope 상자 기준의 같은 shimmer 위상을 쓴다', (
      tester,
    ) async {
      const boundary = ValueKey('boundary');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              key: boundary,
              child: _build(
                _screen(
                  state: {'a': null},
                  children: [
                    {
                      '_type': 'row',
                      '_children': [
                        {
                          '_type': 'text',
                          'value': r'${a}',
                          'style': {'font_size': 20},
                        },
                        {'_type': 'sizedbox', 'width': 300},
                        {
                          '_type': 'text',
                          'value': r'${a}',
                          'style': {'font_size': 20},
                        },
                      ],
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      // Grace, then half a shimmer cycle: the band sits mid-scope.
      await tester.pump(_grace);
      await tester.pump(const Duration(milliseconds: 750));

      final texts = find.byType(Text);
      final left = tester.getRect(texts.at(0)).center;
      final right = tester.getRect(texts.at(1)).center;
      final origin = tester.getTopLeft(find.byKey(boundary));
      final pixels = await tester.runAsync(() async {
        final render =
            tester.renderObject(find.byKey(boundary)) as RenderRepaintBoundary;
        final image = await render.toImage();
        final bytes = await image.toByteData();
        return (image.width, bytes!);
      });
      Color at(Offset global) {
        final p = global - origin;
        final i = (p.dy.round() * pixels!.$1 + p.dx.round()) * 4;
        final b = pixels.$2;
        return Color.fromARGB(
          b.getUint8(i + 3),
          b.getUint8(i),
          b.getUint8(i + 1),
          b.getUint8(i + 2),
        );
      }

      // Mid-cycle the band lights the middle of the scope: the left bone is
      // still base, the right one lit. Bones shaded from their own bounds
      // would both be lit at their centers.
      expect(at(left).r, closeTo(0x2C / 255, 0.01));
      expect(at(right).r - at(left).r, greaterThan(0.05));

      _open('a', 'x');
      await tester.pumpAndSettle();
    });

    testWidgets('이벤트가 있는 leaf는 공개 때 core를 remount하지 않는다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          children: [
            {
              '_type': 'text',
              'value': r'${a}',
              '_on': {'tap': 'go'},
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final before = tester.element(find.byType(RichText));

      _open('a', 'ready');
      await tester.pumpAndSettle();
      final ready = find.text('ready');
      expect(
        find.ancestor(of: ready, matching: find.byType(InteractionWrapper)),
        findsOneWidget,
      );
      expect(identical(tester.element(find.byType(RichText)), before), isTrue);
    });
  });

  group('auto skeleton — repair', () {
    testWidgets('조상 키를 pend한 scope가 정착 전에 dispose되면 그 키를 푼다', (tester) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'partners': null, 'show': true},
          '_action': {'load_partners': _load('p', 'partners')},
        },
        '_children': [
          {'_type': 'text', 'value': 'outer'},
          {
            '_type': 'text',
            'value': 'child',
            '_if': r'${show}',
            '_scope': {
              '_lifecycle': [
                {'on': 'mount', 'action': 'load_partners'},
              ],
              '_skeleton': 'auto',
            },
          },
        ],
      });
      final outer = _envAt(tester, find.text('outer')) as ScopeEnvironment;
      expect(outer.pendingOf('partners'), PendState.pending);

      outer.set('show', false);
      await tester.pump();
      await tester.pump();
      expect(find.text('child'), findsNothing);
      expect(outer.pendingOf('partners'), PendState.settled);

      _open('p', const ['x']);
      await tester.pumpAndSettle();
    });

    testWidgets('조상을 기다리는 scope의 watchdog는 자기 lifecycle 시작부터 잰다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'a': null},
          '_action': {'load': _load('outer', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'text',
            'value': r'${b ?? "seed"}',
            '_scope': {
              '_state': {'b': null},
              '_action': {'load': _load('inner', 'b')},
              '_lifecycle': [
                {'on': 'mount', 'action': 'load'},
              ],
              '_skeleton': 'auto',
            },
          },
        ],
      });
      final inner = _envAt(tester, find.byType(Text));
      await tester.pump(const Duration(seconds: 10));
      _open('outer', 1);
      await tester.pump();
      await tester.pump();
      expect(_calls, ['outer', 'inner']);

      await tester.pump(const Duration(seconds: 6));
      expect(inner.pendingOf('b'), PendState.pending);

      await tester.pump(const Duration(seconds: 9));
      expect(inner.pendingOf('b'), PendState.settled);
      _open('inner');
      await tester.pumpAndSettle();
    });

    testWidgets('조상을 기다리는 scope는 앱 복귀 remount를 mount 전에 발화하지 않는다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'a': null},
          '_action': {'load': _load('outer', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'text',
            'value': 'inner',
            '_scope': {
              '_action': {
                'go': {'_type': 'gate', 'tag': 'inner'},
                'again': {'_type': 'gate', 'tag': 'again'},
              },
              '_lifecycle': [
                {'on': 'mount', 'action': 'go'},
                {'on': 'remount', 'action': 'again'},
              ],
            },
          },
        ],
      });
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(_calls, ['outer']);

      _open('outer', 1);
      await tester.pump();
      await tester.pump();
      expect(_calls, ['outer', 'inner']);
      _open('inner');
      await tester.pumpAndSettle();
    });

    testWidgets('보이지 않는 scope도 mount 시작과 함께 watchdog를 잰다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TickerMode(
              enabled: false,
              child: _build(
                _screen(
                  state: {'a': null},
                  children: [
                    {'_type': 'text', 'value': r'${a ?? "seed"}'},
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final env = _envAt(tester, find.byType(Text));
      expect(_calls, ['a']);
      await tester.pump(const Duration(seconds: 14));
      expect(env.pendingOf('a'), PendState.pending);
      await tester.pump(const Duration(seconds: 1));
      expect(env.pendingOf('a'), PendState.settled);
      _open('a');
      await tester.pumpAndSettle();
    });

    testWidgets('쓰기 추론이 없는 auto mount가 멈춰도 watchdog가 자손을 출발시킨다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_action': {
            'ping': {'_type': 'gate', 'tag': 'outer'},
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'ping'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'text',
            'value': 'inner',
            '_scope': {
              '_action': {
                'go': {'_type': 'gate', 'tag': 'inner'},
              },
              '_lifecycle': [
                {'on': 'mount', 'action': 'go'},
              ],
            },
          },
        ],
      });
      expect(_calls, ['outer']);

      await tester.pump(const Duration(seconds: 15));
      await tester.pump();
      expect(_calls, ['outer', 'inner']);
      _open('outer');
      _open('inner');
      await tester.pumpAndSettle();
    });

    testWidgets('auto scope와 placeholder 행을 내리면 전역 pending 수가 원래대로 돌아온다', (
      tester,
    ) async {
      final base = ScopeEnvironment.pendingKeys;
      await _pump(
        tester,
        _screen(
          state: {'a': null, 'items': null},
          children: [
            {'_type': 'text', 'value': r'${a}'},
            {
              '_type': 'text',
              'value': r'${item.name}',
              '_loop': {
                '_in': r'${items}',
                '_key': r'${item.id}',
                '_skeleton': 3,
              },
            },
          ],
        ),
      );
      expect(find.byType(SkeletonRow), findsNWidgets(3));
      expect(ScopeEnvironment.pendingKeys, greaterThan(base));

      await tester.pumpWidget(const SizedBox());
      expect(ScopeEnvironment.pendingKeys, base);
    });

    testWidgets(
      '이벤트가 있는 비-leaf pending 노드와 parent-data 노드는 공개 때 자손 State를 지킨다',
      (tester) async {
        await _pump(
          tester,
          _screen(
            state: {'a': null, 'b': null},
            extra: {
              'go': {'_type': 'gate', 'tag': 'go'},
            },
            children: [
              {
                '_type': 'sizedbox',
                'width': r'${a}',
                '_on': {'tap': 'go'},
                '_children': [
                  {'_type': 'text', 'value': 'inside'},
                ],
              },
              {
                '_type': 'row',
                '_children': [
                  {
                    '_type': 'expanded',
                    'flex': r'${b}',
                    '_on': {'tap': 'go'},
                    '_children': [
                      {'_type': 'text', 'value': 'flexed'},
                    ],
                  },
                ],
              },
            ],
          ),
        );
        await tester.pump(_grace);
        Element element(String text) => tester.element(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        final inside = element('inside');
        final flexed = element('flexed');

        _open('a', 120);
        _open('b', 2);
        await tester.pumpAndSettle();
        expect(identical(element('inside'), inside), isTrue);
        expect(identical(element('flexed'), flexed), isTrue);
        expect(
          find.ancestor(
            of: find.text('flexed'),
            matching: find.byType(InteractionWrapper),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Scope.didUpdateWidget의 template 재시드(syncState)는 pending을 풀지 않는다',
      (tester) async {
        Map<String, Object?> screen(Object? seed) => _screen(
          state: {'a': seed},
          children: [
            {'_type': 'text', 'value': r'${a}'},
          ],
        );
        await _pump(tester, screen(null));
        final env = _envAt(tester, find.byType(Text));
        expect(env.pendingOf('a'), PendState.pending);

        await _pump(tester, screen('reseeded'));
        await tester.pump(_grace);
        expect(identical(_envAt(tester, find.byType(Text)), env), isTrue);
        expect(env.read('a'), 'reseeded');
        expect(env.pendingOf('a'), PendState.pending);
        expect(_mask(tester, find.byType(Text)), paints..rrect());

        _open('a', 'loaded');
        await tester.pumpAndSettle();
        expect(env.pendingOf('a'), PendState.settled);
        expect(find.text('loaded'), findsOneWidget);
      },
    );

    testWidgets('owner 키를 함께 기다리는 auto scope 둘은 함께 공개된다', (tester) async {
      Map<String, Object?> section(String label) => {
        '_type': 'column',
        '_scope': {
          '_lifecycle': [
            {'on': 'mount', 'action': 'load_partners'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {'_type': 'text', 'value': '$label=\${partners}'},
        ],
      };
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'partners': null},
          '_action': {'load_partners': _load('p', 'partners')},
        },
        '_children': [section('S1'), section('S2')],
      });
      await tester.pump(_grace);
      final s1 = find.textContaining('S1=');
      final s2 = find.textContaining('S2=');
      expect(_mask(tester, s1), paints..rrect());
      expect(_mask(tester, s2), paints..rrect());

      _open('p', 'x');
      await tester.pump();
      await tester.pump();
      expect(find.text('S1=x'), findsOneWidget);
      expect(find.text('S2=x'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(_mask(tester, s1), isNot(paints..rrect()));
      expect(_mask(tester, s2), isNot(paints..rrect()));
    });

    testWidgets('auto scope 밖에서 같은 키를 읽는 노드는 pending으로 그리지 않는다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'partners': null},
          '_action': {'load_partners': _load('p', 'partners')},
        },
        '_children': [
          {'_type': 'text', 'value': r'H=${partners ?? "none"}'},
          {
            '_type': 'column',
            '_scope': {
              '_lifecycle': [
                {'on': 'mount', 'action': 'load_partners'},
              ],
              '_skeleton': 'auto',
            },
            '_children': [
              {'_type': 'text', 'value': r'S=${partners}'},
            ],
          },
        ],
      });
      await tester.pump(_grace);
      final header = find.text('H=none');
      expect(header, findsOneWidget);
      expect(_maskOf(header), findsNothing);
      expect(_maskOf(find.textContaining('S=')), findsOneWidget);
      expect(
        Scope.envOf(tester.element(header))!.pendingOf('partners'),
        PendState.pending,
      );

      _open('p', 'x');
      await tester.pumpAndSettle();
      expect(find.text('H=x'), findsOneWidget);
      expect(find.text('S=x'), findsOneWidget);
    });

    testWidgets('조상 auto scope를 기다리던 scope가 GlobalKey로 밖에 옮겨지면 바로 출발한다', (
      tester,
    ) async {
      final outer =
          TemplateCompiler.buildDirectiveTree(
                TemplateParser.buildUiTree(
                  _screen(state: {'a': null}, children: const []),
                ),
              )
              as ScopeDirective;
      final nested = KeyedSubtree(
        key: GlobalKey(),
        child: _build({
          '_type': 'text',
          'value': 'nested',
          '_scope': {
            '_action': {
              'row': {'_type': 'gate', 'tag': 'row'},
            },
            '_lifecycle': [
              {'on': 'mount', 'action': 'row'},
            ],
          },
        }),
      );
      Widget tree({required bool inside}) => MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Scope(
                config: outer.config,
                actions: outer.actions,
                lifecycle: outer.lifecycle,
                autoSkeleton: true,
                child: inside ? nested : const SizedBox(),
              ),
              if (!inside) nested,
            ],
          ),
        ),
      );

      await tester.pumpWidget(tree(inside: true));
      expect(_calls, ['a']);

      await tester.pumpWidget(tree(inside: false));
      expect(find.text('nested'), findsOneWidget);
      expect(_calls, ['a', 'row']);

      _open('a', 'x');
      _open('row');
      await tester.pumpAndSettle();
      expect(_calls, ['a', 'row']);
    });

    testWidgets('lifecycle 없이 생긴 placeholder 행 scope는 나중에 훅을 받아도 발화하지 않는다', (
      tester,
    ) async {
      Map<String, Object?> template({required bool hooks}) => _screen(
        state: {'items': null},
        children: [
          {
            '_type': 'text',
            'value': r'${item.name}',
            '_loop': {
              '_in': r'${items}',
              '_key': r'${item.id}',
              '_skeleton': 2,
            },
            '_scope': {
              '_action': {
                'row': {'_type': 'gate', 'tag': 'row'},
              },
              if (hooks)
                '_lifecycle': [
                  {'on': 'mount', 'action': 'row'},
                ],
            },
          },
        ],
      );

      await _pump(tester, template(hooks: false));
      expect(find.byType(SkeletonMask), findsNWidgets(2));
      await _pump(tester, template(hooks: true));
      await tester.pump();
      expect(find.byType(SkeletonMask), findsNWidgets(2));
      expect(_calls, isNot(contains('row')));
      _open('items', const <Object?>[]);
      await tester.pumpAndSettle();
    });
  });

  group('auto skeleton — stability', () {
    testWidgets('motion 인자·payload만 기다리는 노드는 motion을 잃지 않고 오류 없이 그려진다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'ms': null, 'p': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          children: [
            {
              '_type': 'text',
              'value': 'moving',
              '_motion': {'type': 'fade_in', 'duration': r'${ms * 1}'},
            },
            {
              '_type': 'text',
              'value': 'tapper',
              '_on': {
                'tap': {'do': 'go', 'event': r'${p * 2}'},
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      expect(tester.takeException(), isNull);
      expect(find.text('moving'), findsOneWidget);
      expect(find.text('tapper'), findsOneWidget);
      await tester.tap(find.text('tapper'), warnIfMissed: false);
      await tester.pump();
      expect(_calls, isNot(contains('go')));
      Element core() => tester.element(
        find.descendant(
          of: find.text('moving'),
          matching: find.byType(RichText),
        ),
      );
      final moving = core();

      _open('ms', 200);
      _open('p', 3);
      await tester.pumpAndSettle();
      expect(identical(core(), moving), isTrue);
      expect(
        find.ancestor(
          of: find.text('moving'),
          matching: find.byType(MotionWrapper),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('tapper'));
      await tester.pump();
      expect(_calls.where((c) => c == 'go'), hasLength(1));
      _open('go');
      await tester.pumpAndSettle();
    });

    /// A card under its own automatic skeleton: a label over a column loop
    /// of 50-high rows (a fixed [count], or none).
    Map<String, Object?> card(int i, {int? count}) => _screen(
      state: {'items': null},
      children: [
        {'_type': 'text', 'value': 'card$i'},
        {
          '_type': 'container',
          'height': 50,
          '_loop': {
            '_in': r'${items}',
            '_key': r'${item.id}',
            '_skeleton': ?count,
          },
          '_children': [
            {'_type': 'text', 'value': r'${item.name}'},
          ],
        },
      ],
    );

    testWidgets('바깥 피드 안 카드의 auto 루프는 피드 viewport를 채우지 않는다', (tester) async {
      await _pump(tester, {
        '_type': 'sizedbox',
        'height': 600,
        '_child': {
          '_type': 'single_child_scroll_view',
          '_child': {
            '_type': 'column',
            '_children': [for (var i = 0; i < 5; i++) card(i)],
          },
        },
      });
      await tester.pump();
      int visible() => [
        for (var i = 0; i < 5; i++)
          if (tester.getRect(find.text('card$i')).top < 600) i,
      ].length;
      final loading = visible();

      _open('items', const [
        {'id': '0', 'name': 'n0'},
      ]);
      await tester.pumpAndSettle();
      expect(find.text('n0'), findsNWidgets(5));
      expect(loading, visible());
    });

    testWidgets('일반 피드의 end_reached는 카드 안 placeholder 행에 막히지 않는다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'sizedbox',
        'height': 400,
        '_scope': {
          '_action': {
            'more': {'_type': 'gate', 'tag': 'more'},
          },
        },
        '_on': {'end_reached': 'more'},
        '_child': {
          '_type': 'single_child_scroll_view',
          '_child': {
            '_type': 'column',
            '_children': [for (var i = 0; i < 6; i++) card(i, count: 2)],
          },
        },
      });
      expect(find.byType(SkeletonRow), findsNWidgets(12));
      final feed = tester.state<ScrollableState>(find.byType(Scrollable));
      feed.position.jumpTo(feed.position.maxScrollExtent);
      await tester.pump();
      expect(_calls, contains('more'));
      _open('more');
      _open('items', const <Object?>[]);
      await tester.pumpAndSettle();
    });

    testWidgets(
      '_skeleton 없는 lazy list는 공개 때 스크롤 위치를 지키고 밀린 end_reached를 한 번 보낸다',
      (tester) async {
        await _pump(
          tester,
          _screen(
            state: {'items': null},
            extra: {
              'more': {'_type': 'gate', 'tag': 'more'},
            },
            children: [
              {
                '_type': 'sizedbox',
                'height': 420,
                '_on': {'end_reached': 'more'},
                '_children': [
                  {
                    '_type': 'container',
                    'height': 50,
                    '_loop': {
                      '_in': r'${items}',
                      '_key': r'${item.id}',
                      '_wrap': 'list',
                    },
                    '_children': [
                      {'_type': 'text', 'value': r'${item.name}'},
                    ],
                  },
                ],
              },
            ],
          ),
        );
        await tester.pump();
        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );
        scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
        await tester.pump();
        final offset = scrollable.position.pixels;
        expect(offset, greaterThan(0));
        expect(_calls, isNot(contains('more')));

        _open('items', [
          for (var i = 0; i < 9; i++) {'id': '$i', 'name': 'n$i'},
        ]);
        await tester.pumpAndSettle();
        expect(
          identical(tester.state(find.byType(Scrollable)), scrollable),
          isTrue,
        );
        expect(scrollable.position.pixels, offset);
        expect(_calls.where((c) => c == 'more'), hasLength(1));
        _open('more');
        await tester.pumpAndSettle();
        expect(_calls.where((c) => c == 'more'), hasLength(1));
      },
    );

    testWidgets(
      '공개를 마친 auto scope의 노드는 나중에 생긴 auto scope의 pend로 bone이 되지 않는다',
      (tester) async {
        await _pump(tester, {
          '_type': 'column',
          '_scope': {
            '_state': {'b': 'seed', 'show': false},
            '_action': {'load_b': _load('b', 'b')},
          },
          '_children': [
            _screen(
              state: {'a': null},
              children: [
                {'_type': 'text', 'value': r'A=${a}'},
                {'_type': 'text', 'value': r'B=${b}'},
              ],
            ),
            {
              '_type': 'text',
              '_if': r'${show}',
              'value': r'late=${b}',
              '_scope': {
                '_lifecycle': [
                  {'on': 'mount', 'action': 'load_b'},
                ],
                '_skeleton': 'auto',
              },
            },
          ],
        });
        _open('a', 'x');
        await tester.pumpAndSettle();
        Element core() => tester.element(
          find.descendant(
            of: find.text('B=seed'),
            matching: find.byType(RichText),
          ),
        );
        final shown = core();

        tester.state<ScopeState>(find.byType(Scope).first).set('show', true);
        await tester.pump();
        await tester.pump(_grace);
        expect(_calls, contains('b'));
        expect(find.text('B=seed'), findsOneWidget);
        expect(identical(core(), shown), isTrue);
        expect(_maskOf(find.text('B=seed')), findsNothing);
        expect(_mask(tester, find.textContaining('late=')), paints..rrect());

        _open('b', 'y');
        await tester.pumpAndSettle();
        expect(find.text('B=y'), findsOneWidget);
        expect(find.text('late=y'), findsOneWidget);
      },
    );
  });

  group('auto skeleton — characterization', () {
    /// The engine layers between the core widget found by [core] and the
    /// node's [PlainObserver], innermost first.
    List<String> layers(WidgetTester tester, Finder core) {
      final names = <String>[];
      tester.element(core).visitAncestorElements((element) {
        final widget = element.widget;
        if (widget is PlainObserver) return false;
        final name = switch (widget) {
          IgnorePointer() => 'IgnorePointer',
          SkeletonMask() => 'SkeletonMask',
          InteractionWrapper() => 'InteractionWrapper',
          ScrollEventWrapper() => 'ScrollEventWrapper',
          MotionWrapper() => 'MotionWrapper',
          RepaintBoundary() => 'RepaintBoundary',
          KeyedSubtree(key: GlobalKey()) => 'CoreKey',
          _ => null,
        };
        if (name != null) names.add(name);
        return true;
      });
      return names;
    }

    testWidgets(
      'held tap(debounce)는 action_intent 없이 무시되고 공개 뒤 실제 payload로 한 번',
      (tester) async {
        final sink = _TelemetrySink();
        Telemetry.install(sink);
        addTearDown(Telemetry.reset);
        await _pump(
          tester,
          _screen(
            state: {'a': null},
            extra: {
              'go': {'_type': 'gate', 'tag': r'go:${event}'},
            },
            children: [
              {
                '_type': 'text',
                'value': 'tapper',
                '_on': {
                  'tap': {'do': 'go', 'event': r'${a}', 'debounce': 100},
                },
              },
            ],
          ),
        );
        await tester.pump(_grace);
        await tester.tap(find.text('tapper'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(seconds: 4));
        expect(_calls.where((c) => c.startsWith('go')), isEmpty);
        expect(sink.events.where((e) => e.event == 'action_intent'), isEmpty);

        _open('a', 'real');
        await tester.pumpAndSettle();
        await tester.tap(find.text('tapper'));
        await tester.pump(const Duration(milliseconds: 200));
        expect(_calls.where((c) => c.startsWith('go')), ['go:real']);
        expect(
          sink.events.where(
            (e) =>
                e.event == 'action_intent' && e.properties['accepted'] == true,
          ),
          hasLength(1),
        );
        _open('go:real');
        await tester.pumpAndSettle();
      },
    );

    testWidgets('held 노드의 pressed_as는 누르는 동안에도 false, 공개 뒤엔 true', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          children: [
            {
              '_type': 'container',
              'width': 120,
              'height': 60,
              '_on': {
                'tap': {'do': 'go', 'event': r'${a}', 'pressed_as': 'down'},
              },
              '_child': {'_type': 'text', 'value': r'${down ? "D" : "U"}'},
            },
          ],
        ),
      );
      await tester.pump(_grace);
      var gesture = await tester.startGesture(tester.getCenter(find.text('U')));
      await tester.pump();
      expect(find.text('U'), findsOneWidget);
      await gesture.up();
      await tester.pump();

      _open('a', 'x');
      await tester.pumpAndSettle();
      gesture = await tester.startGesture(tester.getCenter(find.text('U')));
      await tester.pump();
      expect(find.text('D'), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
      _open('go');
      await tester.pumpAndSettle();
    });

    testWidgets('payload만 기다리는 end_reached는 끝에 머문 채 공개되면 다음 스크롤 알림에 한 번', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'more': {'_type': 'gate', 'tag': 'more'},
          },
          children: [
            {
              '_type': 'sizedbox',
              'height': 300,
              '_on': {
                'end_reached': {'do': 'more', 'event': r'${a}'},
              },
              '_child': {
                '_type': 'list_view',
                '_children': [
                  for (var i = 0; i < 20; i++)
                    {'_type': 'sizedbox', 'height': 100},
                ],
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pump();
      expect(_calls, isNot(contains('more')));

      _open('a', 'x');
      await tester.pumpAndSettle();
      expect(_calls, isNot(contains('more')));
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent - 1);
      await tester.pump();
      expect(_calls.where((c) => c == 'more'), hasLength(1));
      _open('more');
      await tester.pumpAndSettle();
    });

    testWidgets(
      'tap·motion·scroll·isolate가 있는 held·pending leaf의 layer 순서와 core 유지',
      (tester) async {
        Map<String, Object?> leaf(String value, String tag) => {
          '_type': 'text',
          'value': value,
          '_morph': {'_from': 0, '_to': 1, '_as': 'm$tag', '_repeat': true},
          '_motion': 'fade_in',
          '_on': {
            'tap': {'do': 'go', 'event': r'${a}'},
            'end_reached': 'go',
          },
        };
        await _pump(
          tester,
          _screen(
            state: {'a': null},
            extra: {
              'go': {'_type': 'gate', 'tag': 'go'},
            },
            children: [leaf('held', 'h'), leaf(r'p${a}', 'p')],
          ),
        );
        await tester.pump(_grace);
        final held = find.descendant(
          of: find.text('held'),
          matching: find.byType(RichText),
        );
        final pending = find.byType(RichText).last;
        expect(layers(tester, held), [
          'CoreKey',
          'InteractionWrapper',
          'ScrollEventWrapper',
          'RepaintBoundary',
          'IgnorePointer',
        ]);
        expect(layers(tester, pending), [
          'CoreKey',
          'SkeletonMask',
          'IgnorePointer',
        ]);
        final heldCore = tester.element(held);
        final pendingCore = tester.element(pending);

        _open('a', 'x');
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        const revealed = [
          'CoreKey',
          'MotionWrapper',
          'InteractionWrapper',
          'ScrollEventWrapper',
          'RepaintBoundary',
        ];
        expect(layers(tester, held), [...revealed, 'IgnorePointer']);
        expect(layers(tester, find.byType(RichText).last), [
          ...revealed,
          'SkeletonMask',
          'IgnorePointer',
        ]);
        expect(identical(tester.element(held), heldCore), isTrue);
        expect(
          identical(tester.element(find.byType(RichText).last), pendingCore),
          isTrue,
        );
      },
    );

    testWidgets('expanded·positioned 노드는 공개 때 자식 core를 remount하지 않는다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          children: [
            {
              '_type': 'row',
              '_children': [
                {
                  '_type': 'expanded',
                  'flex': r'${a}',
                  '_on': {'tap': 'go'},
                  '_child': {'_type': 'text', 'value': 'in-expanded'},
                },
              ],
            },
            {
              '_type': 'sizedbox',
              'height': 100,
              'width': 200,
              '_child': {
                '_type': 'stack',
                '_children': [
                  {
                    '_type': 'positioned',
                    'left': r'${a}',
                    '_on': {'tap': 'go'},
                    '_child': {'_type': 'text', 'value': 'in-positioned'},
                  },
                ],
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      Element core(String text) => tester.element(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      );
      final expanded = core('in-expanded');
      final positioned = core('in-positioned');

      _open('a', 1);
      await tester.pumpAndSettle();
      expect(identical(core('in-expanded'), expanded), isTrue);
      expect(identical(core('in-positioned'), positioned), isTrue);
      expect(
        find.ancestor(
          of: find.text('in-expanded'),
          matching: find.byType(InteractionWrapper),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('in-positioned'));
      await tester.pump();
      expect(_calls, contains('go'));
      _open('go');
      await tester.pumpAndSettle();
    });

    testWidgets('_key 루프 행의 pending 노드는 공개 때 같은 element를 쓴다', (tester) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {
            'a': null,
            'items': [
              {'id': 'r1'},
              {'id': 'r2'},
            ],
          },
          '_action': {'load_a': _load('a', 'a')},
          '_lifecycle': [
            {'on': 'mount', 'action': 'load_a'},
          ],
          '_skeleton': 'auto',
        },
        '_children': [
          {
            '_type': 'text',
            '_loop': {'_in': r'${items}', '_key': r'${item.id}'},
            'value': r'${item.id}:${a}',
          },
        ],
      });
      await tester.pump(_grace);
      final rows = [for (final e in find.byType(RichText).evaluate()) e];
      expect(rows, hasLength(2));

      _open('a', 'x');
      await tester.pumpAndSettle();
      expect(find.text('r1:x'), findsOneWidget);
      final after = [for (final e in find.byType(RichText).evaluate()) e];
      expect(identical(after[0], rows[0]), isTrue);
      expect(identical(after[1], rows[1]), isTrue);
    });

    testWidgets('pending leaf는 공개 뒤와 같은 크기로 배치된다', (tester) async {
      await _pump(
        tester,
        _screen(
          state: {'p': null},
          children: [
            {'_type': 'text', 'value': r'${p.text}', 'width': 100},
            {'_type': 'icon', 'name': r'${p.icon}', 'size': 32},
            {'_type': 'checkbox', 'active_color': r'${p.color}'},
            {
              '_type': 'sizedbox',
              'width': 200,
              '_child': {'_type': 'slider', 'max': r'${p.max}'},
            },
            {
              '_type': 'sizedbox',
              'width': 200,
              '_child': {'_type': 'text_field', 'hint': r'${p.hint}'},
            },
          ],
        ),
      );
      await tester.pump(_grace);
      final masks = find.byType(SkeletonMask);
      expect(masks, findsNWidgets(5));
      final pending = [for (var i = 0; i < 5; i++) tester.getSize(masks.at(i))];

      _open('p', const {
        'text': 'hello',
        'icon': 'home',
        'color': '#FF0000',
        'max': 10,
        'hint': 'type',
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final revealed = [
        for (var i = 0; i < 5; i++) tester.getSize(masks.at(i)),
      ];
      expect(revealed[0].height, pending[0].height);
      expect(revealed.skip(1), pending.skip(1));
    });

    testWidgets('auto가 아닌 화면은 skeleton layer 없이 lifecycle·이벤트를 한 번씩 낸다', (
      tester,
    ) async {
      await _pump(tester, {
        '_type': 'column',
        '_scope': {
          '_state': {'a': null},
          '_action': {
            'first': {'_type': 'gate', 'tag': 'first'},
            'second': {'_type': 'gate', 'tag': 'second'},
            'go': {'_type': 'gate', 'tag': 'go'},
          },
          '_lifecycle': [
            {'on': 'mount', 'action': 'first'},
            {'on': 'mount', 'action': 'second'},
          ],
        },
        '_children': [
          {
            '_type': 'text',
            'value': r'v${a}',
            '_motion': 'fade_in',
            '_on': {
              'tap': {'do': 'go', 'event': r'${a}'},
            },
          },
        ],
      });
      await tester.pumpAndSettle();
      expect(_calls, ['first', 'second']);
      expect(find.byType(SkeletonMask), findsNothing);
      expect(find.byType(SkeletonClock), findsNothing);
      expect(layers(tester, find.byType(RichText)), [
        'MotionWrapper',
        'InteractionWrapper',
      ]);
      final scopes = find.byType(Scope).evaluate().length;
      expect(
        find
            .byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_ActionLayer',
            )
            .evaluate()
            .length,
        scopes,
      );
      await tester.tap(find.byType(RichText));
      await tester.pump();
      expect(_calls.where((c) => c == 'go'), hasLength(1));
      _open('first');
      _open('second');
      _open('go');
      await tester.pumpAndSettle();
    });

    testWidgets('pending scope에서도 interval 훅은 돌고 앱 복귀 remount는 발화한다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'tick': {'_type': 'gate', 'tag': 'tick'},
            'back': {'_type': 'gate', 'tag': 'back'},
          },
          lifecycle: [
            {'on': 'interval', 'every': 100, 'action': 'tick'},
            {'on': 'remount', 'action': 'back'},
          ],
          children: [
            {'_type': 'text', 'value': r'${a}'},
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(_calls.where((c) => c == 'tick'), isNotEmpty);
      expect(find.byType(SkeletonMask), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(_calls, contains('back'));
      _open('a', 'x');
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('auto skeleton — slivers and self-acting widgets', () {
    testWidgets('pending sliver leaf는 sliver로 남아 오류 없이 그려지고 공개된다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {
              '_type': 'sizedbox',
              'height': 300,
              '_child': {
                '_type': 'custom_scroll_view',
                '_children': [
                  {
                    '_type': 'sliver_fill_remaining',
                    'has_scroll_body': r'${a}',
                  },
                ],
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      expect(tester.takeException(), isNull);
      expect(find.byType(SliverIgnorePointer), findsOneWidget);
      expect(find.byType(SkeletonMask), findsNothing);
      final sliver = tester.element(find.byType(SliverFillRemaining));

      _open('a', false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        identical(tester.element(find.byType(SliverFillRemaining)), sliver),
        isTrue,
      );
    });

    testWidgets('box form으로 등록한 sliver spec은 pending 동안 실제로 빌드되어 오류가 없다', (
      tester,
    ) async {
      WidgetFactory.register(
        'custom_sliver',
        EagerSpec(
          (context, props, children) => SliverToBoxAdapter(
            child: SizedBox(height: 40, child: Text('${props['label']}')),
          ),
          produces: LayoutProtocol.sliver,
          skeleton: SkeletonForm.box,
        ),
      );
      addTearDown(WidgetFactory.reset);
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {
              '_type': 'sizedbox',
              'height': 300,
              '_child': {
                '_type': 'custom_scroll_view',
                '_children': [
                  {'_type': 'custom_sliver', 'label': r'${a}'},
                ],
              },
            },
          ],
        ),
      );
      await tester.pump(_grace);
      expect(tester.takeException(), isNull);
      final sliver = tester.element(find.byType(SliverToBoxAdapter));

      _open('a', 'ok');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('ok'), findsOneWidget);
      expect(
        identical(tester.element(find.byType(SliverToBoxAdapter)), sliver),
        isTrue,
      );
    });

    /// [node] under an automatic skeleton whose `a` is still pending, with
    /// an `act` action recording its dispatch.
    Future<void> pumpEffectful(
      WidgetTester tester,
      Map<String, Object?> node,
    ) => _pump(
      tester,
      _screen(
        state: {'a': null},
        extra: {
          'act': {'_type': 'gate', 'tag': 'act'},
        },
        children: [
          {'_type': 'sizedbox', 'width': 300, 'height': 300, '_child': node},
        ],
      ),
    );

    testWidgets('pending dismissible은 밀리지 않고, 공개 뒤엔 밀면 on_dismissed를 보낸다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'dismissible',
        'direction': r'${a}',
        'on_dismissed': 'act',
        '_child': {'_type': 'text', 'value': 'swipe me'},
      });
      await tester.pump(_grace);
      final core = tester.element(find.byType(Dismissible));
      await tester.drag(
        find.text('swipe me'),
        const Offset(500, 0),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(_calls, isNot(contains('act')));
      expect(tester.takeException(), isNull);

      _open('a', 'horizontal');
      await tester.pumpAndSettle();
      expect(identical(tester.element(find.byType(Dismissible)), core), isTrue);
      await tester.drag(find.text('swipe me'), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(_calls, contains('act'));
      // Nothing removes the dismissed widget here, which Dismissible asserts on.
      tester.takeException();
    });

    testWidgets('pending page_view는 넘어가지 않고, 공개 뒤엔 on_page_changed를 보낸다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'page_view',
        'viewport_fraction': r'${a}',
        'on_page_changed': 'act',
        '_children': [
          {'_type': 'text', 'value': 'page0'},
          {'_type': 'text', 'value': 'page1'},
        ],
      });
      await tester.pump(_grace);
      await tester.fling(
        find.text('page0'),
        const Offset(-300, 0),
        1000,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(_calls, isNot(contains('act')));

      _open('a', 1.0);
      await tester.pumpAndSettle();
      await tester.fling(find.text('page0'), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(_calls, contains('act'));
      _open('act');
      await tester.pumpAndSettle();
    });

    testWidgets('pending refresh_indicator는 당겨지지 않고, 공개 뒤엔 on_refresh를 보낸다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'refresh_indicator',
        'color': r'${a}',
        'on_refresh': 'act',
        '_child': {
          '_type': 'list_view',
          '_children': [
            {'_type': 'text', 'value': 'pull'},
          ],
        },
      });
      await tester.pump(_grace);
      await tester.fling(
        find.text('pull'),
        const Offset(0, 300),
        1000,
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(_calls, isNot(contains('act')));
      await tester.pumpAndSettle();

      _open('a', '#FF0000');
      await tester.pumpAndSettle();
      await tester.fling(find.text('pull'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(_calls, contains('act'));
      _open('act');
      await tester.pumpAndSettle();
    });

    testWidgets('pending text_field는 focus를 받지 않고, 공개 뒤엔 입력이 change를 보낸다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'text_field',
        'hint': r'${a}',
        '_on': {'change': 'act'},
      });
      await tester.pump(_grace);
      final core = tester.element(find.byType(EditableText));
      await tester.showKeyboard(find.byType(EditableText));
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isFalse);
      expect(_calls, isNot(contains('act')));

      _open('a', 'hint');
      await tester.pumpAndSettle();
      expect(
        identical(tester.element(find.byType(EditableText)), core),
        isTrue,
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isTrue);
      await tester.enterText(find.byType(EditableText), 'hi');
      await tester.pump();
      expect(_calls, contains('act'));
      _open('act');
      await tester.pumpAndSettle();
    });

    testWidgets('pending autofocus text_field는 focus를 받지 않고, 공개 뒤에 받는다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'text_field',
        'autofocus': true,
        'hint': r'${a}',
      });
      await tester.pump(_grace);
      EditableTextState field() =>
          tester.state<EditableTextState>(find.byType(EditableText));
      final core = field();
      expect(core.widget.focusNode.hasFocus, isFalse);

      _open('a', 'hint');
      await tester.pumpAndSettle();
      expect(identical(field(), core), isTrue);
      expect(field().widget.focusNode.hasFocus, isTrue);
    });

    testWidgets('pending video는 player를 띄우지 않고 box로, 공개 뒤에 player를 띄운다', (
      tester,
    ) async {
      Finder player() => find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_VideoView',
      );
      await pumpEffectful(tester, {
        '_type': 'video',
        'src': 'clip.mp4',
        'muted': r'${a}',
      });
      await tester.pump(_grace);
      expect(player(), findsNothing);
      // Like the real player before its first frame, an unsized box.
      expect(tester.getSize(find.byType(SkeletonMask)), const Size(300, 300));

      _open('a', true);
      await tester.pumpAndSettle();
      expect(player(), findsOneWidget);
    });
  });

  group('auto skeleton — default safety', () {
    testWidgets('held 노드의 decoration 층은 action host를 못 보고, 자식과 공개 뒤엔 본다', (
      tester,
    ) async {
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          extra: {
            'go': {'_type': 'gate', 'tag': 'go'},
            'inner': {'_type': 'gate', 'tag': 'inner'},
          },
          children: [
            {
              '_type': 'container',
              'width': 200,
              'height': 100,
              '_on': {
                'tap': {'do': 'go', 'event': r'${a}'},
              },
              '_children': [
                {
                  '_type': 'text',
                  'value': 'inner',
                  '_on': {'tap': 'inner'},
                },
              ],
            },
          ],
        ),
      );
      await tester.pump(_grace);
      // Where a new event layer of the container would resolve its sink.
      Element decoration() => tester.element(
        find.byWidgetPredicate(
          (w) => w is InteractionWrapper && w.on['tap'] == 'go',
        ),
      );
      final child = tester.element(find.byType(RichText));
      expect(Scope.actionHost(decoration()), isNull);
      expect(Scope.actionHost(child), isNotNull);
      await tester.tap(find.text('inner'));
      await tester.pump();
      expect(_calls, contains('inner'));

      _open('a', 'x');
      _open('inner');
      await tester.pumpAndSettle();
      expect(Scope.actionHost(decoration()), same(Scope.actionHost(child)));
      expect(identical(tester.element(find.byType(RichText)), child), isTrue);
    });

    testWidgets('stand-in으로 그린 pending icon·image는 읽지 않은 prop 경고를 내지 않는다', (
      tester,
    ) async {
      final lines = <String>[];
      EngineLog.configure(output: lines.add);
      addTearDown(() => EngineLog.configure(output: debugPrint));
      await _pump(
        tester,
        _screen(
          state: {'p': null},
          children: [
            {'_type': 'icon', 'name': r'${p.icon}', 'size': 32},
            {
              '_type': 'image',
              'src': r'${p.image}',
              'width': 120,
              'height': 80,
            },
          ],
        ),
      );
      await tester.pump(_grace);
      expect(find.byType(SkeletonMask), findsNWidgets(2));
      expect(lines.where((l) => l.contains('ignored prop')), isEmpty);
      _open('p', const {'icon': 'home'});
      await tester.pumpAndSettle();
    });

    testWidgets('form 없이 등록한 leaf spec은 실제로 빌드되어 bone 아래서 입력을 받지 않는다', (
      tester,
    ) async {
      final taps = <Object?>[];
      WidgetFactory.register(
        'custom_leaf',
        EagerSpec(
          (context, props, children) => GestureDetector(
            onTap: () => taps.add(props['label']),
            child: SizedBox(
              width: 80,
              height: 40,
              child: Text('${props['label']}'),
            ),
          ),
        ),
      );
      addTearDown(WidgetFactory.reset);
      await _pump(
        tester,
        _screen(
          state: {'a': null},
          children: [
            {'_type': 'custom_leaf', 'label': r'${a.name}'},
          ],
        ),
      );
      await tester.pump(_grace);
      expect(tester.takeException(), isNull);
      expect(find.text('null'), findsOneWidget);
      expect(tester.getSize(_maskOf(find.text('null'))), const Size(80, 40));
      final core = tester.element(find.byType(GestureDetector).last);
      await tester.tap(find.text('null'), warnIfMissed: false);
      expect(taps, isEmpty);

      _open('a', const {'name': 'ok'});
      await tester.pumpAndSettle();
      expect(
        identical(tester.element(find.byType(GestureDetector).last), core),
        isTrue,
      );
      await tester.tap(find.text('ok'));
      expect(taps, ['ok']);
    });
  });

  group('auto skeleton — self-started dispatch', () {
    /// [node] under an automatic skeleton whose `a` is still pending, with
    /// an `act` action recording its dispatch.
    Future<void> pumpEffectful(
      WidgetTester tester,
      Map<String, Object?> node,
    ) => _pump(
      tester,
      _screen(
        state: {'a': null},
        extra: {
          'act': {'_type': 'gate', 'tag': 'act'},
        },
        children: [
          {'_type': 'sizedbox', 'width': 300, 'height': 300, '_child': node},
        ],
      ),
    );

    Finder byTypeName(String name) =>
        find.byWidgetPredicate((w) => w.runtimeType.toString() == name);

    testWidgets(
      'pending swipe_layout autoplay는 on_changed를 보내지 않고, 공개 뒤엔 보낸다',
      (tester) async {
        await pumpEffectful(tester, {
          '_type': 'swipe_layout',
          'id': r'${a}',
          'length': 3,
          'autoplay_interval': 100,
          'on_changed': 'act',
          '_child': {'_type': 'text', 'value': 'page'},
        });
        await tester.pump(_grace);
        await tester.pump(const Duration(milliseconds: 250));
        expect(_calls, isNot(contains('act')));
        final core = tester.element(byTypeName('_SwipeLayout'));

        _open('a', 'swipe');
        await tester.pump();
        await tester.pump(_fade);
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          identical(tester.element(byTypeName('_SwipeLayout')), core),
          isTrue,
        );
        expect(_calls, contains('act'));
        _open('act');
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('pending spin_grid는 시작한 회전이 끝나도 on_finish를 보내지 않는다', (
      tester,
    ) async {
      await pumpEffectful(tester, {
        '_type': 'spin_grid',
        'winner_index': 0,
        'trigger': 'draw',
        'duration': 100,
        'steps': r'${a}',
        'on_finish': 'act',
        '_children': [
          {'_type': 'text', 'value': 'p0'},
          {'_type': 'text', 'value': 'p1'},
        ],
      });
      await tester.pump(_grace);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_calls, isNot(contains('act')));
      final core = tester.element(byTypeName('_SpinGrid'));

      _open('a', 5);
      await tester.pumpAndSettle();
      expect(identical(tester.element(byTypeName('_SpinGrid')), core), isTrue);
    });

    testWidgets(
      '등록한 ActionSpec이 Timer로 보내는 dispatch는 pending 동안 막히고 공개 뒤엔 간다',
      (tester) async {
        WidgetFactory.register(
          'custom_ticker',
          ActionSpec(
            (context, props, children, dispatch) => _Ticker(dispatch: dispatch),
          ),
        );
        addTearDown(WidgetFactory.reset);
        await pumpEffectful(tester, {
          '_type': 'custom_ticker',
          'label': r'${a}',
        });
        await tester.pump(_grace);
        await tester.pump(const Duration(milliseconds: 250));
        expect(_calls, isNot(contains('act')));
        final core = tester.element(find.byType(_Ticker));

        _open('a', 'x');
        await tester.pump();
        await tester.pump(_fade);
        await tester.pump(const Duration(milliseconds: 250));
        expect(identical(tester.element(find.byType(_Ticker)), core), isTrue);
        expect(_calls, contains('act'));
        _open('act');
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'pending 소스 위 loop swipe wrap은 placeholder 행에서 on_changed를 보내지 않는다',
      (tester) async {
        await pumpEffectful(tester, {
          '_type': 'text',
          'value': r'${item.name}',
          '_loop': {
            '_in': r'${a}',
            '_key': r'${item.id}',
            '_skeleton': 3,
            '_wrap': {
              '_type': 'swipe',
              'autoplay_interval': 100,
              'on_changed': 'act',
            },
          },
        });
        await tester.pump(_grace);
        await tester.pump(const Duration(milliseconds: 250));
        expect(_calls, isNot(contains('act')));
        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}

/// A self-acting widget that dispatches `act` on a timer, reading its sink
/// when the timer fires.
class _Ticker extends StatefulWidget {
  const _Ticker({required this.dispatch});

  final ActionSink? dispatch;

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => widget.dispatch?.handle('act'),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 40, height: 40);
}
