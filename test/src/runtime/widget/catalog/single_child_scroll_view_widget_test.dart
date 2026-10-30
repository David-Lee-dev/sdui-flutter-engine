import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/single_child_scroll_view_widget.dart';
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
        builder: (context) =>
            SingleChildScrollViewWidget.build(context, props, children),
      ),
    ),
  ),
);

void main() {
  group('SingleChildScrollViewWidget', () {
    group('build', () {
      testWidgets('scrollDirection·padding·physics를 읽는다(padding scale)', (
        tester,
      ) async {
        await _pump(tester, const {
          'scroll_direction': 'horizontal',
          'padding': 20,
          'physics': 'never',
        }, scale: 0.5);
        final v = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        expect(v.scrollDirection, Axis.horizontal);
        expect(v.padding, const EdgeInsets.all(10));
        expect(v.physics, isA<NeverScrollableScrollPhysics>());
      });

      testWidgets('scrollDirection 기본은 vertical', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .scrollDirection,
          Axis.vertical,
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
        final view = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
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
        Widget content = const SizedBox(key: child, height: 100),
      }) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: media,
            child: EngineMetrics(
              scale: 1,
              child: Builder(
                builder: (context) => SingleChildScrollViewWidget.build(
                  context,
                  props,
                  [content],
                ),
              ),
            ),
          ),
        ),
      );

      SingleChildScrollView view(WidgetTester tester) =>
          tester.widget(find.byType(SingleChildScrollView));

      double childBottom(WidgetTester tester) =>
          MediaQuery.of(tester.element(find.byKey(child))).padding.bottom;

      // iOS 홈 인디케이터, Android 제스처 내비, 3버튼 내비.
      for (final inset in const [34.0, 24.0, 48.0]) {
        testWidgets('하단 $inset: 끝 여백은 템플릿 padding + inset이고 자식 하단은 0', (
          tester,
        ) async {
          await pump(tester, const {
            'padding': 16,
          }, media: MediaQueryData(padding: EdgeInsets.only(bottom: inset)));

          expect(
            view(tester).padding,
            EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
          );
          expect(childBottom(tester), 0);
        });
      }

      testWidgets('padding이 없으면 하단 inset만 준다', (tester) async {
        await pump(tester, const {});

        expect(view(tester).padding, const EdgeInsets.only(bottom: 34));
      });

      testWidgets('안쪽 safe_area(top:false) + 8 우회 패턴은 8만 남는다', (tester) async {
        await pump(
          tester,
          const {},
          content: const Column(
            key: child,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 100),
              SafeArea(top: false, child: SizedBox(height: 8)),
            ],
          ),
        );

        expect(tester.getSize(find.byKey(child)).height, 108);
      });

      testWidgets('reverse여도 inset은 화면 하단 쪽에 둔다', (tester) async {
        await pump(tester, const {'reverse': true, 'padding': 16});

        expect(view(tester).padding, const EdgeInsets.fromLTRB(16, 16, 16, 50));
      });

      testWidgets('키보드가 올라와 padding이 0이면 끝 여백도 템플릿 padding뿐이다', (tester) async {
        await pump(
          tester,
          const {'padding': 16},
          media: const MediaQueryData(
            viewPadding: EdgeInsets.only(bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
        );

        expect(view(tester).padding, const EdgeInsets.all(16));
      });

      testWidgets('가로 스크롤은 padding과 자식 inset을 바꾸지 않는다', (tester) async {
        await pump(tester, const {'scroll_direction': 'horizontal'});

        expect(view(tester).padding, isNull);
        expect(childBottom(tester), 34);
      });

      testWidgets('inset_end: false면 padding과 자식 inset을 바꾸지 않는다', (
        tester,
      ) async {
        await pump(tester, const {'inset_end': false, 'padding': 16});

        expect(view(tester).padding, const EdgeInsets.all(16));
        expect(childBottom(tester), 34);
      });

      testWidgets('중첩 스크롤은 바깥에서만 inset을 한 번 더한다', (tester) async {
        await pump(
          tester,
          const {},
          content: Builder(
            builder: (context) => SingleChildScrollViewWidget.build(
              context,
              const {},
              [const SizedBox(key: child, height: 100)],
            ),
          ),
        );

        final views = tester
            .widgetList<SingleChildScrollView>(
              find.byType(SingleChildScrollView),
            )
            .toList();
        expect(views.first.padding, const EdgeInsets.only(bottom: 34));
        expect(views.last.padding, EdgeInsets.zero);
      });
    });

    group('하단 inset 자동 판단', () {
      const content = Key('content');

      MediaQueryData screen([double inset = 34]) => MediaQueryData(
        size: const Size(800, 600),
        padding: EdgeInsets.only(bottom: inset),
      );

      Widget scroll(Map<String, Object?> props) => Builder(
        builder: (context) => SingleChildScrollViewWidget.build(
          context,
          props,
          [const _Stateful(key: content)],
        ),
      );

      Future<void> mount(
        WidgetTester tester,
        Widget Function(Widget scroll) layout, {
        Map<String, Object?> props = const {'padding': 16},
        MediaQueryData? media,
      }) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: media ?? screen(),
            child: EngineMetrics(scale: 1, child: layout(scroll(props))),
          ),
        ),
      );

      EdgeInsetsGeometry? padding(WidgetTester tester) => tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .padding;

      double contentBottom(WidgetTester tester) =>
          MediaQuery.of(tester.element(find.byKey(content))).padding.bottom;

      // 판단 보정에 한 프레임을 주고, 그 뒤로는 프레임이 이어지지 않아야 한다
      // (Scrollable은 첫 프레임 뒤에 한 프레임을 스스로 예약한다).
      Future<void> settled(WidgetTester tester) async {
        await tester.pump();
        await tester.pump();
        expect(tester.binding.hasScheduledFrame, isFalse);
      }

      Widget withCta(Widget scroll) => Column(
        children: [
          Expanded(child: scroll),
          const SafeArea(top: false, child: SizedBox(height: 56)),
        ],
      );

      for (final inset in const [34.0, 24.0, 48.0]) {
        testWidgets('화면 하단까지 닿으면 첫 프레임부터 inset $inset을 더하고 그대로 둔다', (
          tester,
        ) async {
          await mount(tester, (scroll) => scroll, media: screen(inset));

          final expected = EdgeInsets.fromLTRB(16, 16, 16, 16 + inset);
          expect(padding(tester), expected);
          expect(contentBottom(tester), 0);
          await settled(tester);
          expect(padding(tester), expected);
        });
      }

      testWidgets('column[expanded(scv), 하단 CTA]는 끝 여백에 inset을 더하지 않는다', (
        tester,
      ) async {
        await mount(tester, withCta);
        await settled(tester);

        expect(padding(tester), const EdgeInsets.all(16));
        expect(contentBottom(tester), 34);
      });

      testWidgets('가운데 dialog 안의 scv는 inset을 더하지 않는다', (tester) async {
        await mount(
          tester,
          (scroll) =>
              Center(child: SizedBox(width: 300, height: 300, child: scroll)),
        );
        await tester.pump();

        expect(padding(tester), const EdgeInsets.all(16));
        expect(contentBottom(tester), 34);
      });

      testWidgets('화면 하단에 붙은 sheet 안의 scv는 첫 프레임에 inset을 더한다', (tester) async {
        await mount(
          tester,
          (scroll) => Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(height: 300, child: scroll),
          ),
        );

        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
        await settled(tester);
        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
      });

      testWidgets('inset_end: true면 하단에 닿지 않아도 inset을 더한다', (tester) async {
        await mount(
          tester,
          withCta,
          props: const {'padding': 16, 'inset_end': true},
        );
        await tester.pump();

        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
        expect(contentBottom(tester), 0);
      });

      testWidgets('inset_end: false면 하단에 닿아도 inset을 더하지 않는다', (tester) async {
        await mount(
          tester,
          (scroll) => scroll,
          props: const {'padding': 16, 'inset_end': false},
        );
        await tester.pump();

        expect(padding(tester), const EdgeInsets.all(16));
        expect(contentBottom(tester), 34);
      });

      testWidgets('하단 바가 생기고 사라지면 판단이 바뀌고 자식 상태는 유지된다', (tester) async {
        final bar = ValueNotifier(false);
        addTearDown(bar.dispose);
        await mount(
          tester,
          (scroll) => ValueListenableBuilder<bool>(
            valueListenable: bar,
            builder: (context, shown, _) => Column(
              children: [
                Expanded(child: scroll),
                if (shown) const SizedBox(height: 60),
              ],
            ),
          ),
        );
        final state = tester.state(find.byKey(content));
        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));

        bar.value = true;
        await settled(tester);
        expect(padding(tester), const EdgeInsets.all(16));
        expect(contentBottom(tester), 34);

        bar.value = false;
        await settled(tester);
        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
        expect(contentBottom(tester), 0);
        expect(tester.state(find.byKey(content)), same(state));
      });

      testWidgets('페이지 전환처럼 scale 변환이 걸려도 레이아웃 위치로 판단한다', (tester) async {
        await mount(
          tester,
          (scroll) => Transform.scale(scale: 0.8, child: scroll),
        );
        await tester.pump();

        expect(padding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
      });
    });
  });
}

class _Stateful extends StatefulWidget {
  const _Stateful({super.key});

  @override
  State<_Stateful> createState() => _StatefulState();
}

class _StatefulState extends State<_Stateful> {
  @override
  Widget build(BuildContext context) => const SizedBox(height: 100);
}
