import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/positioned_widget.dart';
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
      child: Stack(
        children: [
          Builder(
            builder: (context) =>
                PositionedWidget.build(context, props, children),
          ),
        ],
      ),
    ),
  ),
);

void main() {
  group('PositionedWidget', () {
    group('build', () {
      testWidgets('left·top·width·height가 scale된다', (tester) async {
        // right/bottom은 Flutter의 Positioned가 width·left와 동시 지정을 assert로
        // 막는 조합(left+right+width 등)이라 여기선 겹치지 않는 성분만 함께 지정한다.
        await _pump(tester, const {
          'left': 10,
          'top': 20,
          'width': 50,
          'height': 60,
        }, scale: 0.5);
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.left, 5);
        expect(positioned.top, 10);
        expect(positioned.width, 25);
        expect(positioned.height, 30);
      });

      testWidgets('right·bottom도 scale된다', (tester) async {
        await _pump(tester, const {'right': 30, 'bottom': 40}, scale: 0.5);
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.right, 15);
        expect(positioned.bottom, 20);
      });

      testWidgets('음수 top·right 오프셋을 보존한다', (tester) async {
        await _pump(tester, const {'top': -6, 'right': -6});
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.top, -6);
        expect(positioned.right, -6);
      });

      testWidgets('자식이 없으면 SizedBox.shrink로 관대하게(Positioned.child는 필수)', (
        tester,
      ) async {
        await _pump(tester, const {});
        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.child, isA<SizedBox>());
      });
    });
  });
}
