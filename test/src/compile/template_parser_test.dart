import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';

void main() {
  group('TemplateParser', () {
    group('build_ui_tree', () {
      test('구조 키를 걷어내고 맨몸 키는 props로 넘긴다', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'text',
          'value': r'${title}',
          'color': '#fff',
        });

        expect(node.type, 'text');
        expect(node.props['value'], r'${title}');
        expect(node.props['color'], '#fff');
        expect(node.props.containsKey('_type'), isFalse);
        expect(node.reserved, isEmpty);
        expect(node.children, isEmpty);
      });

      test('맨몸 키는 props로, _ 접두 예약 키는 reserved로 가른다 (sigil 분리)', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'text',
          'value': r'${title}',
          'color': '#fff',
          '_if': r'${show}',
          '_loop': {'_in': r'${items}'},
          '_on': {'tap': 'go'},
        });

        // 맨몸 = 위젯 prop(리프 지역), _ 접두 = 예약(컴파일러가 마커로 해석).
        expect(node.props, {'value': r'${title}', 'color': '#fff'});
        expect(node.reserved, {
          '_if': r'${show}',
          '_loop': {'_in': r'${items}'},
          '_on': {'tap': 'go'},
        });
        // props엔 마커가 없고 reserved엔 위젯 prop이 없다 — 두 봉투가 서로 안 샌다.
        expect(node.props.keys.any((k) => k.startsWith('_')), isFalse);
        expect(node.reserved.keys.every((k) => k.startsWith('_')), isTrue);
      });

      test('구조 키(_type·_key·_child·_children)는 reserved에도 안 담긴다', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'box',
          '_key': 'k1',
          '_child': {'_type': 'text'},
        });

        expect(node.key, 'k1');
        expect(node.reserved.containsKey('_type'), isFalse);
        expect(node.reserved.containsKey('_key'), isFalse);
        expect(node.reserved.containsKey('_child'), isFalse);
        expect(node.reserved, isEmpty);
      });

      test('child(단수)를 재귀 파싱한다', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'box',
          '_child': {'_type': 'text', 'value': 'hi'},
        });

        expect(node.children, hasLength(1));
        expect(node.children.single.type, 'text');
        expect(node.children.single.path, 'root/child:text');
      });

      test('children(복수)를 순서대로 재귀 파싱한다', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'column',
          '_children': [
            {'_type': 'text', 'value': 'a'},
            {'_type': 'text', 'value': 'b'},
          ],
        });

        expect(node.children.map((c) => c.props['value']), ['a', 'b']);
        expect(node.children[1].path, 'root/children[1]:text');
      });

      test('slot 경로에 child type을 붙인다', () {
        final node = TemplateParser.buildUiTree({
          '_type': 'scaffold',
          '_slots': {
            'body': {'_type': 'column'},
          },
        });

        expect(node.slots['body']!.path, 'root/slots[body]:column');
      });

      test(
        '과도하게 깊은 중첩은 InvalidTemplateException (StackOverflow 방지, B-1.2)',
        () {
          Map<String, Object?> node = {'_type': 'text'};
          for (var i = 0; i < 300; i++) {
            node = {'_type': 'box', '_child': node};
          }
          expect(
            () => TemplateParser.buildUiTree(node),
            throwsA(isA<InvalidTemplateException>()),
          );
        },
      );

      test('type이 없으면 InvalidTemplateException', () {
        expect(
          () => TemplateParser.buildUiTree({'value': 'x'}),
          throwsA(isA<InvalidTemplateException>()),
        );
      });

      test('child와 children을 동시에 주면 InvalidTemplateException', () {
        expect(
          () => TemplateParser.buildUiTree({
            '_type': 'box',
            '_child': {'_type': 'text'},
            '_children': [
              {'_type': 'text'},
            ],
          }),
          throwsA(isA<InvalidTemplateException>()),
        );
      });
    });
  });
}
