import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/flex_widget.dart';
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
        builder: (context) => FlexWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('FlexWidget', () {
    group('build', () {
      testWidgets('direction을 읽는다', (tester) async {
        await _pump(tester, const {'direction': 'vertical'});
        expect(tester.widget<Flex>(find.byType(Flex)).direction, Axis.vertical);
      });

      testWidgets('direction 기본은 horizontal', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<Flex>(find.byType(Flex)).direction,
          Axis.horizontal,
        );
      });

      testWidgets('spacing을 scale해 전달한다', (tester) async {
        await _pump(tester, const {'spacing': 12});
        expect(tester.widget<Flex>(find.byType(Flex)).spacing, 12);
      });
    });
  });
}
