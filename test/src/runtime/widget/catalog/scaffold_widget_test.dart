import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/safe_area_widget.dart';
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

    testWidgets('body 슬롯을 SafeArea로 감싸지 않는다', (tester) async {
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

      expect(
        find.ancestor(of: find.text('본문'), matching: find.byType(SafeArea)),
        findsNothing,
      );
    });

    group('inset 규칙', () {
      const body = Key('body');
      const bar = Key('bar');

      /// 0.10.0의 하단 띠: 탭을 받지 않는 불투명 ColoredBox.
      Finder strip() => find.byWidgetPredicate(
        (w) => w is IgnorePointer && w.child is ColoredBox,
      );

      Future<void> pump(
        WidgetTester tester,
        EdgeInsets padding, {
        Map<String, Object?> props = const {},
        Map<String, Widget> slots = const {},
        Widget content = const SizedBox.expand(key: body),
        bool hostSafeArea = false,
      }) {
        Widget screen = EngineMetrics(
          scale: 1,
          child: Builder(
            builder: (context) => ScaffoldWidget.build(context, props, {
              'body': content,
              ...slots,
            }),
          ),
        );
        if (hostSafeArea) screen = SafeArea(bottom: false, child: screen);
        return tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(800, 600),
                padding: padding,
                viewPadding: padding,
              ),
              child: screen,
            ),
          ),
        );
      }

      // 0.10.1 특성화 값 그대로다. app_bar 틀은 화면 safe-area 정책이 아니라 바
      // 자신의 배치 규칙이다.
      testWidgets('app_bar는 상태바 아래 app_bar_height 높이로 그리고 body는 그 아래다', (
        tester,
      ) async {
        await pump(
          tester,
          const EdgeInsets.only(top: 47, bottom: 34),
          props: const {'app_bar_height': 56},
          slots: const {'app_bar': SizedBox.expand(key: bar)},
        );

        expect(
          tester.getRect(find.byKey(bar)),
          const Rect.fromLTRB(0, 47, 800, 103),
        );
        expect(
          tester.getRect(find.byKey(body)),
          const Rect.fromLTRB(0, 103, 800, 600),
        );
        final media = MediaQuery.of(tester.element(find.byKey(body)));
        expect(media.padding, const EdgeInsets.only(bottom: 34));
      });

      testWidgets('app_bar가 없으면 body가 상태바 밑을 포함한 화면 전체를 채운다', (tester) async {
        await pump(tester, const EdgeInsets.fromLTRB(44, 47, 40, 34));

        expect(
          tester.getRect(find.byKey(body)),
          const Rect.fromLTRB(0, 0, 800, 600),
        );
        // 소비하지 않은 inset은 템플릿의 safe_area·스크롤이 쓰도록 그대로 넘긴다.
        final media = MediaQuery.of(tester.element(find.byKey(body)));
        expect(media.padding, const EdgeInsets.fromLTRB(44, 47, 40, 34));
      });

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
      }

      testWidgets('extend_body_behind_app_bar면 body가 app_bar 뒤 화면 맨 위부터 그린다', (
        tester,
      ) async {
        await pump(
          tester,
          const EdgeInsets.only(top: 47, bottom: 34),
          props: const {
            'app_bar_height': 56,
            'extend_body_behind_app_bar': true,
          },
          slots: const {'app_bar': SizedBox.expand(key: bar)},
        );

        expect(tester.getRect(find.byKey(body)).top, 0);
        expect(
          tester.getRect(find.byKey(bar)),
          const Rect.fromLTRB(0, 47, 800, 103),
        );
      });

      testWidgets('extend_body면 body가 하단 슬롯 뒤 화면 하단까지 그린다', (tester) async {
        await pump(
          tester,
          const EdgeInsets.only(bottom: 34),
          props: const {'extend_body': true},
          slots: const {'bottom_navigation_bar': SizedBox(height: 60)},
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

      // 0.11.0부터 no-op인 옛 플래그. 화면은 플래그가 없을 때와 같다.
      for (final flags in const <Map<String, Object?>>[
        {'inset_bottom': true},
        {'inset_bottom': false},
        {'cover_bottom_inset': true},
        {'cover_bottom_inset': false},
        {'inset_bottom': true, 'cover_bottom_inset': true},
      ]) {
        testWidgets(
          '$flags는 효과가 없다',
          (tester) async {
            await pump(
              tester,
              const EdgeInsets.only(top: 47, bottom: 34),
              props: flags,
            );

            expect(
              tester.getRect(find.byKey(body)),
              const Rect.fromLTRB(0, 0, 800, 600),
            );
            final media = MediaQuery.of(tester.element(find.byKey(body)));
            expect(media.padding, const EdgeInsets.only(top: 47, bottom: 34));
            expect(strip(), findsNothing);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      }

      testWidgets(
        'Android에서도 body 하단에 띠를 그리지 않는다',
        (tester) async {
          tester.view.padding = const FakeViewPadding(bottom: 48 * 3);
          addTearDown(tester.view.reset);
          await pump(tester, const EdgeInsets.only(bottom: 48));

          expect(strip(), findsNothing);
          expect(
            tester.getRect(find.byKey(body)),
            const Rect.fromLTRB(0, 0, 800, 600),
          );
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

      testWidgets('호스트 SafeArea 아래 safe_area는 소비되지 않은 엣지만 띄운다', (tester) async {
        await pump(
          tester,
          const EdgeInsets.fromLTRB(0, 47, 0, 34),
          hostSafeArea: true,
          content: Builder(
            builder: (context) => SafeAreaWidget.build(context, const {}, [
              const SizedBox.expand(key: body),
            ]),
          ),
        );

        // 호스트가 상단을 소비했으므로 safe_area는 하단만 띄운다.
        expect(
          tester.getRect(find.byKey(body)),
          const Rect.fromLTRB(0, 47, 800, 566),
        );
      });
    });
  });
}
