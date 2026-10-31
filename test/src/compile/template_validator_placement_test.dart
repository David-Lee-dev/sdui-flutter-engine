import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
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

void main() {
  setUp(WidgetFactory.ensureRegistered);

  group('parent data 를 감싼 bare container 의 `_motion` · `_on`', () {
    final decorations = <String, Object?>{
      '_motion': {'type': 'fade'},
      '_on': {'tap': 'noop'},
    };
    for (final MapEntry(key: name, value: value) in decorations.entries) {
      test('$name 은 컴파일 오류', () {
        expect(
          () => _validate(
            _column({
              '_type': 'container',
              name: value,
              '_child': {
                '_type': 'expanded',
                '_child': {'_type': 'text', 'value': 'x'},
              },
            }),
          ),
          _rejected,
        );
      });

      test('parent-data 노드 자신의 $name 은 그대로 허용', () {
        _validate(
          _column({
            '_type': 'expanded',
            name: value,
            '_child': {'_type': 'text', 'value': 'x'},
          }),
        );
      });
    }
  });

  group('`_scope._skeleton` 배치', () {
    test('sliver 자리에서는 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'custom_scroll_view',
          '_children': [
            {
              '_type': 'sliver_to_box_adapter',
              '_scope': {
                '_skeleton': {'_type': 'sizedbox'},
              },
              '_child': {'_type': 'sizedbox'},
            },
          ],
        }),
        _rejected,
      );
    });

    test('parent-data 노드에서는 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'expanded',
            '_scope': {
              '_skeleton': {'_type': 'sizedbox'},
            },
            '_child': {'_type': 'sizedbox'},
          }),
        ),
        _rejected,
      );
    });

    test('bones 의 뿌리가 parent data 면 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {
              '_type': 'expanded',
              '_child': {'_type': 'sizedbox'},
            },
          },
        }),
        _rejected,
      );
    });

    test('bones 의 뿌리가 sliver 면 컴파일 오류', () {
      expect(
        () => _validate({
          '_type': 'sizedbox',
          '_scope': {
            '_skeleton': {
              '_type': 'sliver_to_box_adapter',
              '_child': {'_type': 'sizedbox'},
            },
          },
        }),
        _rejected,
      );
    });

    test('bones 는 여전히 바인딩을 검사하지 않는다', () {
      _validate({
        '_type': 'sizedbox',
        '_scope': {
          '_skeleton': {'_type': 'text', 'value': r'${undeclared}'},
        },
      });
    });
  });
}
