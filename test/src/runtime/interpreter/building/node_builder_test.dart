import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/loop_observer.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/condition_observer.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/observer/plain_observer.dart';
import 'package:sdui_engine/src/runtime/environment/map_environment.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';
import 'package:sdui_engine/src/runtime/wrapper/scroll_event_wrapper.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/bound_builder.dart';
import 'package:sdui_engine/src/runtime/wrapper/tap_effect.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';

void main() {
  group('NodeBuilder', () {
    group('build', () {
      test('노드는 PlainObserver 경계로 (정적/동적 무관, 판단은 경계 안에서)', () {
        expect(
          NodeBuilder.build(
            const PlainDirective(
              type: 'text',
              props: {'value': 'hi'},
              children: [],
              roots: <String>{},
            ),
          ),
          isA<PlainObserver>(),
        );
        expect(
          NodeBuilder.build(
            const PlainDirective(
              type: 'text',
              props: {'value': r'${x}'},
              children: [],
              roots: <String>{'x'},
            ),
          ),
          isA<PlainObserver>(),
        );
      });

      test('_if는 ConditionObserver로', () {
        final widget = NodeBuilder.build(
          ConditionDirective(
            path: 'test',
            branches: [
              (
                predicate: Expression.compile(r'show'),
                body: const PlainDirective(
                  type: 'text',
                  props: {},
                  children: [],
                  roots: <String>{},
                ),
              ),
            ],
          ),
        );
        expect(widget, isA<ConditionObserver>());
      });

      test('_loop는 LoopObserver로', () {
        final widget = NodeBuilder.build(
          LoopDirective(
            source: Expression.compile(r'items'),
            as: 'it',
            index: 'i',
            keyExpression: Expression.compile(r'it.id'),
            child: const PlainDirective(
              type: 'text',
              props: {},
              children: [],
              roots: <String>{},
            ),
            path: 'test',
          ),
        );
        expect(widget, isA<LoopObserver>());
      });
    });

    group('assemble', () {
      testWidgets('입력 이벤트만 있으면 InteractionWrapper로 감싸지 않는다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        );

        final widget = NodeBuilder.assemble(
          context,
          const PlainDirective(
            type: 'text_field',
            props: {'bind': 'name'},
            on: {'change': 'on_type'},
            children: [],
            roots: <String>{},
          ),
          const MapEnvironment({}),
        );

        expect(widget, isA<BoundBuilder>());
        expect(widget, isNot(isA<InteractionWrapper>()));
      });

      testWidgets('tap 이벤트가 있으면 InteractionWrapper로 감싼다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        );

        final widget = NodeBuilder.assemble(
          context,
          const PlainDirective(
            type: 'text',
            props: {'value': 'tap'},
            on: {'tap': 'go'},
            children: [],
            roots: <String>{},
          ),
          const MapEnvironment({}),
        );

        expect(widget, isA<InteractionWrapper>());
        expect(widget, isNot(isA<ScrollEventWrapper>()));
        final interaction = widget as InteractionWrapper;
        expect(interaction.node.type, 'text');
        expect(interaction.node.path, '');
      });

      testWidgets('tap은 기본으로 리플(TapEffect)을 보인다', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: NodeBuilder.build(
              TemplateCompiler.buildDirectiveTree(
                TemplateParser.buildUiTree(const {
                  '_type': 'text',
                  'value': 'x',
                  '_on': {'tap': 'go'},
                }),
              ),
            ),
          ),
        );
        expect(find.byType(TapEffect), findsOneWidget);
      });

      testWidgets('_on tap ripple:false 면 피드백 없이 탭만 동작한다', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: NodeBuilder.build(
              TemplateCompiler.buildDirectiveTree(
                TemplateParser.buildUiTree(const {
                  '_type': 'text',
                  'value': 'x',
                  '_on': {
                    'tap': {'do': 'go', 'ripple': false},
                  },
                }),
              ),
            ),
          ),
        );
        expect(find.byType(TapEffect), findsNothing);
        expect(find.byType(GestureDetector), findsWidgets);
      });

      testWidgets('scroll 이벤트만 있으면 ScrollEventWrapper로만 감싼다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        );

        final widget = NodeBuilder.assemble(
          context,
          const PlainDirective(
            type: 'text',
            props: {},
            on: {'end_reached': 'more'},
            children: [],
            roots: <String>{},
          ),
          const MapEnvironment({}),
        );

        expect(widget, isA<ScrollEventWrapper>());
        expect(widget, isNot(isA<InteractionWrapper>()));
        expect((widget as ScrollEventWrapper).endThreshold, 300);
        expect(widget.startThreshold, 300);
      });

      testWidgets('key가 있으면 KeyedSubtree로 감싼다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        );
        final widget = NodeBuilder.assemble(
          context,
          const PlainDirective(
            type: 'text',
            props: {'value': 'hi'},
            key: 'k1',
            children: [],
            roots: <String>{},
          ),
          const MapEnvironment({}),
        );
        expect(widget, isA<KeyedSubtree>());
        expect((widget as KeyedSubtree).key, const ValueKey('k1'));
      });
    });

    group('prop 감사 (read-tracking — 안 읽은 prop debug 경고)', () {
      // debugPrint는 flutter_test가 테스트 종료 시 기본값 복원을 검사하므로(foundation invariant),
      // pump 동안만 가로채고 **본문 안에서 즉시 복원**한다(tearDown은 그 검사 뒤라 늦음).
      Future<List<String>> pumpCapturing(
        WidgetTester tester,
        PlainDirective directive,
      ) async {
        final logs = <String>[];
        final original = debugPrint;
        debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
        try {
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: NodeBuilder.build(directive),
            ),
          );
        } finally {
          debugPrint = original;
        }
        return logs;
      }

      testWidgets('위젯이 안 읽은 prop(오타)은 debug 경고하되 렌더는 정상', (tester) async {
        // text는 zzzTypo를 안 읽는다 → 무시되고 debug 경고. 마운트-치명 아님(관대 렌더).
        final logs = await pumpCapturing(
          tester,
          const PlainDirective(
            type: 'text',
            props: {'value': 'hi', 'zzz_typo': 1},
            children: [],
            roots: <String>{},
          ),
        );
        expect(find.text('hi'), findsOneWidget); // 렌더는 정상
        expect(logs.any((l) => l.contains('zzz_typo')), isTrue);
      });

      testWidgets('위젯이 읽는 prop만 있으면 경고 없음', (tester) async {
        final logs = await pumpCapturing(
          tester,
          const PlainDirective(
            type: 'text',
            props: {'value': 'hi'},
            children: [],
            roots: <String>{},
          ),
        );
        expect(logs.any((l) => l.contains('unknown prop')), isFalse);
      });

      testWidgets('child(언더바 빠진 슬롯)는 무시된 prop으로 경고한다', (tester) async {
        // `_child`가 아니라 `child`로 쓰면 prop으로 취급되어 안 읽힌다.
        final logs = await pumpCapturing(
          tester,
          const PlainDirective(
            type: 'text',
            props: {'value': 'hi', 'child': 'x'},
            children: [],
            roots: <String>{},
          ),
        );
        expect(logs.any((l) => l.contains('ignored prop(s): child')), isTrue);
      });
    });
  });
}
