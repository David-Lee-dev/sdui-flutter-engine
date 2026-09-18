import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_grid_widget.dart';
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
                SliverGridWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('SliverGridWidget', () {
    group('build', () {
      testWidgets('crossAxisCount·spacing을 격자 delegate로 반영(spacing scale)', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'cross_axis_count': 3, 'cross_axis_spacing': 20},
          children: [const Text('a')],
          scale: 0.5,
        );
        final delegate =
            tester.widget<SliverGrid>(find.byType(SliverGrid)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 3);
        expect(delegate.crossAxisSpacing, 10);
      });
    });
  });
}
