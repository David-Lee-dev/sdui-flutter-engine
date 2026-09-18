import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/sliver_app_bar_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// [SliverAppBar]는 Material 위젯이라 [MaterialApp] 조상 아래서 pump한다.
Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  Map<String, Widget> slots = const {},
  double scale = 1.0,
}) => tester.pumpWidget(
  MaterialApp(
    home: DefaultTabController(
      length: 1,
      child: EngineMetrics(
        scale: scale,
        child: CustomScrollView(
          slivers: [
            Builder(
              builder: (context) =>
                  SliverAppBarWidget.build(context, props, slots),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  group('SliverAppBarWidget', () {
    group('build', () {
      testWidgets(
        'pinned·expandedHeight를 읽고 자식은 flexibleSpace로(height scale)',
        (tester) async {
          await _pump(
            tester,
            const {'pinned': true, 'expanded_height': 200},
            slots: const {'flexible_space': Text('헤더')},
            scale: 0.5,
          );
          final bar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
          expect(bar.pinned, isTrue);
          expect(bar.expandedHeight, 100);
          expect(bar.flexibleSpace, isNotNull);
          expect(find.text('헤더'), findsOneWidget);
        },
      );

      testWidgets('named 슬롯과 elevation·centerTitle을 전달한다', (tester) async {
        await _pump(
          tester,
          const {'elevation': 3, 'center_title': true},
          slots: const {
            'title': Text('제목'),
            'leading': Icon(Icons.menu),
            'actions': Row(children: [Icon(Icons.search)]),
            'bottom': TabBar(tabs: [Tab(text: '탭')]),
            'flexible_space': Text('헤더'),
          },
        );
        final bar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
        expect(bar.title, isA<Text>());
        expect(bar.leading, isA<Icon>());
        expect(bar.actions, hasLength(1));
        expect(bar.bottom, isA<TabBar>());
        expect(bar.flexibleSpace, isA<Text>());
        expect(bar.elevation, 3);
        expect(bar.centerTitle, isTrue);
      });

      testWidgets(
        '엔진 _slots로 title·leading·actions·bottom·flexibleSpace를 구성한다',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: DefaultTabController(
                length: 1,
                child: EngineRunner(
                  template: {
                    '_type': 'custom_scroll_view',
                    '_children': [
                      {
                        '_type': 'sliver_app_bar',
                        'elevation': 4,
                        'center_title': true,
                        '_slots': {
                          'title': {'_type': 'text', 'value': '제목'},
                          'leading': {'_type': 'text', 'value': '앞'},
                          'actions': {
                            '_type': 'row',
                            '_children': [
                              {'_type': 'text', 'value': '동작'},
                            ],
                          },
                          'bottom': {
                            '_type': 'tab_bar',
                            '_children': [
                              {'_type': 'tab', 'text': '탭'},
                            ],
                          },
                          'flexible_space': {'_type': 'text', 'value': '헤더'},
                        },
                      },
                    ],
                  },
                ),
              ),
            ),
          );

          final bar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
          expect(bar.title, isNotNull);
          expect(bar.leading, isNotNull);
          expect(bar.actions, hasLength(1));
          // 엔진 경유 슬롯은 반응 경계로 감싸져 PreferredSize로 래핑된다(그 안에 tabBar).
          expect(bar.bottom, isA<PreferredSize>());
          expect(find.byType(TabBar), findsOneWidget);
          expect(bar.flexibleSpace, isNotNull);
          expect(bar.elevation, 4);
          expect(bar.centerTitle, isTrue);
        },
      );

      testWidgets('snap은 floating일 때만 유효(단독 snap은 무시)', (tester) async {
        await _pump(tester, const {'snap': true});
        expect(
          tester.widget<SliverAppBar>(find.byType(SliverAppBar)).snap,
          isFalse,
        );
      });
    });
  });
}
