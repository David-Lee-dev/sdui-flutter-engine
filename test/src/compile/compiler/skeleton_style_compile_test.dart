import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

/// A root column whose scope declares [style], with `skeleton_style_v1`.
Map<String, Object?> _styled(
  Object? style, {
  List<String> requires = const ['skeleton_style_v1'],
}) => {
  '_type': 'column',
  '_requires': requires,
  '_scope': {'_skeleton_style': style},
  '_children': const [
    {'_type': 'text', 'value': 'x'},
  ],
};

Matcher _fails(String path, String message) => throwsA(
  isA<InvalidTemplateException>()
      .having((e) => e.path, 'path', path)
      .having((e) => e.message, 'message', contains(message)),
);

void main() {
  group('_scope._skeleton_style', () {
    test('is a known feature', () {
      expect(TemplateCompiler.knownFeatures, contains('skeleton_style_v1'));
    });

    test('compiles each key into the scope override', () {
      final scope =
          _compile(
                _styled(const {
                  'effect': 'breathe',
                  'base': '#1E2016',
                  'highlight': {
                    'colors': ['#0D9EFF', '#F32DD6'],
                  },
                  'duration': 1800,
                }),
              )
              as ScopeDirective;

      final style = scope.skeletonStyle!;
      expect(style.effect, 'breathe');
      expect(style.base, '#1E2016');
      expect(style.highlight, {
        'colors': ['#0D9EFF', '#F32DD6'],
      });
      expect(style.durationMs, 1800);
    });

    test('leaves omitted keys unset', () {
      final scope =
          _compile(_styled(const {'effect': 'shimmer'})) as ScopeDirective;

      final style = scope.skeletonStyle!;
      expect(style.effect, 'shimmer');
      expect(style.base, isNull);
      expect(style.highlight, isNull);
      expect(style.durationMs, isNull);
    });

    test('a scope without it has no override', () {
      final scope =
          _compile(const {
                '_type': 'column',
                '_scope': {
                  '_state': {'a': 1},
                },
                '_children': [
                  {'_type': 'text', 'value': 'x'},
                ],
              })
              as ScopeDirective;
      expect(scope.skeletonStyle, isNull);
    });

    test('requires skeleton_style_v1', () {
      expect(
        () => _compile(_styled(const {'effect': 'tint'}, requires: const [])),
        _fails('root', 'skeleton_style_v1'),
      );
    });

    test('requires skeleton_style_v1 for a nested scope too', () {
      expect(
        () => _compile(const {
          '_type': 'column',
          '_children': [
            {
              '_type': 'column',
              '_scope': {
                '_skeleton_style': {'effect': 'tint'},
              },
              '_children': [
                {'_type': 'text', 'value': 'x'},
              ],
            },
          ],
        }),
        _fails('root/children[0]:column', 'skeleton_style_v1'),
      );
    });

    test('rejects a value that is not a map', () {
      expect(
        () => _compile(_styled('breathe')),
        _fails('root', '"_scope._skeleton_style" must be a map'),
      );
    });

    test('rejects an unknown key', () {
      expect(
        () => _compile(_styled(const {'speed': 2})),
        _fails('root', 'unknown "_skeleton_style" key "speed"'),
      );
    });

    test('rejects an unknown effect', () {
      expect(
        () => _compile(_styled(const {'effect': 'pulse'})),
        _fails('root', 'unknown "_skeleton_style.effect" "pulse"'),
      );
    });

    test('rejects a binding anywhere', () {
      for (final style in const [
        {'effect': r'${fx}'},
        {'base': r'${color}'},
        {
          'highlight': {
            'colors': ['#000000', r'${color}'],
          },
        },
        {'duration': r'${ms}'},
      ]) {
        expect(
          () => _compile(_styled(style)),
          _fails('root', '"_skeleton_style" takes no bindings'),
          reason: '$style',
        );
      }
    });

    test('rejects a malformed color or gradient', () {
      for (final style in const [
        {'base': '#12'},
        {'base': 'red'},
        {'base': true},
        {
          'highlight': {
            'colors': ['#000000'],
          },
        },
        {
          'highlight': {
            'colors': ['#000000', 'blue'],
          },
        },
        {'highlight': <String, Object?>{}},
      ]) {
        expect(
          () => _compile(_styled(style)),
          _fails('root', 'must be a color'),
          reason: '$style',
        );
      }
    });

    test('rounds a fractional duration up to whole milliseconds', () {
      for (final (duration, ms) in const [(0.3, 1), (1499.2, 1500)]) {
        final scope =
            _compile(_styled({'duration': duration})) as ScopeDirective;
        expect(scope.skeletonStyle!.durationMs, ms, reason: '$duration');
      }
    });

    test('rejects a duration that is not a positive number', () {
      for (final duration in const [0, -100, 'slow']) {
        expect(
          () => _compile(_styled({'duration': duration})),
          _fails('root', '"_skeleton_style.duration" must be a positive'),
          reason: '$duration',
        );
      }
    });
  });
}
