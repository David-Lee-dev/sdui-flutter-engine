import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/custom_scroll_view_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> slivers = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            CustomScrollViewWidget.build(context, props, slivers),
      ),
    ),
  ),
);

void main() {
  group('CustomScrollViewWidget', () {
    group('build', () {
      testWidgets('명시된 sliver 자식을 slivers로 넘긴다', (tester) async {
        await _pump(
          tester,
          const {},
          slivers: [const SliverToBoxAdapter(child: Text('a'))],
        );
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('scrollDirection을 읽는다', (tester) async {
        await _pump(
          tester,
          const {'scroll_direction': 'horizontal'},
          slivers: [const SliverToBoxAdapter(child: SizedBox())],
        );
        expect(
          tester
              .widget<CustomScrollView>(find.byType(CustomScrollView))
              .scrollDirection,
          Axis.horizontal,
        );
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
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
