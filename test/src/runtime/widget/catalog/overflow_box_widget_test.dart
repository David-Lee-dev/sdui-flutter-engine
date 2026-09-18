import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/overflow_box_widget.dart';
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
        builder: (context) => OverflowBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('OverflowBoxWidget', () {
    group('build', () {
      testWidgets('maxWidth·maxHeight가 scale된다', (tester) async {
        await _pump(tester, const {
          'max_width': 300,
          'max_height': 200,
        }, scale: 0.5);
        final box = tester.widget<OverflowBox>(find.byType(OverflowBox));
        expect(box.maxWidth, 150);
        expect(box.maxHeight, 100);
      });

      testWidgets('alignment 기본은 center', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<OverflowBox>(find.byType(OverflowBox)).alignment,
          Alignment.center,
        );
      });
    });
  });
}
