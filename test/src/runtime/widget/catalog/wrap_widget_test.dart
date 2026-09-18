import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/wrap_widget.dart';
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
        builder: (context) => WrapWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('WrapWidget', () {
    group('build', () {
      testWidgets('기본은 horizontal/start/start/0/0', (tester) async {
        await _pump(tester, const {});
        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.direction, Axis.horizontal);
        expect(wrap.alignment, WrapAlignment.start);
        expect(wrap.crossAxisAlignment, WrapCrossAlignment.start);
        expect(wrap.spacing, 0.0);
        expect(wrap.runSpacing, 0.0);
      });

      testWidgets('spacing·runSpacing은 scale된다', (tester) async {
        await _pump(tester, const {
          'spacing': 16,
          'run_spacing': 8,
        }, scale: 0.5);
        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.spacing, 8);
        expect(wrap.runSpacing, 4);
      });

      testWidgets('runAlignment·방향·clipBehavior를 전달한다', (tester) async {
        await _pump(tester, const {
          'run_alignment': 'space_between',
          'text_direction': 'rtl',
          'vertical_direction': 'up',
          'clip_behavior': 'hard_edge',
        });
        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.runAlignment, WrapAlignment.spaceBetween);
        expect(wrap.textDirection, TextDirection.rtl);
        expect(wrap.verticalDirection, VerticalDirection.up);
        expect(wrap.clipBehavior, Clip.hardEdge);
      });
    });
  });
}
