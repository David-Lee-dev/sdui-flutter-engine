import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/auto_scroll_widget.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: EngineMetrics(
      scale: 1.0,
      child: SizedBox(width: 400, height: 300, child: child),
    ),
  ),
);

void main() {
  group('AutoScrollWidget', () {
    group('build', () {
      testWidgets('renders a shrink box for empty children', (tester) async {
        await _pump(
          tester,
          Builder(
            builder: (context) =>
                AutoScrollWidget.build(context, const {}, const []),
          ),
        );

        expect(find.byType(ListView), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 0 && widget.height == 0,
          ),
          findsOneWidget,
        );
      });

      testWidgets('renders an infinite ListView over positional children', (
        tester,
      ) async {
        await _pump(
          tester,
          Builder(
            builder: (context) => AutoScrollWidget.build(
              context,
              const {},
              const [Text('A'), Text('B')],
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('A'), findsWidgets);
      });

      testWidgets('respects horizontal scroll direction', (tester) async {
        await _pump(
          tester,
          Builder(
            builder: (context) => AutoScrollWidget.build(
              context,
              const {'scroll_direction': 'horizontal'},
              const [SizedBox(width: 100, child: Text('A'))],
            ),
          ),
        );

        final list = tester.widget<ListView>(find.byType(ListView));
        expect(list.scrollDirection, Axis.horizontal);
      });

      testWidgets('advances continuously as time elapses', (tester) async {
        await _pump(
          tester,
          Builder(
            builder: (context) => AutoScrollWidget.build(
              context,
              const {'speed': 40},
              const [SizedBox(height: 100, child: Text('A'))],
            ),
          ),
        );
        await tester.pump();

        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );
        final initialOffset = scrollable.position.pixels;
        await tester.pump(const Duration(seconds: 1));

        expect(scrollable.position.pixels, greaterThan(initialOffset));
        expect(scrollable.position.pixels, closeTo(40, 1));
        expect(tester.takeException(), isNull);
      });
    });
  });
}
