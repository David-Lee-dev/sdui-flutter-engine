import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';

/// 입력 위젯 ↔ 상태 **양방향 바인딩** end-to-end. `bind` 키를 읽어 초기값을 반영하고, 사용자
/// 조작이 그 키에 직접 커밋돼(명명 액션·페이로드 없이) 같은 키를 읽는 다른 위젯에 반영된다.
/// 입력은 Material 위젯이라 [Scaffold] 아래 마운트한다.
Future<void> _pump(WidgetTester tester, Map<String, Object?> template) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EngineRunner(template: template)),
      ),
    );

void main() {
  group('input binding (end-to-end)', () {
    testWidgets('toggle — 초기 상태 반영 + 토글이 상태에 쓰여 다른 위젯에 반영', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'agree': false},
        },
        '_children': [
          {'_type': 'text', 'value': r'agree=${agree}'},
          {'_type': 'toggle', 'bind': 'agree'},
        ],
      });

      expect(find.text('agree=false'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('agree=true'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('checkbox — 초기 상태 반영 + 토글이 상태에 쓰인다', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'ok': true},
        },
        '_children': [
          {'_type': 'text', 'value': r'ok=${ok}'},
          {'_type': 'checkbox', 'bind': 'ok'},
        ],
      });

      expect(find.text('ok=true'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(find.text('ok=false'), findsOneWidget);
    });

    testWidgets('textField — 입력이 상태에 쓰여 다른 위젯에 반영된다', (tester) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'name': ''},
        },
        '_children': [
          {'_type': 'text', 'value': r'입력=${name}'},
          {'_type': 'text_field', 'bind': 'name'},
        ],
      });

      expect(find.text('입력='), findsOneWidget);

      await tester.enterText(find.byType(TextField), '홍길동');
      await tester.pump();

      expect(find.text('입력=홍길동'), findsOneWidget);
    });

    testWidgets(r'textField change — bind 쓰기와 $event 액션을 함께 실행한다', (
      tester,
    ) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'name': '', 'changed': ''},
          '_action': {
            'on_type': {'_type': 'set', 'changed': r'${event}'},
          },
        },
        '_children': [
          {'_type': 'text', 'value': r'name=${name};changed=${changed}'},
          {
            '_type': 'text_field',
            'bind': 'name',
            '_on': {'change': 'on_type'},
          },
        ],
      });

      await tester.enterText(find.byType(TextField), '민수');
      await tester.pump();

      expect(find.text('name=민수;changed=민수'), findsOneWidget);
    });

    testWidgets(r'textField submit — $event 액션을 실행하고 bind를 다시 쓰지 않는다', (
      tester,
    ) async {
      await _pump(tester, const {
        '_type': 'column',
        '_scope': {
          '_state': {'name': '', 'submitted': ''},
          '_action': {
            'save': {'_type': 'set', 'submitted': r'${event}'},
          },
        },
        '_children': [
          {'_type': 'text', 'value': r'name=${name};submitted=${submitted}'},
          {
            '_type': 'text_field',
            'bind': 'name',
            '_on': {'submit': 'save'},
          },
        ],
      });

      final field = tester.widget<TextField>(find.byType(TextField));
      field.onSubmitted!('확정값');
      await tester.pump();

      expect(find.text('name=;submitted=확정값'), findsOneWidget);
    });

    testWidgets('textField id — FocusNode를 FocusRegistry에 등록해 포커스 가능', (
      tester,
    ) async {
      await _pump(tester, const {
        '_type': 'text_field',
        'id': 'email',
        'bind': 'email',
        '_scope': {
          '_state': {'email': ''},
        },
      });

      // 레지스트리는 EngineRunner가 마운트에 만들어 context로 내린다 — 위젯의 element에서 꺼낸다.
      final registry = EngineRegistryScope.of(
        tester.element(find.byType(TextField)),
      )!.focus;
      final node = registry.nodeFor('email');
      expect(node, isNotNull);
      expect(node!.hasFocus, isFalse);

      node.requestFocus();
      await tester.pump();

      expect(node.hasFocus, isTrue); // 드라이버가 id로 포커스할 수 있는 통로
    });

    testWidgets('slider — 초기 상태 수치를 반영한다', (tester) async {
      await _pump(tester, const {
        '_type': 'slider',
        'bind': 'level',
        'min': 0,
        'max': 1,
        '_scope': {
          '_state': {'level': 0.4},
        },
      });

      expect(tester.widget<Slider>(find.byType(Slider)).value, 0.4);
    });
  });
}
