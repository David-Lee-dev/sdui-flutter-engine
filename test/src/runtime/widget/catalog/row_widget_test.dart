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
    });
  });
}
