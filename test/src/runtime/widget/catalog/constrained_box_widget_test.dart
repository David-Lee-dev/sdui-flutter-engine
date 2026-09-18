import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/constrained_box_widget.dart';
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
            ConstrainedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ConstrainedBoxWidget', () {
    group('build', () {
      testWidgets('constraints의 치수가 scale된다', (tester) async {
        await _pump(tester, const {
          'constraints': {'max_width': 100, 'min_height': 40},
        }, scale: 0.5);
        final box = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox));
        expect(box.constraints.maxWidth, 50);
        expect(box.constraints.minHeight, 20);
      });

      testWidgets('constraints 없으면 무제약(BoxConstraints 기본)', (tester) async {
        await _pump(tester, const {});
        final box = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox));
        expect(box.constraints, const BoxConstraints());
      });
    });
  });
}
