import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/baseline_widget.dart';
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
        builder: (context) => BaselineWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('BaselineWidget', () {
    group('build', () {
      testWidgets('baseline이 scale되고 baselineType을 읽는다', (tester) async {
        await _pump(tester, const {
          'baseline': 40,
          'baseline_type': 'ideographic',
        }, scale: 0.5);
        final b = tester.widget<Baseline>(find.byType(Baseline));
        expect(b.baseline, 20);
        expect(b.baselineType, TextBaseline.ideographic);
      });

      testWidgets('baselineType 기본은 alphabetic', (tester) async {
        await _pump(tester, const {'baseline': 10});
        expect(
          tester.widget<Baseline>(find.byType(Baseline)).baselineType,
          TextBaseline.alphabetic,
        );
      });
    });
  });
}
