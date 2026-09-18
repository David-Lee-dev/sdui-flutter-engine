import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/single_child_scroll_view_widget.dart';
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
        builder: (context) =>
            SingleChildScrollViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('SingleChildScrollViewWidget', () {
    group('build', () {
      testWidgets('scrollDirection·padding·physics를 읽는다(padding scale)', (
        tester,
      ) async {
        await _pump(tester, const {
          'scroll_direction': 'horizontal',
          'padding': 20,
          'physics': 'never',
        }, scale: 0.5);
        final v = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        expect(v.scrollDirection, Axis.horizontal);
        expect(v.padding, const EdgeInsets.all(10));
        expect(v.physics, isA<NeverScrollableScrollPhysics>());
      });

      testWidgets('scrollDirection 기본은 vertical', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .scrollDirection,
          Axis.vertical,
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
        final view = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
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
