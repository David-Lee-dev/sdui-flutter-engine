import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/skeleton_widget.dart';

Future<void> _pump(WidgetTester tester, Map<String, Object?> props) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: EngineMetrics(
          scale: 1.0,
          child: Center(
            child: Builder(
              builder: (context) =>
                  SkeletonWidget.build(context, props, const []),
            ),
          ),
        ),
      ),
    );

Container _box(WidgetTester tester) =>
    tester.widget<Container>(find.byType(Container));

void main() {
  group('SkeletonWidget', () {
    group('build', () {
      testWidgets('rect — sizes the bone and rounds by radius', (tester) async {
        await _pump(tester, const {'width': 120, 'height': 16, 'radius': 6});
        final box = tester.getSize(find.byType(Container));
        expect(box, const Size(120, 16));
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(6));
        // opaque fill so the ancestor shimmer's srcATOP mask has pixels.
        expect((decoration.color)!.a, 1.0);
      });

      testWidgets('circle — diameter is height, width ignored', (tester) async {
        await _pump(tester, const {
          'width': 200,
          'height': 40,
          'shape': 'circle',
        });
        expect(tester.getSize(find.byType(Container)), const Size(40, 40));
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('pill — fully rounded ends at any width', (tester) async {
        await _pump(tester, const {'width': 80, 'height': 24, 'shape': 'pill'});
        final decoration = _box(tester).decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(12));
      });
    });
  });
}
