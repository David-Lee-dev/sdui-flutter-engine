import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/flexible_widget.dart';
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
      child: Column(
        children: [
          Builder(
            builder: (context) =>
                FlexibleWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('FlexibleWidget', () {
    group('build', () {
      testWidgets('flex 기본 1, fit 기본 loose', (tester) async {
        await _pump(tester, const {});
        final flexible = tester.widget<Flexible>(find.byType(Flexible));
        expect(flexible.flex, 1);
        expect(flexible.fit, FlexFit.loose);
      });

      testWidgets('flex·fit을 읽는다', (tester) async {
        await _pump(tester, const {'flex': 2, 'fit': 'tight'});
        final flexible = tester.widget<Flexible>(find.byType(Flexible));
        expect(flexible.flex, 2);
        expect(flexible.fit, FlexFit.tight);
      });
    });
  });
}
