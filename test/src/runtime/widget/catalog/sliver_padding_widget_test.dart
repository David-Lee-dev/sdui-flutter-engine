import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_padding_widget.dart';
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
      child: CustomScrollView(
        slivers: [
          Builder(
            builder: (context) =>
                SliverPaddingWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverPaddingWidget', () {
    group('build', () {
      testWidgets('padding이 scale되어 sliver에 적용된다', (tester) async {
        await _pump(
          tester,
          const {'padding': 20},
          children: [const SliverToBoxAdapter(child: Text('a'))],
          scale: 0.5,
        );
        expect(
          tester.widget<SliverPadding>(find.byType(SliverPadding)).padding,
          const EdgeInsets.all(10),
        );
      });

      testWidgets('자식이 없으면 빈 sliver로 관대하게', (tester) async {
        await _pump(tester, const {'padding': 5});
        expect(find.byType(SliverPadding), findsOneWidget);
      });
    });
  });
}
