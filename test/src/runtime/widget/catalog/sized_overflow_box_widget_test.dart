import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sized_overflow_box_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) =>
            SizedOverflowBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('SizedOverflowBoxWidget', () {
    group('build', () {
      testWidgets('width·height가 Size로, scale 적용', (tester) async {
        await _pump(tester, const {'width': 100, 'height': 40}, scale: 0.5);
        expect(
          tester.widget<SizedOverflowBox>(find.byType(SizedOverflowBox)).size,
          const Size(50, 20),
        );
      });

      testWidgets('빠진 성분은 0', (tester) async {
        await _pump(tester, const {'width': 100});
        expect(
          tester.widget<SizedOverflowBox>(find.byType(SizedOverflowBox)).size,
          const Size(100, 0),
        );
      });
    });
  });
}
