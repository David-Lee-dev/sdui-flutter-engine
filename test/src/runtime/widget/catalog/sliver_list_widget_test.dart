import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_list_widget.dart';
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
      child: CustomScrollView(
        slivers: [
          Builder(
            builder: (context) =>
                SliverListWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverListWidget', () {
    group('build', () {
      testWidgets('명시된 자식을 sliver 리스트로 렌더한다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(find.byType(SliverList), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
      });
    });
  });
}
