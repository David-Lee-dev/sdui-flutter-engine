import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';

/// named-slot 위젯(§4 `_slots`) end-to-end — `scaffold`가 `_slots: {appBar, body, fab}`를 Flutter
/// Scaffold의 named 자리로 매핑한다. 파서(`_slots` 구조 키)·컴파일러·NodeBuilder(slot 분기)가
/// 다 있어야 통과한다. scaffold가 자체 Scaffold를 내므로 바깥 Scaffold 없이 MaterialApp home으로 마운트.
void main() {
  group('scaffold (named-slot 위젯 — _slots)', () {
    testWidgets('appBar·body·floatingActionButton 슬롯이 각 자리로 매핑된다', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EngineRunner(
            template: {
              '_type': 'scaffold',
              '_slots': {
                'app_bar': {'_type': 'text', 'value': '제목'},
                'body': {'_type': 'text', 'value': '본문'},
                'floating_action_button': {'_type': 'text', 'value': 'FAB'},
              },
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets); // scaffold 위젯이 Scaffold를 냄
      expect(find.text('제목'), findsOneWidget); // appBar 슬롯
      expect(find.text('본문'), findsOneWidget); // body 슬롯
      expect(find.text('FAB'), findsOneWidget); // fab 슬롯
    });

    testWidgets('슬롯 자식의 바인딩도 rootData로 푼다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EngineRunner(
            template: {
              '_type': 'scaffold',
              '_slots': {
                'body': {'_type': 'text', 'value': r'${title}'},
              },
            },
            rootData: {'title': '바인딩됨'},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('바인딩됨'), findsOneWidget);
    });

    testWidgets('_slots와 _child를 함께 주면 마운트-치명', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EngineRunner(
            template: {
              '_type': 'scaffold',
              '_slots': {
                'body': {'_type': 'text', 'value': 'x'},
              },
              '_child': {'_type': 'text', 'value': 'y'},
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<InvalidTemplateException>());
    });
  });

  group('scaffold 하단 inset (템플릿 경로)', () {
    Future<void> mount(
      WidgetTester tester,
      Map<String, Object?> template, {
      double inset = 34,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(800, 600),
              padding: EdgeInsets.only(bottom: inset),
              viewPadding: EdgeInsets.only(bottom: inset),
            ),
            child: EngineRunner(template: template),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Map<String, Object?> screen(
      Map<String, Object?> body, {
      Map<String, Object?> props = const {},
      Map<String, Object?> slots = const {},
    }) => {
      '_type': 'scaffold',
      ...props,
      '_slots': {'body': body, ...slots},
    };

    const scroll = {
      '_type': 'single_child_scroll_view',
      'padding': 16,
      '_child': {'_type': 'sizedbox', 'height': 100},
    };

    // Scaffold는 body를 느슨하게 재므로, 화면 높이를 채우는 탭 템플릿처럼 펼친다.
    const filled = {
      '_type': 'column',
      '_children': [
        {'_type': 'expanded', '_child': scroll},
      ],
    };

    EdgeInsets? scrollPadding(WidgetTester tester) =>
        tester
                .widget<SingleChildScrollView>(
                  find.byType(SingleChildScrollView),
                )
                .padding
            as EdgeInsets?;

    testWidgets('scaffold + scv: 화면 하단까지 그리고 끝 여백에 inset을 더한다', (tester) async {
      await mount(tester, screen(filled));

      expect(tester.getRect(find.byType(SingleChildScrollView)).bottom, 600);
      expect(scrollPadding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
    });

    testWidgets('스크롤 아래 safe_area CTA가 있으면 스크롤 끝 여백에 inset을 더하지 않는다', (
      tester,
    ) async {
      await mount(
        tester,
        screen({
          '_type': 'column',
          '_children': [
            {'_type': 'expanded', '_child': scroll},
            {
              '_type': 'safe_area',
              'top': false,
              '_child': {'_type': 'sizedbox', 'height': 56},
            },
          ],
        }),
      );

      expect(tester.getRect(find.byType(SingleChildScrollView)).bottom, 510);
      expect(scrollPadding(tester), const EdgeInsets.all(16));
    });

    testWidgets('하단 슬롯이 있으면 스크롤 끝 여백에 inset을 더하지 않는다', (tester) async {
      await mount(
        tester,
        screen(
          scroll,
          slots: {
            'bottom_navigation_bar': {'_type': 'sizedbox', 'height': 60},
          },
        ),
      );

      expect(scrollPadding(tester), const EdgeInsets.all(16));
    });

    testWidgets('inset_bottom·cover_bottom_inset은 효과도 경고도 없다', (tester) async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        await mount(
          tester,
          screen(
            filled,
            props: {'inset_bottom': true, 'cover_bottom_inset': true},
          ),
        );
      } finally {
        debugPrint = original;
      }

      expect(tester.getRect(find.byType(SingleChildScrollView)).bottom, 600);
      expect(scrollPadding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
      expect(logs.where((l) => l.contains('ignored prop')), isEmpty);
    });

    testWidgets('알 수 없는 scaffold prop은 여전히 경고한다', (tester) async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        await mount(tester, screen(filled, props: {'zzz_typo': true}));
      } finally {
        debugPrint = original;
      }

      expect(logs.any((l) => l.contains('ignored prop(s): zzz_typo')), isTrue);
    });

    testWidgets('inset_end: false면 템플릿 padding만 쓴다', (tester) async {
      await mount(tester, screen({...scroll, 'inset_end': false}));

      expect(scrollPadding(tester), const EdgeInsets.all(16));
    });

    testWidgets('스크롤 안의 list_view(shrink_wrap)는 inset을 다시 더하지 않는다', (
      tester,
    ) async {
      await mount(
        tester,
        screen({
          '_type': 'column',
          '_children': [
            {
              '_type': 'expanded',
              '_child': {
                '_type': 'single_child_scroll_view',
                '_child': {
                  '_type': 'list_view',
                  'shrink_wrap': true,
                  'physics': 'never',
                  '_children': [
                    {'_type': 'sizedbox', 'height': 100},
                  ],
                },
              },
            },
          ],
        }),
      );

      expect(scrollPadding(tester), const EdgeInsets.only(bottom: 34));
      expect(
        tester.widget<ListView>(find.byType(ListView)).padding,
        EdgeInsets.zero,
      );
    });

    testWidgets('page_view 안의 세로 스크롤이 inset을 한 번 더한다', (tester) async {
      await mount(
        tester,
        screen({
          '_type': 'page_view',
          '_children': [scroll],
        }),
      );

      expect(scrollPadding(tester), const EdgeInsets.fromLTRB(16, 16, 16, 50));
    });

    testWidgets(
      'Android: 띠 없이 스크롤 끝 여백은 셸 padding을 그대로 더한다',
      (tester) async {
        tester.view.padding = const FakeViewPadding(bottom: 48 * 3);
        addTearDown(tester.view.reset);
        // 앱 셸이 떠 있는 탭 바 높이(80)를 하단 padding에 더한 상태.
        await mount(tester, screen(filled), inset: 48 + 80);

        expect(
          scrollPadding(tester),
          const EdgeInsets.fromLTRB(16, 16, 16, 144),
        );
        expect(tester.getRect(find.byType(SingleChildScrollView)).bottom, 600);
        expect(
          find.byWidgetPredicate(
            (w) => w is IgnorePointer && w.child is ColoredBox,
          ),
          findsNothing,
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets('nested_scroll_view body의 list_view가 inset을 한 번 더한다', (
      tester,
    ) async {
      await mount(
        tester,
        screen({
          '_type': 'nested_scroll_view',
          '_children': [
            {
              '_type': 'sliver_to_box_adapter',
              '_child': {'_type': 'sizedbox', 'height': 100},
            },
            {
              '_type': 'list_view',
              '_children': [
                {'_type': 'sizedbox', 'height': 100},
              ],
            },
          ],
        }),
      );

      expect(
        tester.widget<ListView>(find.byType(ListView)).padding,
        const EdgeInsets.only(bottom: 34),
      );
    });
  });
}
