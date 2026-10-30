import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/custom_scroll_view_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> slivers = const [],
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            CustomScrollViewWidget.build(context, props, slivers),
      ),
    ),
  ),
);

void main() {
  group('CustomScrollViewWidget', () {
    group('build', () {
      testWidgets('명시된 sliver 자식을 slivers로 넘긴다', (tester) async {
        await _pump(
          tester,
          const {},
          slivers: [const SliverToBoxAdapter(child: Text('a'))],
        );
        expect(find.text('a'), findsOneWidget);
      });

      testWidgets('scrollDirection을 읽는다', (tester) async {
        await _pump(
          tester,
          const {'scroll_direction': 'horizontal'},
          slivers: [const SliverToBoxAdapter(child: SizedBox())],
        );
        expect(
          tester
              .widget<CustomScrollView>(find.byType(CustomScrollView))
              .scrollDirection,
          Axis.horizontal,
        );
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
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
        MediaQueryData media = const MediaQueryData(
          padding: EdgeInsets.only(bottom: 34),
        ),
        double height = 1000,
      }) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: media,
            child: EngineMetrics(
              scale: 1,
              child: Builder(
                builder: (context) =>
                    CustomScrollViewWidget.build(context, props, [
                      SliverToBoxAdapter(
                        child: SizedBox(
                          key: child,
                          width: height,
                          height: height,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      );

      double maxExtent(WidgetTester tester) => tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .maxScrollExtent;

      double childBottom(WidgetTester tester) =>
          MediaQuery.of(tester.element(find.byKey(child))).padding.bottom;

      // iOS 홈 인디케이터, Android 제스처 내비, 3버튼 내비.
      for (final inset in const [34.0, 24.0, 48.0]) {
        testWidgets('하단 $inset: 끝에 inset 높이를 더하고 sliver 하단은 0', (tester) async {
          await pump(
            tester,
            const {},
            media: MediaQueryData(padding: EdgeInsets.only(bottom: inset)),
          );

          expect(maxExtent(tester), 1000 + inset - 600);
          expect(childBottom(tester), 0);
        });
      }

      testWidgets('sliver_fill_remaining은 viewport를 채우고 inset만큼 스크롤된다', (
        tester,
      ) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
              child: EngineMetrics(
                scale: 1,
                child: Builder(
                  builder: (context) => CustomScrollViewWidget.build(
                    context,
                    const {},
                    [const SliverFillRemaining(child: SizedBox(key: child))],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.getSize(find.byKey(child)).height, 600);
        expect(maxExtent(tester), 34);
      });

      testWidgets('reverse여도 inset은 화면 하단 쪽에 둔다', (tester) async {
        await pump(tester, const {'reverse': true}, height: 100);

        expect(tester.getBottomLeft(find.byKey(child)).dy, 600 - 34);
      });

      testWidgets('키보드가 올라와 padding이 0이면 끝 여백도 0이다', (tester) async {
        await pump(
          tester,
          const {},
          media: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
        );

        expect(maxExtent(tester), 1000 - 600);
      });

      testWidgets('가로 스크롤은 여백을 더하지도 inset을 지우지도 않는다', (tester) async {
        await pump(tester, const {'scroll_direction': 'horizontal'});

        expect(maxExtent(tester), 1000 - 800);
        expect(childBottom(tester), 34);
      });

      testWidgets('inset_end: false면 여백을 더하지도 inset을 지우지도 않는다', (tester) async {
        await pump(tester, const {'inset_end': false});

        expect(maxExtent(tester), 1000 - 600);
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
                      builder: (context) =>
                          CustomScrollViewWidget.build(context, const {}, [
                            const SliverToBoxAdapter(
                              child: SizedBox(key: child, height: 1000),
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable))
              .position
              .maxScrollExtent,
          1000 - 300,
        );
        expect(
          MediaQuery.of(tester.element(find.byKey(child))).padding.bottom,
          34,
        );
      });
    });
  });
}
