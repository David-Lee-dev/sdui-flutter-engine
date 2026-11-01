import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
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

/// The merged box of [node]'s slot.
SkeletonMerge _mergeOf(Map<String, Object?> node) =>
    (_slot(node).bones as MergedBonesDirective).merge;

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
      final merged = _slot(_merged('merge')).bones as MergedBonesDirective;
      final derived = _slot(_merged(true));

      expect(merged.merge.radius, 8);
      expect(merged.merge.width, isNull);
      expect(derived.bones, isA<PlainDirective>());

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
      expect(_mergeOf(_merged({'merge': true})).radius, 8);
      expect(_mergeOf(_merged({'merge': true, 'radius': 12})).radius, 12);
      expect(_mergeOf(_merged({'merge': true, 'shape': 'pill'})).radius, 999);
      expect(_mergeOf(_merged({'merge': true, 'shape': 'rect'})).radius, 8);
      final wide = _mergeOf(_merged({'merge': true, 'width': 224}));
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
  });

  group('_skeleton: merge inside a derived _skeleton', () {
    /// A column with derived bones holding a text and [row].
    Map<String, Object?> derivedAround(Map<String, Object?> row) => {
      '_type': 'column',
      '_skeleton': true,
      '_children': [
        {'_type': 'text', 'value': r'${user.title}'},
        row,
      ],
    };

    test('is one merged box over the descendant derived as true', () {
      final bones = _slot(derivedAround(_merged('merge'))).bones;
      final column = bones as PlainDirective;
      expect(column.type, 'column');
      expect(column.children.first, isA<PlainDirective>());
      final merged = column.children[1] as MergedBonesDirective;
      expect(merged.merge.radius, 8);
      expect(merged.merge.width, isNull);

      final derived = (_slot(_merged(true)).bones as PlainDirective);
      final row = merged.bones as PlainDirective;
      expect(row.type, derived.type);
      expect(row.props, derived.props);
      expect(
        [for (final c in row.children) (c as PlainDirective).props],
        [for (final c in derived.children) (c as PlainDirective).props],
      );
    });

    test('takes radius, shape and width', () {
      MergedBonesDirective nested(Object? skeleton) =>
          (_slot(derivedAround(_merged(skeleton))).bones as PlainDirective)
                  .children[1]
              as MergedBonesDirective;

      final timer = nested({'merge': true, 'width': 224, 'radius': 12}).merge;
      expect(timer.width, 224);
      expect(timer.radius, 12);
      expect(nested({'merge': true, 'shape': 'pill'}).merge.radius, 999);
    });

    test('fails without skeleton_merge_v1, naming the node', () {
      expect(
        () => _compile(
          _section(
            derivedAround(_merged('merge')),
            requires: const ['skeleton_v2'],
          ),
        ),
        _fails('"skeleton_merge_v1"', at: 'children[1]'),
      );
    });

    void rejects(Object? skeleton, String message) => expect(
      () => _compile(_section(derivedAround(_merged(skeleton)))),
      _fails(message, at: 'children[1]'),
    );

    test('rejects merge: false, an unknown key and radius with pill', () {
      rejects({'merge': false}, '"merge"');
      rejects({'merge': true, 'height': 20}, 'unknown');
      rejects({'merge': true, 'radius': 4, 'shape': 'pill'}, '"radius"');
      rejects({'merge': true, 'width': r'${w}'}, 'literal');
    });

    test('rejects a _loop node', () {
      expect(
        () => _compile(
          _section(
            derivedAround(const {
              '_type': 'text',
              'value': r'${item}',
              '_loop': {'_in': r'${user}', '_as': 'item', '_key': r'${item}'},
              '_skeleton': 'merge',
            }),
          ),
        ),
        _fails('"_loop"', at: 'children[1]'),
      );
    });

    test('rejects nested control flow without its own _skeleton', () {
      expect(
        () => _compile(
          _section(
            derivedAround(const {
              '_type': 'row',
              '_skeleton': 'merge',
              '_children': [
                {'_type': 'text', 'value': 'a', '_if': r'${user != null}'},
              ],
            }),
          ),
        ),
        _fails('own "_skeleton"'),
      );
    });

    test('rejects a parent-data node in validation', () {
      expect(
        () => TemplateValidator.validate(
          _compile(
            _section({
              '_type': 'row',
              '_skeleton': true,
              '_children': const [
                {
                  '_type': 'expanded',
                  '_skeleton': 'merge',
                  '_child': {'_type': 'text', 'value': 'a'},
                },
              ],
            }),
          ),
          const {},
        ),
        _fails('parent-data', at: 'children[0]'),
      );
    });
  });

  test('the internal merge marker is not a template key', () {
    expect(
      () => _compile(
        _section(const {
          '_type': 'column',
          '_skeleton': true,
          '_children': [
            {
              '_type': 'text',
              'value': 'a',
              '_skeleton_merge': {'radius': 8},
            },
          ],
        }),
      ),
      _fails('unknown reserved key "_skeleton_merge"'),
    );
  });
}
