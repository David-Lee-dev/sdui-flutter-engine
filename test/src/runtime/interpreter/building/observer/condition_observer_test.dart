import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

const _grades = {
  '_type': 'cond',
  '_children': [
    {'_type': 'text', 'value': 'A', '_if': r'${score > 90}'},
    {'_type': 'text', 'value': 'B', '_if': r'${score > 80}'},
    {'_type': 'text', 'value': 'C', '_if': r'${score > 70}'},
    {'_type': 'text', 'value': 'F', '_else': true},
  ],
};

void main() {
  group('ConditionObserver (cond)', () {
    testWidgets('순서대로 첫 참 가지를 렌더한다', (tester) async {
      await _pump(
        tester,
        Scope.ofState(const {'score': 85}, child: _content(_grades)),
      );

      expect(find.text('B'), findsOneWidget); // 85 > 80 (>90은 거짓)
      expect(find.text('A'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(find.text('F'), findsNothing);
    });

    testWidgets('아무 가지도 안 맞으면 _else', (tester) async {
      await _pump(
        tester,
        Scope.ofState(const {'score': 50}, child: _content(_grades)),
      );

      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('_else만 있어도 fallback 본문을 렌더한다', (tester) async {
      const elseOnly = {
        '_type': 'cond',
        '_children': [
          {'_type': 'text', 'value': 'fallback', '_else': true},
        ],
      };

      await _pump(tester, _content(elseOnly));

      expect(find.text('fallback'), findsOneWidget);
    });

    testWidgets('_else 없고 아무것도 안 맞으면 빈 자리', (tester) async {
      const noElse = {
        '_type': 'cond',
        '_children': [
          {'_type': 'text', 'value': 'A', '_if': r'${score > 90}'},
        ],
      };
      await _pump(
        tester,
        Scope.ofState(const {'score': 10}, child: _content(noElse)),
      );

      expect(find.text('A'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('술어 상태가 바뀌면 가지를 전환한다(반응)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(const {'score': 95}, key: key, child: _content(_grades)),
      );

      expect(find.text('A'), findsOneWidget);

      key.currentState!.set('score', 50);
      await tester.pump();

      expect(find.text('A'), findsNothing);
      expect(find.text('F'), findsOneWidget);
    });
  });
}
