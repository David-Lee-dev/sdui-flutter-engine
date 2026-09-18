import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/overflow_bar_widget.dart';
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
        builder: (context) => OverflowBarWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('OverflowBarWidget', () {
    group('build', () {
      testWidgets('spacing이 scale되고 overflowAlignment을 읽는다', (tester) async {
        await _pump(tester, const {
          'spacing': 20,
          'overflow_alignment': 'center',
        }, scale: 0.5);
        final bar = tester.widget<OverflowBar>(find.byType(OverflowBar));
        expect(bar.spacing, 10);
        expect(bar.overflowAlignment, OverflowBarAlignment.center);
      });

      testWidgets('기본은 spacing 0·overflowAlignment start·down', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final bar = tester.widget<OverflowBar>(find.byType(OverflowBar));
        expect(bar.spacing, 0.0);
        expect(bar.overflowAlignment, OverflowBarAlignment.start);
        expect(bar.overflowDirection, VerticalDirection.down);
      });
    });
  });
}
