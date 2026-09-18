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
}
