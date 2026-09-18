import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/tab_bar_view_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

/// [TabBarView]는 [DefaultTabController] 조상과 자식 수 = length가 필요하다.
Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
}) => tester.pumpWidget(
  MaterialApp(
    home: DefaultTabController(
      length: children.length,
      child: EngineMetrics(
        scale: 1.0,
        child: Builder(
          builder: (context) =>
              TabBarViewWidget.build(context, props, children),
        ),
      ),
    ),
  ),
);

void main() {
  group('TabBarViewWidget', () {
    group('build', () {
      testWidgets('탭당 자식을 받아 선택된 탭을 보인다', (tester) async {
        await _pump(
          tester,
          const {},
          children: [const Text('탭0'), const Text('탭1')],
        );
        expect(
          tester.widget<TabBarView>(find.byType(TabBarView)).children.length,
          2,
        );
        expect(find.text('탭0'), findsOneWidget);
      });
    });
  });
}
