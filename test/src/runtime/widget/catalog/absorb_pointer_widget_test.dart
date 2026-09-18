import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/absorb_pointer_widget.dart';
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
            AbsorbPointerWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('AbsorbPointerWidget', () {
    testWidgets('child를 렌더링한다', (tester) async {
      await _pump(tester, const {}, children: const [Text('child')]);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('absorbing 기본은 true이고 false로 설정할 수 있다', (tester) async {
      await _pump(tester, const {});
      expect(
        tester.widget<AbsorbPointer>(find.byType(AbsorbPointer)).absorbing,
        isTrue,
      );

      await _pump(tester, const {'absorbing': false});
      expect(
        tester.widget<AbsorbPointer>(find.byType(AbsorbPointer)).absorbing,
        isFalse,
      );
    });
  });
}
