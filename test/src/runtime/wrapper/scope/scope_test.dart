import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';

/// 매 plan 호출의 `speed` 인자를 기록하는 테스트 motion — 상태 변경이 인자 재해석을 유발하는지 관찰.
///
/// plan은 `MotionWrapper`의 initState·didUpdateWidget마다 불린다. PlainObserver가 `_motion`
/// 인자를 구독해 상태 변경 시 재-assemble → 새 params가 didUpdateWidget으로 plan에 도달한다.
class _RecordMotion extends Motion {
  _RecordMotion(this.speeds);

  final List<Object?> speeds;

  @override
  String get type => 'record';

  @override
  MotionPlan plan(MotionParams params) {
    speeds.add(params.raw('speed'));
    return const MotionPlan(duration: Duration.zero);
  }

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) =>
      child;
}

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

void main() {
  group('Scope', () {
    testWidgets('a compiled skeleton scope installs a SkeletonScope boundary', (
      tester,
    ) async {
      await _pump(
        tester,
        _content(const {
          '_type': 'text',
          'value': 'content',
          '_scope': {
            '_state': {'ready': false},
            '_action': {
              'load': {'_type': 'set', 'ready': true},
            },
            '_lifecycle': [
              {'on': 'mount', 'action': 'load'},
            ],
            '_skeleton': {'_type': 'text', 'value': 'loading'},
          },
        }),
      );

      expect(find.byType(SkeletonScope), findsOneWidget);
    });

    testWidgets('a scope without a skeleton keeps its direct child', (
      tester,
    ) async {
      await _pump(
        tester,
        _content(const {
          '_type': 'text',
          'value': 'content',
          '_scope': {
            '_state': {'ready': false},
            '_action': {
              'load': {'_type': 'set', 'ready': true},
            },
            '_lifecycle': [
              {'on': 'mount', 'action': 'load'},
            ],
          },
        }),
      );

      expect(find.byType(SkeletonScope), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('상태가 바뀌면 바인딩된 노드만 갱신된다', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'count': 1},
          key: key,
          child: _content(const {
            '_type': 'column',
            '_children': [
              {'_type': 'text', 'value': r'${count}'},
              {'_type': 'text', 'value': 'static'},
            ],
          }),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('static'), findsOneWidget);

      key.currentState!.set('count', 2);
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.text('static'), findsOneWidget);
    });

    testWidgets('_if 술어 상태가 바뀌면 자식을 켜고 끈다', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'visible': true},
          key: key,
          child: _content(const {
            '_type': 'column',
            '_children': [
              {'_type': 'text', 'value': 'shown', '_if': r'${visible}'},
            ],
          }),
        ),
      );

      expect(find.text('shown'), findsOneWidget);

      key.currentState!.set('visible', false);
      await tester.pump();
      expect(find.text('shown'), findsNothing);

      key.currentState!.set('visible', true);
      await tester.pump();
      expect(find.text('shown'), findsOneWidget);
    });

    testWidgets('state prop이 갱신되면(위젯 재사용) 자식이 새 값을 읽는다', (tester) async {
      // 같은 위치·타입이라 element·State가 재사용된다(initState 아닌 didUpdateWidget 경로).
      await _pump(
        tester,
        Scope.ofState(const {
          'label': 'A',
        }, child: _content(const {'_type': 'text', 'value': r'${label}'})),
      );
      expect(find.text('A'), findsOneWidget);

      await _pump(
        tester,
        Scope.ofState(const {
          'label': 'B',
        }, child: _content(const {'_type': 'text', 'value': r'${label}'})),
      );

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('config로 넘기면 _state만 초기 상태로 뽑고 driver 조각은 무시한다', (
      tester,
    ) async {
      // S1 계약 — config는 driver 설정을 더 실어 나르지만 상태 seed는 _state만.
      await _pump(
        tester,
        Scope(
          config: ScopeConfig.fromRaw(const {
            '_state': {'label': 'hi'},
            '_action': {
              'tap': {'_set': 'label'},
            },
          }),
          child: _content(const {'_type': 'text', 'value': r'${label}'}),
        ),
      );

      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('선언 안 된 키에 set하면 StateError (조용한 no-op 금지)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'count': 1},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );

      expect(() => key.currentState!.set('nope', 1), throwsStateError);
    });

    testWidgets('선언된 키를 null로 set하면 반영된다(no-op 아님)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'label': 'hi'},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${label}'}),
        ),
      );
      expect(find.text('hi'), findsOneWidget);

      key.currentState!.set('label', null);
      await tester.pump();

      expect(find.text('hi'), findsNothing);
    });

    testWidgets('dispose된 뒤 들어온 set은 조용히 드롭한다(크래시 없음)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'count': 1},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );
      final state = key.currentState!; // 참조를 잡아둔다(dispose 뒤 currentState는 null)

      await _pump(tester, const SizedBox()); // Scope 제거 → dispose

      expect(() => state.set('count', 2), returnsNormally);
    });

    testWidgets('빌드 중 set은 예외 없이 다음 프레임에 반영된다', (tester) async {
      final key = GlobalKey<ScopeState>();
      var fired = false;
      await _pump(
        tester,
        Scope.ofState(
          const {'n': 0},
          key: key,
          child: Column(
            children: [
              _content(const {'_type': 'text', 'value': r'${n}'}), // 구독자(먼저 빌드)
              Builder(
                builder: (_) {
                  // 형제가 빌드되는 도중 동기 set — 구독자는 이미 이 프레임에 그려졌다.
                  if (!fired) {
                    fired = true;
                    key.currentState!.set('n', 1);
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      // 예외 없이 통과했으면 defer 성공. 반영은 다음 프레임.
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('config가 바뀐 채 재pump되면(위젯 재사용) 새 _state를 읽는다', (tester) async {
      // ofState가 아니라 config 통로의 didUpdateWidget→ScopeConfig.stateOf→syncState 경로를 건다.
      // driver 설정(_action)이 config에 섞여 와도 상태 seed는 _state만 반영해야 한다.
      await _pump(
        tester,
        Scope(
          config: ScopeConfig.fromRaw(const {
            '_state': {'label': 'A'},
            '_action': {'tap': 'noop'},
          }),
          child: _content(const {'_type': 'text', 'value': r'${label}'}),
        ),
      );
      expect(find.text('A'), findsOneWidget);

      await _pump(
        tester,
        Scope(
          config: ScopeConfig.fromRaw(const {
            '_state': {'label': 'B'},
            '_action': {'tap': 'noop'},
          }),
          child: _content(const {'_type': 'text', 'value': r'${label}'}),
        ),
      );

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('driver가 바꾼 상태는 seed 그대로인 리빌드에서 살아남는다 (B2 회귀)', (tester) async {
      // 무관한 조상 리빌드(같은 seed 재pump)가 mutation을 seed로 되돌리면 안 된다.
      // reseed는 "선언 seed가 실제로 바뀔 때"만 — 현재 상태와 seed를 비교하면
      // MediaQuery 변화·부모 setState 한 번에 driver가 쓴 값이 초기값으로 리셋된다.
      final key = GlobalKey<ScopeState>();
      Widget tree() => Scope.ofState(
        const {'count': 0},
        key: key,
        child: _content(const {'_type': 'text', 'value': r'${count}'}),
      );

      await _pump(tester, tree());
      expect(find.text('0'), findsOneWidget);

      key.currentState!.set('count', 5);
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      // 같은 seed로 재pump — 상태를 모르는 조상의 리빌드를 흉내낸다.
      await _pump(tester, tree());

      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('seed가 실제로 바뀌면 외부 갱신이 mutation 위에 우선한다', (tester) async {
      // 선언 seed 변경은 권위 있는 외부 갱신(controlled) — 로컬 mutation을 덮는다.
      // B2 가드가 "seed 안 바뀜=skip"만 막고, 진짜 바뀐 seed는 여전히 반영하는지 확인.
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'count': 0},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );
      key.currentState!.set('count', 5);
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      await _pump(
        tester,
        Scope.ofState(
          const {'count': 9},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );

      expect(find.text('9'), findsOneWidget);
      expect(find.text('5'), findsNothing);
    });

    testWidgets('중첩 seed가 내용은 같고 인스턴스만 새로우면 reseed하지 않는다 (deep B2)', (
      tester,
    ) async {
      // 조상 리빌드가 내용이 같은 seed를 새 인스턴스로 다시 만들어 내려도(재decode·인라인 생성)
      // reseed가 아니다. 얕은 비교(mapEquals)는 중첩 컬렉션을 identity로 봐서 여기서 오판해
      // driver가 쓴 로컬 상태(폼 입력 등)를 초기 seed로 되돌린다.
      final key = GlobalKey<ScopeState>();
      Widget tree() => Scope.ofState(
        // 비-const: pump마다 새 맵 인스턴스 — 내용은 동일.
        {'form': <String, Object?>{}},
        key: key,
        child: _content(const {'_type': 'text', 'value': r'${form.email}'}),
      );

      await _pump(tester, tree());
      key.currentState!.set('form', {'email': 'typed@x.com'});
      await tester.pump();
      expect(find.text('typed@x.com'), findsOneWidget);

      await _pump(tester, tree()); // 같은 내용, 새 인스턴스의 seed로 재pump

      expect(find.text('typed@x.com'), findsOneWidget);
    });

    testWidgets('중첩 seed가 실제로 바뀌면 반영된다 (deep 비교가 변경을 놓치지 않음)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          {
            'form': {'email': 'a@x.com'},
          },
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${form.email}'}),
        ),
      );
      expect(find.text('a@x.com'), findsOneWidget);

      await _pump(
        tester,
        Scope.ofState(
          {
            'form': {'email': 'b@x.com'},
          },
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${form.email}'}),
        ),
      );

      expect(find.text('b@x.com'), findsOneWidget);
    });

    testWidgets('같은 seed 맵 인스턴스를 제자리 변경해도 반영된다 (R3 앨리어싱)', (tester) async {
      // 앱이 rootData 맵을 들고 제자리 변경 후 리빌드하는 패턴 — 이전 위젯의 seed와
      // 비교하면 둘이 같은 인스턴스라 "안 바뀜"으로 오판한다. 비교 기준은 위젯이 아니라
      // 엔진이 보관한 마지막 수용 seed(정규화 사본)여야 한다.
      final seed = <String, Object?>{'label': 'A'};
      Widget tree() => Scope.ofState(
        seed,
        child: _content(const {'_type': 'text', 'value': r'${label}'}),
      );

      await _pump(tester, tree());
      expect(find.text('A'), findsOneWidget);

      seed['label'] = 'B'; // 제자리 변경
      await _pump(tester, tree());

      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('키셋이 달라진 seed는 격리한다 — 크래시 없이 보고하고 옛 상태 유지', (tester) async {
      // 스키마 교체(키 추가·제거)는 remount 계약(템플릿 revision key) 위반 — reseed를 스킵하고
      // FlutterError.reportError로 시끄럽게 보고한다. didUpdateWidget에서 StateError로 터지면 안 된다.
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'count': 0},
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );
      key.currentState!.set('count', 5);
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      await _pump(
        tester,
        Scope.ofState(
          const {'count': 0, 'extra': 1}, // 키 추가 — 스키마 교체 시도
          key: key,
          child: _content(const {'_type': 'text', 'value': r'${count}'}),
        ),
      );

      expect(tester.takeException(), isStateError); // 보고됐고
      expect(find.text('5'), findsOneWidget); // 트리는 옛 상태로 살아 있다
    });

    testWidgets('per-key: 한 키 변경은 그 키를 읽는 경계만 리빌드한다', (tester) async {
      // 옛 coarse 통지였다면 $a 변경에 $b 경계도 build가 돌아 B 카운트가 2가 됐다.
      // 키 단위 구독이라 $a 경계만 다시 돈다.
      final buildCounts = <String, int>{};
      WidgetFactory.register(
        'probe',
        EagerSpec((context, props, children) {
          final id = props['id'] as String;
          buildCounts[id] = (buildCounts[id] ?? 0) + 1;
          return Text('${props['v']}');
        }),
      );
      addTearDown(WidgetFactory.reset);

      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'a': 0, 'b': 0},
          key: key,
          child: _content(const {
            '_type': 'column',
            '_children': [
              {'_type': 'probe', 'id': 'A', 'v': r'${a}'},
              {'_type': 'probe', 'id': 'B', 'v': r'${b}'},
            ],
          }),
        ),
      );
      expect(buildCounts, {'A': 1, 'B': 1});

      key.currentState!.set('a', 1);
      await tester.pump();

      expect(buildCounts['A'], 2); // a를 읽는 경계는 리빌드
      expect(buildCounts['B'], 1); // b만 읽는 경계는 그대로
    });

    testWidgets('H1: _motion 인자 상태가 바뀌면 plan이 새 값으로 재호출된다', (tester) async {
      // 옛 구조는 _motion 바인딩을 구독셋에서 빼먹어 상태가 바뀌어도 모션이 얼었다.
      final speeds = <Object?>[];
      MotionFactory.register(_RecordMotion(speeds));
      addTearDown(MotionFactory.reset);

      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'speed': 1},
          key: key,
          child: _content(const {
            '_type': 'text',
            'value': 'hi',
            '_motion': {'type': 'record', 'speed': r'${speed}'},
          }),
        ),
      );
      expect(speeds, [1]);

      key.currentState!.set('speed', 2);
      await tester.pump();

      expect(speeds, [1, 2]); // 상태 변경이 모션 인자 재해석을 유발
    });
  });
}
