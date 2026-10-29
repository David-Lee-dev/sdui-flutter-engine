// The compile stage as a server-side compiler would use it: ONLY compile/ and
// ir/ imports — no runtime, no registries seeded by anything, no Flutter
// widget bindings. `LanguageCatalog.builtin()` is the whole language.
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/schema/language_catalog.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

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

  group('root _requires', () {
    final catalog = LanguageCatalog.builtin();
    final throwsInvalid = throwsA(isA<InvalidTemplateException>());

    Map<String, Object?> root(Object? requires) => {
      '_type': 'text',
      'value': 'x',
      '_requires': requires,
    };

    test('알려진 기능 이름 목록은 컴파일된다', () {
      expect(
        Compile.build(
          root(['spring_v1', 'shape_v1', 'math_v1', 'align_xy_v1']),
          const {},
          catalog: catalog,
        ).directive,
        isNotNull,
      );
      expect(
        Compile.build(root(<Object?>[]), const {}, catalog: catalog).directive,
        isNotNull,
      );
    });

    test('screen 템플릿의 _transition과 함께 둘 수 있다', () {
      final result = Compile.build(
        {
          ...root(['spring_v1']),
          '_transition': {'type': 'fade'},
        },
        const {},
        catalog: catalog,
        screen: true,
      );
      expect(result.transition, isNotNull);
    });

    test('모르는 기능 이름은 컴파일 에러', () {
      expect(
        () => Compile.build(root(['spring_v2']), const {}, catalog: catalog),
        throwsInvalid,
      );
    });

    test('목록이 아니거나 문자열이 아닌 항목은 컴파일 에러', () {
      for (final raw in <Object?>[
        'spring_v1',
        null,
        1,
        [1],
        {'a': 1},
      ]) {
        expect(
          () => Compile.build(root(raw), const {}, catalog: catalog),
          throwsInvalid,
          reason: '$raw',
        );
      }
    });

    test('슬롯을 가진 루트도 슬롯을 잃지 않는다', () {
      final result = Compile.build(
        {
          '_type': 'scaffold',
          '_requires': ['shape_v1'],
          '_slots': {
            'body': {'_type': 'text', 'value': 'x'},
          },
        },
        const {},
        catalog: catalog,
      );
      expect((result.directive as PlainDirective).slots.keys, ['body']);
    });

    test('루트가 아닌 노드의 _requires는 미지 예약 키로 거부된다', () {
      expect(
        () => Compile.build(
          {
            '_type': 'column',
            '_children': [
              {
                '_type': 'text',
                'value': 'x',
                '_requires': ['spring_v1'],
              },
            ],
          },
          const {},
          catalog: catalog,
        ),
        throwsInvalid,
      );
    });

    test('루트의 미지 예약 키는 거부된다(구 엔진이 _requires를 막는 근거)', () {
      expect(
        () => Compile.build(
          {
            '_type': 'text',
            'value': 'x',
            '_requires_next': ['a'],
          },
          const {},
          catalog: catalog,
        ),
        throwsInvalid,
      );
    });
  });
}
