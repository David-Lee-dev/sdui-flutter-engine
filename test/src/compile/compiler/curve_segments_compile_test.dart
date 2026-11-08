import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

const _segments = <Object?>[
  {'until': 0.35, 'to': 1, 'curve': 'ease_out'},
  {'until': 1, 'to': 0, 'curve': 'bounce_out'},
];

Map<String, Object?> _root({List<String> requires = const []}) => {
  if (requires.isNotEmpty) '_requires': requires,
  '_type': 'text',
  'value': r'${n}',
  '_motion': {
    'type': 'move',
    'begin': [0, 0],
    'end': [0, -10],
    'curve': _segments,
  },
  '_morph': {'_to': 1, '_as': 'n', '_curve': _segments},
};

void main() {
  group('_requires curve_segments_v1', () {
    test('선언할 수 있는 기능이다', () {
      expect(TemplateCompiler.knownFeatures, contains('curve_segments_v1'));
      expect(
        () => _compile(_root(requires: ['curve_v2', 'curve_segments_v1'])),
        returnsNormally,
      );
    });

    test('curve_v2처럼 선언만 하는 기능이라 선언하지 않아도 컴파일된다', () {
      expect(() => _compile(_root()), returnsNormally);
    });
  });
}
