import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/opacity_widget.dart';
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
        builder: (context) => OpacityWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('OpacityWidget', () {
    group('build', () {
      testWidgets('opacity 기본은 1.0', (tester) async {
        await _pump(tester, const {});
        expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
      });

      testWidgets('opacity는 0..1로 클램프된다(스케일 대상 아님)', (tester) async {
        await _pump(tester, const {'opacity': 1.5});
        expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
      });
    });
  });
}
