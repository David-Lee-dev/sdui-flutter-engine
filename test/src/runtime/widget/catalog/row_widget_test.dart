import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/row_widget.dart';
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
        builder: (context) => RowWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('RowWidget', () {
    group('build', () {
      testWidgets('props 없으면 Flutter 기본(start/center/max/down)', (
        tester,
      ) async {
        await _pump(tester, const {});
        final row = tester.widget<Row>(find.byType(Row));
        expect(row.mainAxisAlignment, MainAxisAlignment.start);
        expect(row.crossAxisAlignment, CrossAxisAlignment.center);
        expect(row.mainAxisSize, MainAxisSize.max);
      });

      testWidgets('mainAxisAlignment를 읽는다', (tester) async {
        await _pump(tester, const {'main_axis_alignment': 'space_evenly'});
        expect(
          tester.widget<Row>(find.byType(Row)).mainAxisAlignment,
          MainAxisAlignment.spaceEvenly,
        );
      });

      testWidgets('children을 그대로 담는다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b'), const Text('c')],
        );
        expect(tester.widget<Row>(find.byType(Row)).children, hasLength(3));
      });

      testWidgets('baseline 정렬은 text_baseline 없으면 alphabetic으로 맞춘다', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'cross_axis_alignment': 'baseline'},
          children: const [
            Text('a', style: TextStyle(fontSize: 12)),
            Text('b', style: TextStyle(fontSize: 24)),
          ],
        );

        expect(tester.takeException(), isNull);
        final row = tester.renderObject<RenderFlex>(find.byType(Row));
        final a = row.firstChild!;
        final b = row.childAfter(a)!;
        double baseline(RenderBox box) =>
            (box.parentData! as FlexParentData).offset.dy +
            box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
        expect(baseline(a), closeTo(baseline(b), 0.001));
      });
    });
  });
}
