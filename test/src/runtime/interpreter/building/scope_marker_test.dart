import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

void main() {
  group('_scope 마커', () {
    testWidgets('자식에게 초기 상태를 내려준다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'column',
            '_scope': {
              '_state': {'count': 5},
            },
            '_children': [
              {'_type': 'text', 'value': r'${count}'},
            ],
          },
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('안쪽 scope와 바깥(root) 상태를 같은 체인으로 푼다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          rootData: {'user_id': 'u1'},
          template: {
            '_type': 'column',
            '_scope': {
              '_state': {'label': 'hello'},
            },
            '_children': [
              {'_type': 'text', 'value': r'${label}'},
              {'_type': 'text', 'value': r'${user_id}'},
            ],
          },
        ),
      );

      expect(find.text('hello'), findsOneWidget); // 안쪽 scope
      expect(find.text('u1'), findsOneWidget); // 바깥 root
    });

    testWidgets('state 값은 언팩 없이 리터럴로 seed한다 (단일키 맵도 통째로)', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'column',
            '_scope': {
              '_state': {
                'count': {'value': 5}, // 래퍼가 아니라 그냥 맵 데이터
              },
            },
            '_children': [
              {'_type': 'text', 'value': r'${count.value}'}, // 맵으로 보존됨
            ],
          },
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('value 필드를 가진 맵도 통째로 보존한다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'column',
            '_scope': {
              '_state': {
                'product': {'value': 100, 'currency': 'KRW'},
              },
            },
            '_children': [
              {'_type': 'text', 'value': r'${product.currency}'},
              {'_type': 'text', 'value': r'${product.value}'},
            ],
          },
        ),
      );

      expect(find.text('KRW'), findsOneWidget); // 맵이 통째로 보존됨
      expect(find.text('100'), findsOneWidget); // value도 필드로 남음
    });
  });
}
