import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/indexed_stack_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            IndexedStackWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('IndexedStackWidget', () {
    group('build', () {
      testWidgets('index를 읽어 그 자식만 보인다', (tester) async {
        await _pump(
          tester,
          const {'index': 1},
          children: [const Text('a'), const Text('b')],
        );
        expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
      });

      testWidgets('index 기본은 0, sizing 기본은 loose', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final s = tester.widget<IndexedStack>(find.byType(IndexedStack));
        expect(s.index, 0);
        expect(s.sizing, StackFit.loose);
      });

      testWidgets('textDirection을 전달한다', (tester) async {
        await _pump(
          tester,
          const {'text_direction': 'rtl'},
          children: [const Text('a')],
        );
        expect(
          tester.widget<IndexedStack>(find.byType(IndexedStack)).textDirection,
          TextDirection.rtl,
        );
      });

      testWidgets('범위를 넘은 index는 마지막 자식으로 클램프한다', (tester) async {
        await _pump(
          tester,
          const {'index': 5},
          children: [const Text('a'), const Text('b')],
        );

        final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
        expect(stack.index, 1);
        expect(find.text('b'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('자식이 없으면 SizedBox.shrink로 강등한다', (tester) async {
        await _pump(tester, const {'index': 5});

        expect(find.byType(IndexedStack), findsNothing);
        final box = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(box.width, 0);
        expect(box.height, 0);
      });
    });
  });
}
