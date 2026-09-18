import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/rotated_box_widget.dart';
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
        builder: (context) => RotatedBoxWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('RotatedBoxWidget', () {
    group('build', () {
      testWidgets('quarterTurns를 읽는다', (tester) async {
        await _pump(
          tester,
          const {'quarter_turns': 1},
          children: [const Text('a')],
        );
        expect(
          tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
          1,
        );
      });

      testWidgets('quarterTurns 기본은 0', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester.widget<RotatedBox>(find.byType(RotatedBox)).quarterTurns,
          0,
        );
      });
    });
  });
}
