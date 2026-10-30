import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/scaffold_widget.dart';

void main() {
  group('ScaffoldWidget', () {
    testWidgets('drawer 슬롯과 resize·FAB 위치 prop을 전달한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {
                  'resize_to_avoid_bottom_inset': false,
                  'floating_action_button_location': 'center_float',
                },
                const {
                  'drawer': Text('서랍'),
                  'floating_action_button': Text('FAB'),
                },
              ),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      expect(scaffold.resizeToAvoidBottomInset, isFalse);
      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.centerFloat,
      );
    });

    testWidgets('body 슬롯을 항상 SafeArea로 감싼다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {},
                const {'body': Text('본문')},
              ),
            ),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('본문'), matching: find.byType(SafeArea)),
      );
      // Scaffold가 앱바 유무에 맞춰 body의 상단 padding을 이미 제거하므로 상단을
      // 켜도 이중 여백이 없다. 하단은 스크롤이 inset 밑까지 흐르도록 기본으로 끈다.
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);
    });

    testWidgets('extend_body·extend_body_behind_app_bar면 해당 엣지 인셋을 끈다', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1,
            child: Builder(
              builder: (context) => ScaffoldWidget.build(
                context,
                const {'extend_body': true, 'extend_body_behind_app_bar': true},
                const {'body': Text('본문')},
              ),
            ),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('본문'), matching: find.byType(SafeArea)),
      );
      // 템플릿이 명시적으로 그 엣지 뒤로 body를 확장하려는 것이므로 인셋을 끈다.
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isFalse);
    });

    group('inset 규칙', () {
      const body = Key('body');

      Future<void> pump(
        WidgetTester tester,
        EdgeInsets padding, {
        Map<String, Object?> props = const {},
        Map<String, Widget> slots = const {},
      }) => tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(800, 600),
              padding: padding,
              viewPadding: padding,
            ),
            child: EngineMetrics(
              scale: 1,
              child: Builder(
                builder: (context) => ScaffoldWidget.build(context, props, {
                  'body': const SizedBox.expand(key: body),
                  ...slots,
                }),
              ),
            ),
          ),
        ),
      );

      // iOS 홈 인디케이터, Android 제스처 내비, 3버튼 내비.
      for (final inset in const [34.0, 24.0, 48.0]) {
        testWidgets('하단 $inset: body가 화면 하단까지 차고 하단 padding을 자식에게 남긴다', (
          tester,
        ) async {
          await pump(tester, EdgeInsets.only(top: 47, bottom: inset));

          expect(tester.getRect(find.byKey(body)).bottom, 600);
          final media = MediaQuery.of(tester.element(find.byKey(body)));
          expect(media.padding.bottom, inset);
        });

        testWidgets('하단 $inset: inset_bottom이면 이전처럼 하단을 깎는다', (tester) async {
          await pump(
            tester,
            EdgeInsets.only(top: 47, bottom: inset),
            props: const {'inset_bottom': true},
          );

          expect(tester.getRect(find.byKey(body)).bottom, 600 - inset);
        });
      }

      testWidgets('위·좌·우 inset은 그대로 깎는다', (tester) async {
        await pump(tester, const EdgeInsets.fromLTRB(44, 47, 40, 34));

        expect(
          tester.getRect(find.byKey(body)),
          const Rect.fromLTRB(44, 47, 760, 600),
        );
      });

      testWidgets('app bar가 있으면 상단 inset을 다시 깎지 않는다', (tester) async {
        await pump(
          tester,
          const EdgeInsets.only(top: 47, bottom: 34),
          props: const {'app_bar_height': 56},
          slots: const {'app_bar': SizedBox()},
        );

        expect(tester.getRect(find.byKey(body)).top, 47 + 56);
      });

      testWidgets('extend_body면 inset_bottom이어도 하단을 깎지 않는다', (tester) async {
        await pump(
          tester,
          const EdgeInsets.only(bottom: 34),
          props: const {'extend_body': true, 'inset_bottom': true},
        );

        expect(tester.getRect(find.byKey(body)).bottom, 600);
      });

      testWidgets('하단 슬롯이 있으면 body 하단 padding은 0이다', (tester) async {
        await pump(
          tester,
          const EdgeInsets.only(bottom: 34),
          slots: const {'bottom_navigation_bar': SizedBox(height: 60)},
        );

        final media = MediaQuery.of(tester.element(find.byKey(body)));
        expect(media.padding.bottom, 0);
      });
    });

    group('cover_bottom_inset', () {
      const body = Key('body');
      final android = TargetPlatformVariant.only(TargetPlatform.android);
      final ios = TargetPlatformVariant.only(TargetPlatform.iOS);

      /// 실제 기기 하단 inset(View)과 앱 셸이 부풀린 MediaQuery를 따로 준다.
      Future<void> pump(
        WidgetTester tester, {
        double real = 48,
        double? media,
        double keyboard = 0,
        Map<String, Object?> props = const {},
        Map<String, Widget> slots = const {},
        Widget content = const SizedBox.expand(key: body),
      }) {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = const Size(2400, 1800);
        tester.view.padding = FakeViewPadding(bottom: real * 3);
        tester.view.viewPadding = FakeViewPadding(bottom: real * 3);
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard * 3);
        addTearDown(tester.view.reset);
        final bottom = keyboard > 0 ? 0.0 : (media ?? real);
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF123456)),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: EdgeInsets.only(bottom: bottom),
                  viewPadding: EdgeInsets.only(bottom: bottom),
                ),
                child: EngineMetrics(
                  scale: 1,
                  child: Builder(
                    builder: (context) => ScaffoldWidget.build(context, props, {
                      'body': content,
                      ...slots,
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      Finder strip() => find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is IgnorePointer && w.child is ColoredBox,
        ),
        matching: find.byType(ColoredBox),
      );

      testWidgets('Android: body 하단에 실제 inset 높이의 불투명 띠를 그린다', (tester) async {
        await pump(tester);

        expect(tester.getRect(strip()), const Rect.fromLTRB(0, 552, 800, 600));
        expect(tester.getRect(find.byKey(body)).bottom, 600);
      }, variant: android);

      testWidgets('iOS 기본값은 띠를 그리지 않는다', (tester) async {
        await pump(tester);

        expect(strip(), findsNothing);
      }, variant: ios);

      testWidgets('cover_bottom_inset: true면 iOS에서도 그린다', (tester) async {
        await pump(tester, real: 34, props: const {'cover_bottom_inset': true});

        expect(tester.getRect(strip()), const Rect.fromLTRB(0, 566, 800, 600));
      }, variant: ios);

      testWidgets('cover_bottom_inset: false면 Android에서도 그리지 않는다', (
        tester,
      ) async {
        await pump(tester, props: const {'cover_bottom_inset': false});

        expect(strip(), findsNothing);
      }, variant: android);

      testWidgets('앱 셸이 MediaQuery 하단 padding을 부풀려도 띠는 실제 inset 높이다', (
        tester,
      ) async {
        await pump(tester, real: 48, media: 48 + 80);

        expect(tester.getSize(strip()).height, 48);
        final media = MediaQuery.of(tester.element(find.byKey(body)));
        expect(media.padding.bottom, 128);
      }, variant: android);

      testWidgets('상위가 하단 padding을 이미 소비했으면 띠 높이가 0이다', (tester) async {
        await pump(tester, real: 48, media: 0);

        expect(tester.getSize(strip()).height, 0);
      }, variant: android);

      testWidgets('띠 색은 background_color, 없으면 테마 scaffold 배경이다', (
        tester,
      ) async {
        await pump(tester);
        expect(
          tester.widget<ColoredBox>(strip()).color,
          const Color(0xFF123456),
        );

        await pump(tester, props: const {'background_color': '#FFAA0000'});
        expect(
          tester.widget<ColoredBox>(strip()).color,
          const Color(0xFFAA0000),
        );
      }, variant: android);

      testWidgets('키보드가 올라오면 띠 높이가 0이고 body 상태는 유지된다', (tester) async {
        final field = GlobalKey();
        Widget content() => SizedBox.expand(
          key: body,
          child: Text('x', key: field),
        );
        await pump(tester, content: content());
        final before = field.currentContext;

        await pump(tester, keyboard: 300, content: content());

        expect(tester.getSize(strip()).height, 0);
        expect(field.currentContext, same(before));
      }, variant: android);

      testWidgets('bottom_navigation_bar 슬롯이 있으면 그리지 않는다', (tester) async {
        await pump(
          tester,
          slots: const {'bottom_navigation_bar': SizedBox(height: 60)},
        );

        expect(strip(), findsNothing);
      }, variant: android);

      testWidgets('inset_bottom이면 그리지 않는다', (tester) async {
        await pump(tester, props: const {'inset_bottom': true});

        expect(strip(), findsNothing);
      }, variant: android);

      testWidgets('띠는 탭을 막지 않는다', (tester) async {
        var taps = 0;
        await pump(
          tester,
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox.expand(key: body),
          ),
        );

        await tester.tapAt(const Offset(400, 590));
        expect(taps, 1);
      }, variant: android);

      testWidgets('작은 body의 위치는 바뀌지 않는다', (tester) async {
        await pump(
          tester,
          content: const SizedBox(key: body, width: 100, height: 40),
        );

        expect(
          tester.getRect(find.byKey(body)),
          const Rect.fromLTRB(0, 0, 100, 40),
        );
        expect(tester.getRect(strip()).bottom, 600);
      }, variant: android);
    });
  });
}
