import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

Matcher _fails(String message, {String? at}) => throwsA(
  isA<InvalidTemplateException>()
      .having((e) => e.message, 'message', contains(message))
      .having((e) => e.path, 'path', at == null ? anything : contains(at)),
);

Map<String, Object?> _root(
  Map<String, Object?> child, {
  List<String> requires = const [],
}) => {
  if (requires.isNotEmpty) '_requires': requires,
  '_type': 'column',
  '_children': [
    {'_type': 'text', 'value': 'page'},
    child,
  ],
};

const _overlay = {
  '_type': 'anchored_overlay',
  'anchor': 'badge',
  '_children': [
    {
      '_type': 'anchored',
      'placement': 'below',
      '_child': {'_type': 'text', 'value': 'card'},
    },
  ],
};

const _exitDelay = {
  '_type': 'text',
  'value': 'card',
  '_motion': {'type': 'fade', 'on': 'both', 'exit_delay': 100},
};

void main() {
  group('_requires anchored_overlay_v1', () {
    test('is a known feature', () {
      expect(TemplateCompiler.knownFeatures, contains('anchored_overlay_v1'));
    });

    test('anchored_overlay fails without it, naming the node', () {
      expect(
        () => _compile(_root(_overlay)),
        _fails('"anchored_overlay_v1"', at: 'children[1]'),
      );
    });

    test('anchored fails without it', () {
      expect(
        () => _compile(
          _root({
            '_type': 'stack',
            '_children': [
              {
                '_type': 'anchored',
                '_child': {'_type': 'text', 'value': 'x'},
              },
            ],
          }),
        ),
        _fails('"anchored_overlay_v1"', at: 'children[0]'),
      );
    });

    test('a _motion exit_delay fails without it', () {
      expect(
        () => _compile(_root(_exitDelay)),
        _fails('"anchored_overlay_v1"', at: 'children[1]'),
      );
    });

    test('compiles with it', () {
      expect(
        _compile(_root(_overlay, requires: const ['anchored_overlay_v1'])),
        isA<PlainDirective>(),
      );
      expect(
        _compile(
          _root(
            _exitDelay,
            requires: const ['anchored_overlay_v1', 'presence_v1'],
          ),
        ),
        isA<PlainDirective>(),
      );
    });

    test('templates without the new names compile without it', () {
      expect(
        _compile(
          _root({
            '_type': 'text',
            'value': 'x',
            '_motion': {'type': 'fade', 'on': 'both', 'delay': 100},
          }),
        ),
        isA<PlainDirective>(),
      );
    });
  });
}
