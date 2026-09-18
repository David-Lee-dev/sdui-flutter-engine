import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/adaptive_radius.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/clip_rrect_widget.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  double scale = 1.0,
  Widget Function(Widget child)? wrap,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: scale,
      child: Builder(
        builder: (context) {
          final child = ClipRRectWidget.build(context, props, children);
          return wrap == null ? child : wrap(child);
        },
      ),
    ),
  ),
);

void main() {
  group('ClipRRectWidget', () {
    group('build', () {
      testWidgets('기본은 BorderRadius.zero/Clip.antiAlias', (tester) async {
        await _pump(tester, const {});
        final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
        expect(clip.borderRadius, BorderRadius.zero);
        expect(clip.clipBehavior, Clip.antiAlias);
      });

      testWidgets('borderRadius가 scale된다', (tester) async {
        await _pump(tester, const {'border_radius': 20}, scale: 0.5);
        expect(
          tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius,
          BorderRadius.circular(10),
        );
      });

      testWidgets('auto는 실제 렌더 크기로 radius를 계산한다', (tester) async {
        await _pump(
          tester,
          const {'border_radius': 'auto'},
          children: [const SizedBox(width: 100, height: 100)],
          wrap: (child) => Center(child: child),
        );
        await tester.pump();

        final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
        final measuredSize = tester.getSize(find.byType(ClipRRect));
        expect(
          clip.borderRadius,
          BorderRadius.circular(AdaptiveRadius.compute(measuredSize)),
        );
      });
    });
  });
}
