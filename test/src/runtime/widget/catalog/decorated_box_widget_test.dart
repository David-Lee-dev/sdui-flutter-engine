import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/decorated_box_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            DecoratedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('DecoratedBoxWidget', () {
    group('build', () {
      testWidgets('decoration을 읽는다', (tester) async {
        await _pump(tester, const {
          'decoration': {'color': '#FF0000'},
        });
        final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
        expect(
          (box.decoration as BoxDecoration).color,
          const Color(0xFFFF0000),
        );
      });

      testWidgets('decoration 없으면 빈 BoxDecoration', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration,
          const BoxDecoration(),
        );
      });

      testWidgets('position: foreground를 전달한다', (tester) async {
        await _pump(tester, const {'position': 'foreground'});
        expect(
          tester.widget<DecoratedBox>(find.byType(DecoratedBox)).position,
          DecorationPosition.foreground,
        );
      });
    });
  });
}
