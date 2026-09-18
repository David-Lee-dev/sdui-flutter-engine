import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/expanded_widget.dart';
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
      child: Column(
        children: [
          Builder(
            builder: (context) =>
                ExpandedWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('ExpandedWidget', () {
    group('build', () {
      testWidgets('flex 기본은 1', (tester) async {
        await _pump(tester, const {});
        expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 1);
      });

      testWidgets('flex를 읽는다', (tester) async {
        await _pump(tester, const {'flex': 3});
        expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 3);
      });

      testWidgets('자식이 없으면 SizedBox.shrink로 관대하게(Expanded.child는 필수)', (
        tester,
      ) async {
        await _pump(tester, const {});
        expect(
          tester.widget<Expanded>(find.byType(Expanded)).child,
          isA<SizedBox>(),
        );
      });
    });
  });
}
