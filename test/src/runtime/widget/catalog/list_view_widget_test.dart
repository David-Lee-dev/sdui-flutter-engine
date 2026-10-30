import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/list_view_widget.dart';
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
        builder: (context) => ListViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('ListViewWidget', () {
    group('build', () {
      testWidgets(
        'scrollDirection·itemExtent·shrinkWrap을 읽는다(itemExtent scale)',
        (tester) async {
          await _pump(
            tester,
            const {
              'scroll_direction': 'horizontal',
              'item_extent': 100,
              'shrink_wrap': true,
            },
            children: [const Text('a'), const Text('b')],
            scale: 0.5,
          );
          final v = tester.widget<ListView>(find.byType(ListView));
          expect(v.scrollDirection, Axis.horizontal);
          expect(v.itemExtent, 50);
          expect(v.shrinkWrap, isTrue);
        },
      );

      testWidgets('명시된 자식을 그대로 렌더한다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('a'), const Text('b')],
        );
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
      });

      testWidgets('primary·keyboardDismissBehavior·clipBehavior를 전달한다', (
        tester,
      ) async {
        await _pump(tester, const {
          'primary': false,
          'keyboard_dismiss_behavior': 'on_drag',
          'clip_behavior': 'none',
        });
        final view = tester.widget<ListView>(find.byType(ListView));
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
                builder: (context) => ListViewWidget.build(context, props, [
                  const SizedBox(key: child, width: 10, height: 10),
                ]),
              ),
            ),
          ),
        ),
      );

      ListView view(WidgetTester tester) =>
          tester.widget(find.byType(ListView));

      EdgeInsets childPadding(WidgetTester tester) =>
          MediaQuery.of(tester.element(find.byKey(child))).padding;

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
          expect(childPadding(tester).bottom, 0);
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
        expect(tester.getTopLeft(find.byKey(child)).dy, 0);
      });

      testWidgets('reverse여도 inset은 화면 하단 쪽에 둔다', (tester) async {
        await pump(tester, const {'reverse': true});

        expect(view(tester).padding, const EdgeInsets.only(bottom: 34));
        expect(tester.getBottomLeft(find.byKey(child)).dy, 600 - 34);
      });

      testWidgets('가로 리스트는 Flutter 기본 padding 처리를 그대로 둔다', (tester) async {
        await pump(tester, const {'scroll_direction': 'horizontal'});

        expect(view(tester).padding, isNull);
        expect(childPadding(tester).bottom, 34);
      });

      testWidgets('inset_end: false면 inset을 더하지도 지우지도 않는다', (tester) async {
        await pump(tester, const {'inset_end': false});

        expect(view(tester).padding, EdgeInsets.zero);
        expect(childPadding(tester).bottom, 34);
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
                      builder: (context) => ListViewWidget.build(
                        context,
                        const {},
                        [const SizedBox(key: child, width: 10, height: 10)],
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
          tester.widget<ListView>(find.byType(ListView)).padding,
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
