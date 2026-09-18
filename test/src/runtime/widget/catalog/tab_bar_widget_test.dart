import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/tab_bar_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// [TabBar]는 [DefaultTabController] + Material 조상이 필요하다.
Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> tabs = const [],
}) => tester.pumpWidget(
  MaterialApp(
    home: DefaultTabController(
      length: tabs.length,
      child: EngineMetrics(
        scale: 1.0,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Builder(
                builder: (context) => TabBarWidget.build(context, props, tabs),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('TabBarWidget', () {
    group('build', () {
      testWidgets('indicator_size를 생략하면 tab을 기본값으로 쓴다', (tester) async {
        await _pump(
          tester,
          const {},
          tabs: [
            const Tab(text: 'a'),
            const Tab(text: 'b'),
          ],
        );
        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect(bar.indicatorSize, TabBarIndicatorSize.tab);
      });

      testWidgets('indicator_size label을 전달한다', (tester) async {
        await _pump(
          tester,
          const {'indicator_size': 'label'},
          tabs: [
            const Tab(text: 'a'),
            const Tab(text: 'b'),
          ],
        );
        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect(bar.indicatorSize, TabBarIndicatorSize.label);
      });

      testWidgets('indicator_size tab을 전달한다', (tester) async {
        await _pump(
          tester,
          const {'indicator_size': 'tab'},
          tabs: [
            const Tab(text: 'a'),
            const Tab(text: 'b'),
          ],
        );
        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect(bar.indicatorSize, TabBarIndicatorSize.tab);
      });

      testWidgets('tab 자식과 isScrollable을 읽는다', (tester) async {
        await _pump(
          tester,
          const {'is_scrollable': true},
          tabs: [
            const Tab(text: 'a'),
            const Tab(text: 'b'),
          ],
        );
        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect(bar.tabs.length, 2);
        expect(bar.isScrollable, isTrue);
      });

      testWidgets(
        'indicatorWeight·labelStyle·tabAlignment·dividerColor를 전달한다',
        (tester) async {
          await _pump(
            tester,
            const {
              'is_scrollable': true,
              'indicator_weight': 4,
              'label_style': {'font_size': 18, 'font_weight': 'bold'},
              'unselected_label_style': {'font_size': 14},
              'tab_alignment': 'start',
              'indicator_size': 'label',
              'divider_color': '#FF112233',
            },
            tabs: [
              const Tab(text: 'a'),
              const Tab(text: 'b'),
            ],
          );
          final bar = tester.widget<TabBar>(find.byType(TabBar));
          expect(bar.indicatorWeight, 4);
          expect(bar.labelStyle?.fontSize, 18);
          expect(bar.labelStyle?.fontWeight, FontWeight.bold);
          expect(bar.unselectedLabelStyle?.fontSize, 14);
          expect(bar.tabAlignment, TabAlignment.start);
          expect(bar.indicatorSize, TabBarIndicatorSize.label);
          expect(bar.dividerColor, const Color(0xFF112233));
        },
      );
    });
  });
}
