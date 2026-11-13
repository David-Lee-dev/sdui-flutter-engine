import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

Map<String, Object?> _root({List<String> requires = const []}) => {
  if (requires.isNotEmpty) '_requires': requires,
  '_type': 'text',
  'value': 'page',
  '_scope': {
    '_action': {
      'ask': {'_type': 'set', 'asked': true},
    },
    '_state': {'asked': false},
    '_lifecycle': [
      {'on': 'exit_back', 'action': 'ask'},
    ],
  },
};

void main() {
  group('_lifecycle exit_back', () {
    test('X-C1 compiles with lifecycle_exit_back_v1', () {
      final root = _compile(_root(requires: ['lifecycle_exit_back_v1']));

      final hook = (root as ScopeDirective).lifecycle.single;
      expect(hook.trigger.name, 'exitBack');
      expect(hook.action, 'ask');
    });

    test('X-C2 fails without lifecycle_exit_back_v1, naming the feature', () {
      expect(
        () => _compile(_root()),
        throwsA(
          isA<InvalidTemplateException>().having(
            (e) => e.message,
            'message',
            contains('"lifecycle_exit_back_v1"'),
          ),
        ),
      );
    });
  });
}
