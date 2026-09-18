import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/padding_widget.dart';
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
        builder: (context) => PaddingWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('PaddingWidget', () {
    group('build', () {
      testWidgets('padding이 없으면 EdgeInsets.zero', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<Padding>(find.byType(Padding)).padding,
          EdgeInsets.zero,
        );
      });

      testWidgets('padding이 scale된다', (tester) async {
        await _pump(tester, const {'padding': 16}, scale: 0.5);
        expect(
          tester.widget<Padding>(find.byType(Padding)).padding,
          const EdgeInsets.all(8),
        );
      });
    });
  });
}
