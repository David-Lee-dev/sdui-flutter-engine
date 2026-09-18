import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/nested_body_widget.dart';
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
        builder: (context) => NestedBodyWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('NestedBodyWidget', () {
    group('build', () {
      testWidgets('자식을 NestedBodyMarker로 감싸 그대로 렌더한다', (tester) async {
        await _pump(tester, const {}, children: [const Text('body')]);
        expect(find.byType(NestedBodyMarker), findsOneWidget);
        expect(find.text('body'), findsOneWidget);
      });
    });
  });
}
