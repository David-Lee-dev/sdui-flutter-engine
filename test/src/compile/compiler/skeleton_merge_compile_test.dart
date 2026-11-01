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

/// A section scope with a mount hook around [child], declaring [requires].
Map<String, Object?> _section(
  Map<String, Object?> child, {
  List<String> requires = const ['skeleton_v2', 'skeleton_merge_v1'],
}) => {
  '_requires': requires,
  '_type': 'column',
  '_scope': {
    '_state': {'user': null},
    '_action': {
      'load': {'_type': 'set', 'user': null},
    },
    '_lifecycle': const [
      {'on': 'mount', 'action': 'load'},
    ],
  },
  '_children': [child],
};

SkeletonDirective _slot(Map<String, Object?> node) =>
    ((_compile(_section(node)) as ScopeDirective).child as PlainDirective)
            .children
            .single
        as SkeletonDirective;

const _row = {
  '_type': 'row',
  'spacing': 8,
  '_children': [
    {'_type': 'text', 'value': r'${user.name}'},
    {'_type': 'text', 'value': 'points'},
    {'_type': 'image', 'src': r'${user.avatar}', 'width': 20, 'height': 20},
  ],
};

Map<String, Object?> _merged(Object? skeleton) => {
  ..._row,
  '_skeleton': skeleton,
};

void main() {
  group('_requires skeleton_merge_v1', () {
    test('is a known feature', () {
      expect(TemplateCompiler.knownFeatures, contains('skeleton_merge_v1'));
    });

    test('a merged _skeleton fails without it, naming the node', () {
      expect(
        () => _compile(
          _section(_merged('merge'), requires: const ['skeleton_v2']),
        ),
        _fails('"skeleton_merge_v1"', at: 'children[0]'),
      );
    });
  });

  group('_skeleton: merge', () {
    test('derives the bones as true does and merges them with radius 8', () {
      final merged = _slot(_merged('merge'));
      final derived = _slot(_merged(true));

      expect(merged.merge, isNotNull);
      expect(merged.merge!.radius, 8);
      expect(merged.merge!.width, isNull);
      expect(derived.merge, isNull);

      final bones = merged.bones as PlainDirective;
      final plain = derived.bones as PlainDirective;
      expect(bones.type, plain.type);
      expect(bones.props, plain.props);
      expect(
        [for (final c in bones.children) (c as PlainDirective).props],
        [for (final c in plain.children) (c as PlainDirective).props],
      );
    });

    test('{merge: true} takes radius, shape and width', () {
      expect(_slot(_merged({'merge': true})).merge!.radius, 8);
      expect(_slot(_merged({'merge': true, 'radius': 12})).merge!.radius, 12);
      expect(
        _slot(_merged({'merge': true, 'shape': 'pill'})).merge!.radius,
        999,
      );
      expect(_slot(_merged({'merge': true, 'shape': 'rect'})).merge!.radius, 8);
      final wide = _slot(_merged({'merge': true, 'width': 224})).merge!;
      expect(wide.width, 224);
      expect(wide.radius, 8);
    });
  });

  group('_skeleton: merge rejects', () {
    void rejects(Object? skeleton, String message) => expect(
      () => _compile(_section(_merged(skeleton))),
      _fails(message, at: 'children[0]'),
    );

    test('an unknown key', () {
      rejects({'merge': true, 'height': 20}, 'unknown');
    });

    test('merge: false', () {
      rejects({'merge': false}, '"merge"');
    });

    test('a binding', () {
      rejects({'merge': true, 'radius': r'${r}'}, 'literal');
      rejects({'merge': true, 'width': r'${w}'}, 'literal');
      rejects({'merge': r'${m}'}, '"merge"');
    });

    test('radius together with shape: pill', () {
      rejects({'merge': true, 'radius': 4, 'shape': 'pill'}, '"radius"');
    });

    test('an unknown shape or a size that is not a number', () {
      rejects({'merge': true, 'shape': 'circle'}, '"shape"');
      rejects({'merge': true, 'radius': -1}, '"radius"');
      rejects({'merge': true, 'width': 'wide'}, '"width"');
    });

    test('on a _loop node', () {
      expect(
        () => _compile(
          _section(const {
            '_type': 'text',
            'value': r'${item}',
            '_loop': {'_in': r'${user}', '_as': 'item', '_key': r'${item}'},
            '_skeleton': 'merge',
          }),
        ),
        _fails('"_loop"', at: 'children[0]'),
      );
    });

    test('nested control flow without its own _skeleton, as true does', () {
      expect(
        () => _compile(
          _section(const {
            '_type': 'column',
            '_skeleton': 'merge',
            '_children': [
              {'_type': 'text', 'value': 'a', '_if': r'${user != null}'},
            ],
          }),
        ),
        _fails('own "_skeleton"'),
      );
    });

    test('a merged _skeleton inside derived bones', () {
      expect(
        () => _compile(
          _section(const {
            '_type': 'column',
            '_skeleton': true,
            '_children': [
              {
                '_type': 'row',
                '_skeleton': 'merge',
                '_children': [
                  {'_type': 'text', 'value': 'a'},
                ],
              },
            ],
          }),
        ),
        _fails('merge', at: 'children[0]'),
      );
    });
  });
}
