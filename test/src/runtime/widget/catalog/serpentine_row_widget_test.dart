import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/serpentine_row_widget.dart';

Future<RenderSerpentineRow> _pumpRow(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double width = 100,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: EngineMetrics(
        scale: 1,
        child: Center(
          child: SizedBox(
            width: width,
            child: Builder(
              builder: (context) =>
                  SerpentineRowWidget.build(context, props, children),
            ),
          ),
        ),
      ),
    ),
  );
  return tester.renderObject<RenderSerpentineRow>(
    find.byType(SerpentineRowRenderObjectWidget),
  );
}

void main() {
  group('SerpentineRowWidget', () {
    testWidgets('reports direct child rects after laying out spacing', (
      tester,
    ) async {
      final render = await _pumpRow(
        tester,
        const {'spacing': 10},
        children: const [
          SizedBox(width: 20, height: 10),
          SizedBox(width: 30, height: 20),
        ],
      );

      expect(render.cellRects, const [
        Rect.fromLTWH(20, 5, 20, 10),
        Rect.fromLTWH(50, 0, 30, 20),
      ]);
    });

    testWidgets('honours main and cross axis alignment', (tester) async {
      final render = await _pumpRow(
        tester,
        const {'alignment': 'space_between', 'cross_alignment': 'end'},
        children: const [
          SizedBox(width: 20, height: 10),
          SizedBox(width: 30, height: 20),
        ],
      );

      expect(render.cellRects, const [
        Rect.fromLTWH(0, 10, 20, 10),
        Rect.fromLTWH(70, 0, 30, 20),
      ]);
    });

    testWidgets('reports no cell rects for an empty row', (tester) async {
      final render = await _pumpRow(tester, const {});

      expect(render.cellRects, isEmpty);
    });
  });
}
