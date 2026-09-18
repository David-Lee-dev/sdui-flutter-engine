import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> template, {
  Map<String, Object?> rootData = const {},
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineRunner(template: template, rootData: rootData),
  ),
);

void main() {
  group('NodeGuard (H9 노드 격리)', () {
    testWidgets('미등록 위젯 type은 마운트-치명 (⑥ — 런타임 강등이 아니라 마운트에서 잡음)', (
      tester,
    ) async {
      // 예전엔 런타임 WidgetFactory.build의 StateError를 NodeGuard가 노드 단위로 강등했다. 이제
      // validator가 미지 위젯 type을 **마운트에서** 잡는다(오타가 그 가지가 뜰 때까지 숨는 걸 막음) —
      // 미지 type은 템플릿 버그라 마운트-치명이 옳다. NodeGuard는 렌더 시점 데이터 오류(아래 테스트)를 계속 격리한다.
      await _pump(tester, {
        '_type': 'column',
        '_children': [
          {'_type': 'text', 'value': 'ok'},
          {'_type': 'carousel'}, // 미등록 → 마운트-치명
        ],
      });

      expect(tester.takeException(), isA<InvalidTemplateException>());
    });

    testWidgets('런타임 표현식 타입오류는 그 노드만 강등', (tester) async {
      await _pump(
        tester,
        {
          '_type': 'column',
          '_children': [
            {'_type': 'text', 'value': 'ok'},
            {'_type': 'text', '_if': r'${a < b}', 'value': 'bad'},
          ],
        },
        rootData: {'a': 'x', 'b': 5}, // 문자열 < 숫자 → FormatException
      );

      expect(tester.takeException(), isA<FormatException>());
      expect(find.text('ok'), findsOneWidget); // 형제 생존
      expect(find.text('bad'), findsNothing); // 강등된 가지
    });

    testWidgets('loop 중복 키는 loop 노드만 강등', (tester) async {
      await _pump(
        tester,
        {
          '_type': 'column',
          '_children': [
            {'_type': 'text', 'value': 'ok'},
            {
              '_type': 'container',
              '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it.id}'},
              '_child': {'_type': 'text', 'value': r'${it.id}'},
            },
          ],
        },
        rootData: {
          'items': [
            {'id': 1},
            {'id': 1}, // 중복 → FormatException
          ],
        },
      );

      expect(tester.takeException(), isA<FormatException>());
      expect(find.text('ok'), findsOneWidget); // 형제 생존
    });
  });
}
