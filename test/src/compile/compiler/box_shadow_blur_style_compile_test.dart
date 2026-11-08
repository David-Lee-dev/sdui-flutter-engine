import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

Map<String, Object?> _root({List<String> requires = const []}) => {
  if (requires.isNotEmpty) '_requires': requires,
  '_type': 'container',
  'decoration': {
    'box_shadow': {'blur_radius': 6, 'blur_style': 'inner'},
  },
};

void main() {
  group('_requires box_shadow_blur_style_v1', () {
    test('선언할 수 있는 기능이다', () {
      expect(
        TemplateCompiler.knownFeatures,
        contains('box_shadow_blur_style_v1'),
      );
      expect(
        () => _compile(_root(requires: ['box_shadow_blur_style_v1'])),
        returnsNormally,
      );
    });

    test('선언하지 않아도 blur_style 을 쓴 템플릿이 컴파일된다', () {
      expect(() => _compile(_root()), returnsNormally);
    });

    test('box_shadow_inset_v1 은 선언만 하는 기능이다', () {
      expect(TemplateCompiler.knownFeatures, contains('box_shadow_inset_v1'));
      final inset = {
        '_type': 'container',
        'decoration': {
          'box_shadow': {'blur_radius': 6, 'inset': true},
        },
      };
      expect(
        () => _compile({
          '_requires': ['box_shadow_inset_v1'],
          ...inset,
        }),
        returnsNormally,
      );
      expect(() => _compile(inset), returnsNormally);
    });

    test('모르는 기능 이름은 여전히 거절한다', () {
      expect(
        () => _compile(_root(requires: ['box_shadow_blur_style_v2'])),
        throwsA(isA<InvalidTemplateException>()),
      );
    });
  });
}
