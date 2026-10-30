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
  });
}
