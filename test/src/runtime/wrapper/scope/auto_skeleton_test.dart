import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/environment/_base.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

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
    ],
    '_skeleton': 'auto',
  },
  '_children': children,
};

Finder _maskOf(Finder finder) =>
    find.ancestor(of: finder, matching: find.byType(SkeletonMask));

RenderObject _mask(WidgetTester tester, Finder finder) =>
    tester.renderObject(_maskOf(finder).first);

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
      expect(env.pendingOf('b'), PendState.pending);
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

    testWidgets('pending 노드는 tap·motion을 걸지 않고, payload만 읽는 노드는 pending 아님', (
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

      _open('a', 'ready');
      await tester.pumpAndSettle();
      final ready = find.text('ready');
      expect(
        find.ancestor(of: ready, matching: find.byType(MotionWrapper)),
        findsOneWidget,
      );
      await tester.tap(ready);
      await tester.pump();
      expect(_calls, contains('go'));
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

    testWidgets('스크롤 안의 eager 루프도 viewport 높이만큼 행을 그린다', (tester) async {
      await _pump(tester, {
        '_type': 'sizedbox',
        'height': 420,
        '_child': {
          '_type': 'single_child_scroll_view',
          '_child': _screen(state: {'items': null}, children: [rows('column')]),
        },
      });
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
  });
}
