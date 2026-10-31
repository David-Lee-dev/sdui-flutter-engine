import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/schema/builtin_language.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

void _validate(Map<String, Object?> template) => TemplateValidator.validate(
  TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template)),
  {},
);

final _rejected = throwsA(isA<InvalidTemplateException>());

const _noopScope = {
  '_state': {'x': 0},
  '_action': {
    'noop': {'_type': 'set', 'x': 1},
  },
};

Map<String, Object?> _column(Map<String, Object?> child) => {
  '_type': 'column',
  '_scope': _noopScope,
  '_children': [child],
};

const _expanded = {
  '_type': 'expanded',
  '_child': {'_type': 'text', 'value': 'x'},
};

/// A replacement `expanded` whose own build hides the parent data.
class _OpaqueExpanded extends StatelessWidget {
  const _OpaqueExpanded();

  @override
  Widget build(BuildContext context) =>
      const Opacity(opacity: 1, child: Expanded(child: Text('replaced')));
}

void main() {
  setUp(WidgetFactory.ensureRegistered);
  tearDown(WidgetFactory.reset);

  group('parent data 는 투명한 container 를 몇 겹이든 따라간다', () {
    test('container(_motion) > container > expanded 는 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'container',
            '_motion': {'type': 'fade'},
            '_child': {'_type': 'container', '_child': _expanded},
          }),
        ),
        _rejected,
      );
    });

    test('container(_on) > `_if` expanded 도 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'container',
            '_on': {'tap': 'noop'},
            '_child': {..._expanded, '_if': r'${x == 0}'},
          }),
        ),
        _rejected,
      );
    });

    test('node `_skeleton` bones 의 뿌리가 container > expanded 면 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_skeleton': {'_type': 'container', '_child': _expanded},
        }),
        _rejected,
      );
    });

    test('`_scope._skeleton` bones 의 뿌리가 container > expanded 면 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {'_type': 'container', '_child': _expanded},
          },
        }),
        _rejected,
      );
    });
  });

  group('`_scope._skeleton` bones 는 모든 분기의 구조를 검사한다', () {
    test('cond 의 첫 분기는 box, fallback 은 sliver 면 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {
              '_type': 'cond',
              '_children': [
                {'_type': 'sizedbox', '_if': r'${false}'},
                {
                  '_type': 'sliver_to_box_adapter',
                  '_else': true,
                  '_child': {'_type': 'sizedbox'},
                },
              ],
            },
          },
        }),
        _rejected,
      );
    });

    test('bones 안쪽 자식의 프로토콜 경계도 검사한다', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {
              '_type': 'column',
              '_children': [
                {
                  '_type': 'sliver_to_box_adapter',
                  '_child': {'_type': 'sizedbox'},
                },
              ],
            },
          },
        }),
        _rejected,
      );
    });

    test('bones 안쪽의 parent-data 배치도 검사한다', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {
              '_type': 'column',
              '_children': [
                {
                  '_type': 'container',
                  '_motion': {'type': 'fade'},
                  '_child': _expanded,
                },
              ],
            },
          },
        }),
        _rejected,
      );
    });

    test('바인딩은 여전히 검사하지 않는다 (분기 안쪽 포함)', () {
      _validate({
        '_type': 'sizedbox',
        '_scope': {
          '_skeleton': {
            '_type': 'column',
            '_if': r'${undeclared}',
            '_children': [
              {'_type': 'text', 'value': r'${also_undeclared}'},
            ],
          },
        },
      });
    });
  });

  test('분기마다 프로토콜이 다른 cond 는 혼합을 허용하는 부모 아래서도 컴파일 오류', () {
    expect(
      () => _validate({
        '_type': 'nested_scroll_view',
        '_children': [
          {
            '_type': 'cond',
            '_children': [
              {'_type': 'sizedbox', '_if': r'${false}'},
              {
                '_type': 'sliver_to_box_adapter',
                '_else': true,
                '_child': {'_type': 'sizedbox'},
              },
            ],
          },
        ],
      }),
      _rejected,
    );
  });

  test('내장 parent-data 빌더만 안쪽을 꾸민다고 선언한다 (compile schema 와 같다)', () {
    for (final MapEntry(key: type, value: schema)
        in BuiltinLanguage.widgets.entries) {
      expect(
        WidgetFactory.schemaOf(type)!.decoratesChild,
        schema.decoratesChild,
        reason: type,
      );
      expect(
        schema.decoratesChild,
        schema.parentData != ParentDataKind.none,
        reason: type,
      );
    }
  });

  group('안쪽을 꾸밀 수 있는지는 등록된 구현이 정한다', () {
    setUp(
      () => WidgetFactory.register(
        'expanded',
        EagerSpec(
          (context, props, children) => const _OpaqueExpanded(),
          parentData: ParentDataKind.flex,
        ),
      ),
    );

    test('다시 등록한 expanded 는 안쪽을 꾸미지 않는다', () {
      expect(WidgetFactory.schemaOf('expanded')!.decoratesChild, isFalse);
    });

    test('다시 등록한 expanded 의 `_motion` 은 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'expanded',
            '_motion': {'type': 'fade'},
          }),
        ),
        _rejected,
      );
    });

    test('다시 등록한 expanded 의 `_on` 은 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'expanded',
            '_on': {'tap': 'noop'},
          }),
        ),
        _rejected,
      );
    });
  });

  test(
    '내장 container 와 visibility 만 자식의 parent data 를 넘긴다고 선언한다 (compile schema 와 같다)',
    () {
      final declared = {
        for (final MapEntry(:key, :value) in BuiltinLanguage.widgets.entries)
          key: ?value.passesChild,
      };

      expect(declared, {
        'container': containerPassesChild,
        'visibility': visibilityPassesChild,
      });
      for (final MapEntry(key: type, value: schema)
          in BuiltinLanguage.widgets.entries) {
        expect(
          WidgetFactory.schemaOf(type)!.passesChild,
          same(schema.passesChild),
          reason: type,
        );
      }
    },
  );

  group('자식의 parent data 를 넘기는지는 등록된 구현이 정한다', () {
    setUp(
      () => WidgetFactory.register(
        'container',
        EagerSpec(
          (context, props, children) => Row(children: children),
          childParentData: ParentDataKind.flex,
        ),
      ),
    );

    test('다시 등록한 container 는 자식을 넘기지 않는다', () {
      expect(WidgetFactory.schemaOf('container')!.passesChild, isNull);
    });

    test('다시 등록한 container > expanded 의 `_motion` 은 허용', () {
      _validate(
        _column({
          '_type': 'container',
          '_motion': {'type': 'fade'},
          '_child': _expanded,
        }),
      );
    });

    test('다시 등록한 container > expanded 의 `_on` 은 허용', () {
      _validate(
        _column({
          '_type': 'container',
          '_on': {'tap': 'noop'},
          '_child': _expanded,
        }),
      );
    });

    test('node `_skeleton` bones 의 뿌리가 다시 등록한 container > expanded 면 허용', () {
      _validate({
        '_type': 'sizedbox',
        '_skeleton': {'_type': 'container', '_child': _expanded},
      });
    });
  });

  test('내장 expanded 의 `_motion` 은 그대로 허용', () {
    _validate(
      _column({
        ..._expanded,
        '_motion': {'type': 'fade'},
      }),
    );
  });
}
