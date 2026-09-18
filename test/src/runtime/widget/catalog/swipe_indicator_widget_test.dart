import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/swipe_indicator_widget.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller_scope.dart';

Future<void> _pump(
  WidgetTester tester,
  SwipeController controller,
  Map<String, Object?> props,
) => tester.pumpWidget(
  MaterialApp(
    home: EngineMetrics(
      scale: 1.0,
      child: Center(
        child: SwipeControllerScope(
          controller: controller,
          child: Builder(
            builder: (context) =>
                SwipeIndicatorWidget.build(context, props, const []),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('SwipeIndicatorWidget', () {
    group('build', () {
      testWidgets('draws one indicator per page', (tester) async {
        final controller = SwipeController(length: 3);
        addTearDown(controller.dispose);
        await _pump(tester, controller, const {});

        expect(
          tester.widget<SmoothIndicator>(find.byType(SmoothIndicator)).count,
          3,
        );
      });

      testWidgets('defaults to a worm effect and honours the effect prop', (
        tester,
      ) async {
        final controller = SwipeController(length: 3);
        addTearDown(controller.dispose);

        await _pump(tester, controller, const {});
        expect(
          tester.widget<SmoothIndicator>(find.byType(SmoothIndicator)).effect,
          isA<WormEffect>(),
        );

        await _pump(tester, controller, const {'effect': 'expand'});
        expect(
          tester.widget<SmoothIndicator>(find.byType(SmoothIndicator)).effect,
          isA<ExpandingDotsEffect>(),
        );
      });
    });

    group('following the controller', () {
      testWidgets('offset tracks the controller position', (tester) async {
        final controller = SwipeController(length: 3);
        addTearDown(controller.dispose);
        await _pump(tester, controller, const {});

        expect(
          tester.widget<SmoothIndicator>(find.byType(SmoothIndicator)).offset,
          0.0,
        );

        await controller.goTo(2);
        await tester.pump();

        expect(
          tester.widget<SmoothIndicator>(find.byType(SmoothIndicator)).offset,
          2.0,
        );
      });
    });
  });
}
