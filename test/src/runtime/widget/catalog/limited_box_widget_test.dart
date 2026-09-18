import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/limited_box_widget.dart';
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
        builder: (context) => LimitedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('LimitedBoxWidget', () {
    group('build', () {
      testWidgets('maxWidth가 scale된다', (tester) async {
        await _pump(tester, const {'max_width': 200}, scale: 0.5);
        expect(
          tester.widget<LimitedBox>(find.byType(LimitedBox)).maxWidth,
          100,
        );
      });

      testWidgets('안 적힌 성분은 무한', (tester) async {
        await _pump(tester, const {'max_width': 200});
        expect(
          tester.widget<LimitedBox>(find.byType(LimitedBox)).maxHeight,
          double.infinity,
        );
      });
    });
  });
}
