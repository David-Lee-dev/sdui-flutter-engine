import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sizedbox_widget.dart';
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
        builder: (context) => SizedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('SizedBoxWidget', () {
    group('build', () {
      testWidgets('width·height가 scale된다', (tester) async {
        await _pump(tester, const {'width': 100, 'height': 40}, scale: 0.5);
        final box = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(box.width, 50);
        expect(box.height, 20);
      });

      testWidgets('자식은 첫 번째만', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(
          (tester.widget<SizedBox>(find.byType(SizedBox)).child as Text).data,
          'a',
        );
      });
    });
  });
}
