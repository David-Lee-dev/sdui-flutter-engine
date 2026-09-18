import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/ignore_pointer_widget.dart';
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
            IgnorePointerWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('IgnorePointerWidget', () {
    testWidgets('child를 렌더링한다', (tester) async {
      await _pump(tester, const {}, children: const [Text('child')]);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('ignoring 기본은 true이고 false로 설정할 수 있다', (tester) async {
      await _pump(tester, const {});
      expect(
        tester.widget<IgnorePointer>(find.byType(IgnorePointer)).ignoring,
        isTrue,
      );

      await _pump(tester, const {'ignoring': false});
      expect(
        tester.widget<IgnorePointer>(find.byType(IgnorePointer)).ignoring,
        isFalse,
      );
    });
  });
}
