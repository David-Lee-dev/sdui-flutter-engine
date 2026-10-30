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
      final result = Compile.build(
        {
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
        },
        {'title'},
        catalog: catalog,
      );

      expect(result.nodeCount, greaterThan(0));
    });

    test('빌트인에 없는 위젯·커맨드·모션·함수는 전부 컴파일에서 거부된다', () {
      Map<String, Object?> node(Map<String, Object?> body) => body;

      expect(
        () =>
            Compile.build(node({'_type': 'nope'}), const {}, catalog: catalog),
        throwsA(isA<InvalidTemplateException>()),
      );
      expect(
        () => Compile.build(
          node({
            '_type': 'text',
            'value': 'x',
            '_on': {'tap': 'go'},
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
        () => Compile.build(root(['spring_v9']), const {}, catalog: catalog),
        throwsInvalid,
      );
    });

    test('0.9.0 기능 이름도 컴파일되고 기존 이름과 함께 쓸 수 있다', () {
      expect(
        Compile.build(
          root([
            'spring_v1',
            'shape_v1',
            'math_v1',
            'align_xy_v1',
            'spring_v2',
            'curve_v2',
            'motion_repeat_v1',
            'press_v1',
            'transform_offset_v1',
            'math_v2',
            'parent_data_motion_v1',
            'motion_start_v1',
          ]),
          const {},
          catalog: catalog,
        ).directive,
        isNotNull,
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

    test('0.9.0 함수 smoothstep·sign은 빌트인 언어에 있다', () {
      expect(
        Compile.build(
          {'_type': 'text', 'value': r'${smoothstep(0, 1, 0.5) + sign(-2)}'},
          const {},
          catalog: catalog,
        ).directive,
        isNotNull,
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

  group('0.9.0 선언 변수', () {
    final catalog = LanguageCatalog.builtin();
    final throwsInvalid = throwsA(isA<InvalidTemplateException>());
    Directive build(Map<String, Object?> t) =>
        Compile.build(t, const {}, catalog: catalog).directive;

    Map<String, Object?> tapScope(Map<String, Object?> node) => {
      '_type': 'column',
      '_scope': {
        '_action': {
          'go': {'_type': 'toast', 'message': 'x'},
        },
      },
      '_children': [node],
    };

    test('_morph._velocity 이름은 자식이 읽을 수 있다', () {
      expect(
        build({
          '_type': 'text',
          '_morph': {'_to': 1, '_as': 'p', '_velocity': 'pv'},
          'value': r'${p + pv}',
        }),
        isA<MorphDirective>(),
      );
    });

    test('_velocity가 버려지면 그 이름을 읽는 자식은 미선언 바인딩 에러', () {
      expect(
        () => build({
          '_type': 'text',
          '_morph': {'_to': 1, '_as': 'p', '_velocity': 3},
          'value': r'${pv}',
        }),
        throwsInvalid,
      );
    });

    test('pressed_as 이름은 노드 자신의 props와 자손이 읽을 수 있다', () {
      expect(
        build(
          tapScope({
            '_type': 'opacity',
            'opacity': r'${down ? 0.5 : 1}',
            '_on': {
              'tap': {'do': 'go', 'pressed_as': 'down'},
            },
            '_child': {'_type': 'text', 'value': r'${down}'},
          }),
        ),
        isNotNull,
      );
    });

    test('pressed_as 이름은 형제 노드에서는 보이지 않는다', () {
      expect(
        () => build({
          '_type': 'column',
          '_scope': {
            '_action': {
              'go': {'_type': 'toast', 'message': 'x'},
            },
          },
          '_children': [
            {
              '_type': 'text',
              'value': 'a',
              '_on': {
                'tap': {'do': 'go', 'pressed_as': 'down'},
              },
            },
            {'_type': 'text', 'value': r'${down}'},
          ],
        }),
        throwsInvalid,
      );
    });
  });

  group('0.9.0 shape v2 · semantics · layout_builder 컴파일', () {
    final catalog = LanguageCatalog.builtin();
    final throwsInvalid = throwsA(isA<InvalidTemplateException>());
    Directive build(Map<String, Object?> t) =>
        Compile.build(t, const {'x'}, catalog: catalog).directive;

    Map<String, Object?> shape(Map<String, Object?> props) => {
      '_type': 'shape',
      ...props,
    };

    test('_requires shape_v2·semantics_v1·layout_builder_v1이 컴파일된다', () {
      expect(
        build({
          '_type': 'text',
          'value': 'x',
          '_requires': ['shape_v2', 'semantics_v1', 'layout_builder_v1'],
        }),
        isNotNull,
      );
    });

    test('모든 키를 쓴 리터럴 shape와 식 값은 컴파일된다', () {
      expect(
        build(
          shape({
            'shapes': [
              {
                'kind': 'capsule',
                'inset': [0, 30],
              },
              {
                'kind': 'circle',
                'op': 'subtract',
                'smooth': 12,
                'at': [0.5, 0],
                'align': 'center',
                'offset': [0, 2],
                'radius': 26,
              },
              {'kind': 'rrect', 'op': 'intersect', 'width': 4, 'height': 4},
              {'kind': 'circle', 'op': r'${x}', 'radius': 3},
              r'${x}',
            ],
            'fill': {
              'colors': ['#FFFFFFFF', '#00FFFFFF'],
            },
            'rim': {
              'width': 1,
              'gradient': {
                'colors': ['#FFFFFFFF', '#00FFFFFF'],
              },
            },
            'shadow': {
              'color': '#40000000',
              'blur': 8,
              'offset': [0, 4],
            },
            'backdrop': {'blur': 12},
          }),
        ),
        isNotNull,
      );
      expect(build(shape({'shapes': r'${x}', 'shadow': r'${x}'})), isNotNull);
    });

    test('리터럴의 모르는 op 값은 컴파일 에러', () {
      expect(
        () => build(
          shape({
            'shapes': [
              {'kind': 'capsule'},
              {'kind': 'circle', 'op': 'substract', 'radius': 4},
            ],
          }),
        ),
        throwsInvalid,
      );
      expect(
        () => build(
          shape({
            'shapes': [
              {'kind': 'circle', 'op': 3, 'radius': 4},
            ],
          }),
        ),
        throwsInvalid,
      );
    });

    test('리터럴 shape 항목·shadow·backdrop의 모르는 키는 컴파일 에러', () {
      for (final props in <Map<String, Object?>>[
        {
          'shapes': [
            {'kind': 'circle', 'radius': 4, 'ratio': 2},
          ],
        },
        {
          'shapes': [
            {'kind': 'circle', 'radius': 4},
          ],
          'shadow': {'blur_radius': 4},
        },
        {
          'shapes': [
            {'kind': 'circle', 'radius': 4},
          ],
          'backdrop': {'sigma': 4},
        },
      ]) {
        expect(() => build(shape(props)), throwsInvalid, reason: '$props');
      }
    });

    test('semantics는 자식 하나를 감싸는 빌트인 위젯이다', () {
      expect(
        build({
          '_type': 'semantics',
          'label': 'Home',
          'button': true,
          'selected': r'${x}',
          '_child': {'_type': 'text', 'value': 'x'},
        }),
        isNotNull,
      );
    });

    Map<String, Object?> layoutBuilder() => {
      '_type': 'layout_builder',
      '_provides': ['max_width', 'max_height'],
      '_child': {'_type': 'text', 'value': r'${max_width}'},
    };

    test('layout_builder는 _provides로 선언한 max_width·max_height를 자식에 준다', () {
      expect(build(layoutBuilder()), isNotNull);
      expect(
        () => build({
          '_type': 'layout_builder',
          '_child': {'_type': 'text', 'value': r'${max_width}'},
        }),
        throwsInvalid,
      );
    });

    test('intrinsic_width·intrinsic_height 아래의 layout_builder는 컴파일 에러', () {
      final throwsInvalid = throwsA(
        isA<InvalidTemplateException>().having(
          (e) => e.message,
          'message',
          contains('intrinsic_width/intrinsic_height'),
        ),
      );
      for (final intrinsic in ['intrinsic_width', 'intrinsic_height']) {
        expect(
          () => build({
            '_type': intrinsic,
            '_child': {
              '_type': 'column',
              '_children': [layoutBuilder()],
            },
          }),
          throwsInvalid,
          reason: intrinsic,
        );
      }
      expect(
        () => build({
          '_type': 'intrinsic_height',
          '_child': {
            '_type': 'column',
            '_loop': {'_in': r'${x}', '_as': 'it', '_key': r'${it}'},
            '_children': [layoutBuilder()],
          },
        }),
        throwsInvalid,
      );
    });

    test('intrinsic 형제·바깥의 layout_builder는 컴파일된다', () {
      expect(
        build({
          '_type': 'column',
          '_children': [
            {
              '_type': 'intrinsic_height',
              '_child': {'_type': 'text', 'value': 'x'},
            },
            layoutBuilder(),
          ],
        }),
        isNotNull,
      );
    });
  });
}
