import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/scrollbar_widget.dart';
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
        builder: (context) => ScrollbarWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ScrollbarWidget', () {
    group('build', () {
      testWidgets('thumbVisibility·thickness를 읽는다(thickness scale)', (
        tester,
      ) async {
        // thumbVisibility:true는 항상 위치를 알아야 해 ScrollController가 필요하다(Flutter 요건).
        // 자식 스크롤뷰를 primary로 두고 PrimaryScrollController를 조상에 심어 배선한다.
        final controller = ScrollController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: EngineMetrics(
              scale: 0.5,
              child: PrimaryScrollController(
                controller: controller,
                child: Builder(
                  builder: (context) => ScrollbarWidget.build(
                    context,
                    const {'thumb_visibility': true, 'thickness': 8},
                    [
                      const SingleChildScrollView(
                        primary: true,
                        child: SizedBox(height: 2000),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final bar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
        expect(bar.thumbVisibility, isTrue);
        expect(bar.thickness, 4);
      });

      testWidgets('자식이 없으면 SizedBox.shrink로 관대하게', (tester) async {
        await _pump(tester, const {});
        expect(
          tester.widget<RawScrollbar>(find.byType(RawScrollbar)).child,
          isA<SizedBox>(),
        );
      });

      testWidgets('interactive·trackVisibility·trackColor를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'interactive': false,
          'track_visibility': false,
          'track_color': '#FF123456',
        });
        final bar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
        expect(bar.interactive, isFalse);
        expect(bar.trackVisibility, isFalse);
        expect(bar.trackColor, const Color(0xFF123456));
      });
    });
  });
}
