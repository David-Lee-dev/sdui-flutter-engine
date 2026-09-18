import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/fitted_box_widget.dart';
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
        builder: (context) => FittedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('FittedBoxWidget', () {
    group('build', () {
      testWidgets('fit·alignment을 읽는다', (tester) async {
        await _pump(tester, const {'fit': 'cover', 'alignment': 'top_left'});
        final box = tester.widget<FittedBox>(find.byType(FittedBox));
        expect(box.fit, BoxFit.cover);
        expect(box.alignment, Alignment.topLeft);
      });

      testWidgets('기본은 contain·center', (tester) async {
        await _pump(tester, const {});
        final box = tester.widget<FittedBox>(find.byType(FittedBox));
        expect(box.fit, BoxFit.contain);
        expect(box.alignment, Alignment.center);
      });
    });
  });
}
