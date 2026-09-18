import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/swipe_pane_widget.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller_scope.dart';

/// Mounts [child] under a live [controller] inside a fixed 400×300 viewport so
/// page math is predictable.
Future<void> _pump(
  WidgetTester tester,
  SwipeController controller,
  Widget child,
) => tester.pumpWidget(
  MaterialApp(
    home: EngineMetrics(
      scale: 1.0,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 300,
          child: SwipeControllerScope(controller: controller, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  group('SwipePaneWidget', () {
    group('build', () {
      testWidgets('renders a PageView over the positional children', (
        tester,
      ) async {
        final controller = SwipeController(length: 2);
        await _pump(
          tester,
          controller,
          Builder(
            builder: (context) => SwipePaneWidget.build(
              context,
              const {},
              const [Text('A0'), Text('A1')],
            ),
          ),
        );
        addTearDown(controller.dispose);

        expect(find.byType(PageView), findsOneWidget);
        expect(find.text('A0'), findsOneWidget);
      });

      testWidgets('a drag settles the shared controller onto the new page', (
        tester,
      ) async {
        final controller = SwipeController(length: 2);
        await _pump(
          tester,
          controller,
          Builder(
            builder: (context) => SwipePaneWidget.build(
              context,
              const {},
              const [Text('A0'), Text('A1')],
            ),
          ),
        );
        addTearDown(controller.dispose);

        await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
        await tester.pumpAndSettle();

        expect(controller.index, 1);
      });
    });

    group('cross-pane synchronization', () {
      testWidgets('a half drag of one pane moves the shared position halfway', (
        tester,
      ) async {
        final controller = SwipeController(length: 2);
        await _pump(
          tester,
          controller,
          Column(
            children: [
              SizedBox(
                height: 150,
                child: Builder(
                  builder: (c) => SwipePaneWidget.build(c, const {}, const [
                    Text('A0'),
                    Text('A1'),
                  ]),
                ),
              ),
              SizedBox(
                height: 150,
                child: Builder(
                  builder: (c) => SwipePaneWidget.build(c, const {}, const [
                    Text('B0'),
                    Text('B1'),
                  ]),
                ),
              ),
            ],
          ),
        );
        addTearDown(controller.dispose);

        // Drag pane A half a viewport (200 of 400) without releasing.
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PageView).first),
        );
        await gesture.moveBy(const Offset(-200, 0));
        await tester.pump();

        // The controller tracks the continuous mid-drag position...
        expect(controller.page, greaterThan(0.3));
        expect(controller.page, lessThan(0.8));

        await gesture.up();
        await tester.pumpAndSettle();

        // ...and both panes land on the same page.
        expect(controller.index, 1);
        expect(find.text('B1'), findsOneWidget);
      });
    });

    group('nested-scrollable isolation', () {
      testWidgets('a nested same-axis scroll end does not end the pane drag', (
        tester,
      ) async {
        final controller = SwipeController(length: 2);
        addTearDown(controller.dispose);
        final inner = ScrollController();
        addTearDown(inner.dispose);

        await _pump(
          tester,
          controller,
          Builder(
            builder: (context) => SwipePaneWidget.build(context, const {}, [
              ListView(
                controller: inner,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < 5; i++)
                    SizedBox(width: 200, child: Text('m$i')),
                ],
              ),
              const Text('P1'),
            ]),
          ),
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PageView)),
        );
        await gesture.moveBy(const Offset(-120, 0));
        await tester.pump();

        expect(controller.isInteracting, isTrue);

        inner.jumpTo(40);
        await tester.pump();

        expect(
          controller.isInteracting,
          isTrue,
          reason:
              'a nested same-axis scrollable must not terminate the pane drag',
        );

        await gesture.up();
        await tester.pumpAndSettle();
      });
    });
  });
}
