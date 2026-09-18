import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/list_view_widget.dart';
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
        builder: (context) => ListViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ListViewWidget', () {
    group('build', () {
      testWidgets(
        'scrollDirection·itemExtent·shrinkWrap을 읽는다(itemExtent scale)',
        (tester) async {
          await _pump(
            tester,
            const {
              'scroll_direction': 'horizontal',
              'item_extent': 100,
              'shrink_wrap': true,
            },
            children: [const Text('a'), const Text('b')],
            scale: 0.5,
          );
          final v = tester.widget<ListView>(find.byType(ListView));
          expect(v.scrollDirection, Axis.horizontal);
          expect(v.itemExtent, 50);
          expect(v.shrinkWrap, isTrue);
        },
      );

      testWidgets('명시된 자식을 그대로 렌더한다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<ListView>(find.byType(ListView));
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
