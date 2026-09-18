import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/fractionally_sized_box_widget.dart';
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
            FractionallySizedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('FractionallySizedBoxWidget', () {
    group('build', () {
      testWidgets('factor는 배수라 scale을 곱하지 않는다', (tester) async {
        await _pump(tester, const {
          'width_factor': 0.5,
          'height_factor': 0.8,
        }, scale: 0.5);
        final box = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        expect(box.widthFactor, 0.5);
        expect(box.heightFactor, 0.8);
      });

      testWidgets('alignment 기본은 center', (tester) async {
        await _pump(tester, const {});
        expect(
          tester
              .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
              .alignment,
          Alignment.center,
        );
      });
    });
  });
}
