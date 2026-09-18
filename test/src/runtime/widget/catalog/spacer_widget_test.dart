import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/spacer_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(WidgetTester tester, Map<String, Object?> props) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1.0,
          child: Column(
            children: [
              Builder(
                builder: (context) =>
                    SpacerWidget.build(context, props, const []),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  group('SpacerWidget', () {
    group('build', () {
      testWidgets('flex 기본은 1', (tester) async {
        await _pump(tester, const {});
        expect(tester.widget<Spacer>(find.byType(Spacer)).flex, 1);
      });

      testWidgets('flex를 읽는다', (tester) async {
        await _pump(tester, const {'flex': 4});
        expect(tester.widget<Spacer>(find.byType(Spacer)).flex, 4);
      });
    });
  });
}
