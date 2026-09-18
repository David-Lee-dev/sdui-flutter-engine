import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/column_widget.dart';
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
        builder: (context) => ColumnWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ColumnWidget', () {
    group('build', () {
      testWidgets('props 없으면 Flutter 기본(start/center/max/down)', (
        tester,
      ) async {
        await _pump(tester, const {});
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.mainAxisAlignment, MainAxisAlignment.start);
        expect(column.crossAxisAlignment, CrossAxisAlignment.center);
        expect(column.mainAxisSize, MainAxisSize.max);
        expect(column.verticalDirection, VerticalDirection.down);
      });

      testWidgets('정렬 props를 그대로 읽는다', (tester) async {
        await _pump(tester, const {
          'main_axis_alignment': 'space_between',
          'cross_axis_alignment': 'stretch',
          'main_axis_size': 'min',
        });
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.mainAxisAlignment, MainAxisAlignment.spaceBetween);
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
        expect(column.mainAxisSize, MainAxisSize.min);
      });

      testWidgets('children을 그대로 담는다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(
          tester.widget<Column>(find.byType(Column)).children,
          hasLength(2),
        );
      });
    });
  });
}
