import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/tab_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  Map<String, Widget> slots = const {},
}) => tester.pumpWidget(
  MaterialApp(
    home: Material(
      child: EngineMetrics(
        scale: 1.0,
        child: Builder(
          builder: (context) => TabWidget.build(context, props, slots),
        ),
      ),
    ),
  ),
);

void main() {
  group('TabWidget', () {
    group('build', () {
      testWidgets('text가 있으면 텍스트 탭', (tester) async {
        await _pump(tester, const {'text': '홈'});
        expect(tester.widget<Tab>(find.byType(Tab)).text, '홈');
      });

      testWidgets('icon 슬롯과 text prop을 함께 쓴다', (tester) async {
        await _pump(
          tester,
          const {'text': '홈'},
          slots: const {'icon': Icon(Icons.home)},
        );
        final tab = tester.widget<Tab>(find.byType(Tab));
        expect(tab.text, '홈');
        expect(tab.icon, isA<Icon>());
      });

      testWidgets('label 슬롯이 있으면 child를 쓰고 text는 null', (tester) async {
        await _pump(
          tester,
          const {'text': '무시'},
          slots: const {'label': Text('홈')},
        );
        final tab = tester.widget<Tab>(find.byType(Tab));
        expect(tab.text, isNull);
        expect(tab.child, isA<Text>());
      });
    });
  });
}
