import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/grid_view_widget.dart';
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
        builder: (context) => GridViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('GridViewWidget', () {
    group('build', () {
      testWidgets('crossAxisCount·spacing을 격자 delegate로 반영(spacing scale)', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'cross_axis_count': 3, 'main_axis_spacing': 20},
          children: [const Text('a')],
          scale: 0.5,
        );
        final delegate =
            tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 3);
        expect(delegate.mainAxisSpacing, 10);
      });

      testWidgets('crossAxisCount 기본은 2', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        final delegate =
            tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, 2);
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<GridView>(find.byType(GridView));
        expect(view.primary, isFalse);
        expect(
          view.keyboardDismissBehavior,
          ScrollViewKeyboardDismissBehavior.onDrag,
        );
        expect(view.clipBehavior, Clip.none);
      });
    });

    group('하단 inset', () {
      const child = Key('child');

      Future<void> pump(
        WidgetTester tester,
        Map<String, Object?> props, {
        EdgeInsets padding = const EdgeInsets.only(bottom: 34),
      }) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(padding: padding),
            child: EngineMetrics(
              scale: 1,
              child: Builder(
                builder: (context) => GridViewWidget.build(context, props, [
                  const SizedBox(key: child),
                ]),
              ),
            ),
          ),
        ),
      );

      GridView view(WidgetTester tester) =>
          tester.widget(find.byType(GridView));

      double childBottom(WidgetTester tester) =>
          MediaQuery.of(tester.element(find.byKey(child))).padding.bottom;

      // iOS 홈 인디케이터, Android 제스처 내비, 3버튼 내비.
      for (final inset in const [34.0, 24.0, 48.0]) {
        testWidgets('하단 $inset: 끝 여백은 템플릿 padding + inset이고 자식 하단은 0', (
          tester,
        ) async {
          await pump(tester, const {
            'padding': 16,
          }, padding: EdgeInsets.only(bottom: inset));

          expect(
            view(tester).padding,
            EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
          );
          expect(childBottom(tester), 0);
        });
      }

      testWidgets('padding이 없으면 하단 inset만 주고 상단 자동 padding은 없다', (
        tester,
      ) async {
        await pump(
          tester,
          const {},
          padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
        );

        expect(view(tester).padding, const EdgeInsets.only(bottom: 34));
      });

      testWidgets('가로 그리드는 Flutter 기본 padding 처리를 그대로 둔다', (tester) async {
        await pump(tester, const {'scroll_direction': 'horizontal'});

        expect(view(tester).padding, isNull);
        expect(childBottom(tester), 34);
      });

      testWidgets('inset_end: false면 inset을 더하지도 지우지도 않는다', (tester) async {
        await pump(tester, const {'inset_end': false});

        expect(view(tester).padding, EdgeInsets.zero);
        expect(childBottom(tester), 34);
      });
      testWidgets('가운데 dialog 안에서는 화면 하단에 닿지 않아 inset을 더하지 않는다', (
        tester,
      ) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 600),
                padding: EdgeInsets.only(bottom: 34),
              ),
              child: EngineMetrics(
                scale: 1,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Builder(
                      builder: (context) => GridViewWidget.build(
                        context,
                        const {},
                        [const SizedBox(key: child)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.widget<GridView>(find.byType(GridView)).padding,
          EdgeInsets.zero,
        );
        expect(
          MediaQuery.of(tester.element(find.byKey(child))).padding.bottom,
          34,
        );
      });
    });
  });
}
