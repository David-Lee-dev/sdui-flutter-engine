import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/clip_oval_widget.dart';
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
        builder: (context) => ClipOvalWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ClipOvalWidget', () {
    group('build', () {
      testWidgets('자식을 감싸고 clipBehavior 기본은 antiAlias', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(find.text('a'), findsOneWidget);
        expect(
          tester.widget<ClipOval>(find.byType(ClipOval)).clipBehavior,
          Clip.antiAlias,
        );
      });

      testWidgets('clipBehavior를 읽는다', (tester) async {
        await _pump(tester, const {'clip_behavior': 'hard_edge'});
        expect(
          tester.widget<ClipOval>(find.byType(ClipOval)).clipBehavior,
          Clip.hardEdge,
        );
      });
    });
  });
}
