import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/center_widget.dart';
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
        builder: (context) => CenterWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('CenterWidget', () {
    group('build', () {
      testWidgets('widthFactor·heightFactor는 배수라 스케일 대상 아님', (tester) async {
        await _pump(tester, const {'width_factor': 2, 'height_factor': 1.5});
        final center = tester.widget<Center>(find.byType(Center));
        expect(center.widthFactor, 2.0);
        expect(center.heightFactor, 1.5);
      });

      testWidgets('없으면 null(자식 크기에 안 묶임)', (tester) async {
        await _pump(tester, const {});
        final center = tester.widget<Center>(find.byType(Center));
        expect(center.widthFactor, isNull);
        expect(center.heightFactor, isNull);
      });
    });
  });
}
