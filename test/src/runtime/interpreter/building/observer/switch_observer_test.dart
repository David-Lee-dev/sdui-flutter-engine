import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

Widget _content(Map<String, Object?> template) => NodeBuilder.build(
  TemplateCompiler.buildDirectiveTree(TemplateParser.buildUiTree(template)),
);

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

const _template = {
  '_type': 'switch',
  '_value': r'${status}',
  '_children': [
    {'_type': 'text', 'value': '로딩중', '_case': 'loading'},
    {'_type': 'text', 'value': '실패', '_case': 'error'},
    {'_type': 'text', 'value': '완료', '_case': 'done'},
    {'_type': 'text', 'value': '알수없음', '_default': true},
  ],
};

void main() {
  group('SwitchObserver', () {
    testWidgets('셀렉터 값에 맞는 가지를 렌더한다', (tester) async {
      await _pump(
        tester,
        Scope.ofState(const {'status': 'error'}, child: _content(_template)),
      );

      expect(find.text('실패'), findsOneWidget);
      expect(find.text('로딩중'), findsNothing);
      expect(find.text('완료'), findsNothing);
    });

    testWidgets('맞는 case가 없으면 _default 가지를 렌더한다', (tester) async {
      await _pump(
        tester,
        Scope.ofState(const {'status': 'zzz'}, child: _content(_template)),
      );

      expect(find.text('알수없음'), findsOneWidget);
    });

    testWidgets('맞는 case도 default도 없으면 빈 자리', (tester) async {
      const noDefault = {
        '_type': 'switch',
        '_value': r'${status}',
        '_children': [
          {'_type': 'text', 'value': '로딩중', '_case': 'loading'},
        ],
      };
      await _pump(
        tester,
        Scope.ofState(const {'status': 'zzz'}, child: _content(noDefault)),
      );

      expect(find.text('로딩중'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('셀렉터가 바뀌면 가지를 전환한다(반응)', (tester) async {
      final key = GlobalKey<ScopeState>();
      await _pump(
        tester,
        Scope.ofState(
          const {'status': 'loading'},
          key: key,
          child: _content(_template),
        ),
      );

      expect(find.text('로딩중'), findsOneWidget);

      key.currentState!.set('status', 'done');
      await tester.pump();

      expect(find.text('로딩중'), findsNothing);
      expect(find.text('완료'), findsOneWidget);
    });

    testWidgets('_case·_default 마커는 위젯 props로 새지 않는다', (tester) async {
      // text 위젯이 알 수 없는 prop을 받으면 깨질 수 있으니, 정상 렌더로 누수 없음을 확인.
      await _pump(
        tester,
        Scope.ofState(const {'status': 'loading'}, child: _content(_template)),
      );

      expect(find.text('로딩중'), findsOneWidget);
    });
  });
}
