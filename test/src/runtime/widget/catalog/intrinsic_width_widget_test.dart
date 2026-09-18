import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/intrinsic_width_widget.dart';
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
            IntrinsicWidthWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('IntrinsicWidthWidget', () {
    group('build', () {
      testWidgets('stepWidth가 scale된다', (tester) async {
        await _pump(tester, const {'step_width': 20}, scale: 0.5);
        expect(
          tester.widget<IntrinsicWidth>(find.byType(IntrinsicWidth)).stepWidth,
          10,
        );
      });
    });
  });
}
