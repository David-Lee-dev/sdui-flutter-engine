// The compile stage as a server-side compiler would use it: ONLY compile/ and
// ir/ imports — no runtime, no registries seeded by anything, no Flutter
// widget bindings. `LanguageCatalog.builtin()` is the whole language.
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/schema/language_catalog.dart';

void main() {
  group('standalone compile (server-side shape)', () {
    final catalog = LanguageCatalog.builtin();

    test('빌트인 언어만으로 실전 템플릿이 컴파일·검증된다', () {
      final result = Compile.build({
        '_type': 'scaffold',
        '_scope': {
          '_state': {'items': null},
          '_action': {
            'load': {
              '_type': 'net',
              'path': '/feed',
              '_then': [
                {'_type': 'set', 'items': r'${data.items}'},
              ],
            },
          },
        },
        '_slots': {
          'body': {
            '_type': 'column',
            '_motion': 'fade_in',
            '_children': [
              {'_type': 'text', 'value': r'${upper(title)}'},
            ],
          },
        },
      }, {
        'title',
      }, catalog: catalog);

      expect(result.nodeCount, greaterThan(0));
    });

    test('빌트인에 없는 위젯·커맨드·모션·함수는 전부 컴파일에서 거부된다', () {
      Map<String, Object?> node(Map<String, Object?> body) => body;

      expect(
        () => Compile.build(node({'_type': 'nope'}), const {}, catalog: catalog),
        throwsA(isA<InvalidTemplateException>()),
      );
      expect(
        () => Compile.build(
          node({
            '_type': 'text',
            'value': 'x',
            '_on': {
              'tap': 'go',
            },
            '_scope': {
              '_action': {
                'go': {'_type': 'nope_cmd'},
              },
            },
          }),
          const {},
          catalog: catalog,
        ),
        throwsA(isA<InvalidTemplateException>()),
      );
      expect(
        () => Compile.build(
          node({'_type': 'text', 'value': 'x', '_motion': 'nope_motion'}),
          const {},
          catalog: catalog,
        ),
        throwsA(isA<InvalidTemplateException>()),
      );
      expect(
        () => Compile.build(
          node({'_type': 'text', 'value': r'${nope_fn(1)}'}),
          const {},
          catalog: catalog,
        ),
        throwsA(isA<InvalidTemplateException>()),
      );
    });
  });
}
