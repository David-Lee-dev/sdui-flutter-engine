import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/grid_view_widget.dart';
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
        builder: (context) => GridViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('GridViewWidget', () {
    group('build', () {
      testWidgets('crossAxisCount·spacing을 격자 delegate로 반영(spacing scale)', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'cross_axis_count': 3, 'main_axis_spacing': 20},
          children: [const Text('a')],
          scale: 0.5,
        );
        final delegate =
            tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 3);
        expect(delegate.mainAxisSpacing, 10);
      });

      testWidgets('crossAxisCount 기본은 2', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final delegate =
            tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<GridView>(find.byType(GridView));
        expect(view.primary, isFalse);
        expect(
          view.keyboardDismissBehavior,
          ScrollViewKeyboardDismissBehavior.onDrag,
        );
        expect(view.clipBehavior, Clip.none);
      });
    });
  });
}
