import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/stack_widget.dart';
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
        builder: (context) => StackWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('StackWidget', () {
    group('build', () {
      testWidgets(
        '기본은 AlignmentDirectional.topStart/StackFit.loose/Clip.hardEdge',
        (tester) async {
          await _pump(tester, const {});
          final stack = tester.widget<Stack>(find.byType(Stack));
          expect(stack.alignment, AlignmentDirectional.topStart);
          expect(stack.fit, StackFit.loose);
          expect(stack.clipBehavior, Clip.hardEdge);
        },
      );

      testWidgets('props를 읽는다', (tester) async {
        await _pump(tester, const {
          'alignment': 'center',
          'fit': 'expand',
          'clip_behavior': 'none',
          'text_direction': 'rtl',
        });
        final stack = tester.widget<Stack>(find.byType(Stack));
        expect(stack.alignment, Alignment.center);
        expect(stack.fit, StackFit.expand);
        expect(stack.clipBehavior, Clip.none);
        expect(stack.textDirection, TextDirection.rtl);
      });
    });
  });
}
