import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

void _validate(Map<String, Object?> template) =>
    TemplateValidator.validate(_compile(template), const {});

Matcher _fails(String message) => throwsA(
  isA<InvalidTemplateException>().having(
    (e) => e.toString(),
    'message',
    contains(message),
  ),
);

const _mount = [
  {'on': 'mount', 'action': 'load'},
];

/// A section scope with a mount hook around [child].
Map<String, Object?> _section(
  Map<String, Object?> child, {
  Map<String, Object?>? skeleton,
  List<Map<String, Object?>> lifecycle = _mount,
}) => {
  '_type': 'column',
  '_scope': {
    '_state': {'user': null},
    '_action': {
      'load': {'_type': 'set', 'user': null},
    },
    '_lifecycle': lifecycle,
    '_skeleton': ?skeleton,
  },
  '_children': [child],
};

ScopeDirective _scopeOf(Directive directive) => directive as ScopeDirective;

/// The plain child of the section column.
Directive _sectionChild(Directive directive) =>
    ((directive as ScopeDirective).child as PlainDirective).children.single;

/// The bones of a node `_skeleton` as plain directives.
PlainDirective _bones(Map<String, Object?> node) =>
    (_sectionChild(_compile(_section(node))) as SkeletonDirective).bones
        as PlainDirective;

Map<String, Object?> _literal(PlainDirective node) => node.props;

void main() {
  group('_requires skeleton_v2', () {
    test('is a known feature', () {
      expect(TemplateCompiler.knownFeatures, contains('skeleton_v2'));
      expect(
        () => _compile(const {
          '_type': 'text',
          'value': 'x',
          '_requires': ['skeleton_v2'],
        }),
        returnsNormally,
      );
    });
  });

  group('node _skeleton', () {
    test('wraps the node outermost, outside its _if', () {
      final child = _sectionChild(
        _compile(
          _section(const {
            '_type': 'text',
            'value': r'${user}',
            '_if': r'${user != null}',
            '_skeleton': {'_type': 'skeleton', 'height': 72},
          }),
        ),
      );
      expect(child, isA<SkeletonDirective>());
      final skeleton = child as SkeletonDirective;
      expect(skeleton.child, isA<ConditionDirective>());
      expect((skeleton.bones as PlainDirective).type, 'skeleton');
      expect((skeleton.bones as PlainDirective).props['height'], 72);
    });

    test('makes the nearest scope with mount hooks track loading', () {
      final tracked = _compile(
        _section(const {
          '_type': 'text',
          'value': 'x',
          '_skeleton': {'_type': 'skeleton'},
        }),
      );
      expect(_scopeOf(tracked).tracksLoading, isTrue);

      final plain = _compile(_section(const {'_type': 'text', 'value': 'x'}));
      expect(_scopeOf(plain).tracksLoading, isFalse);

      final mountless = _compile(
        _section(const {
          '_type': 'text',
          'value': 'x',
          '_skeleton': {'_type': 'skeleton'},
        }, lifecycle: const []),
      );
      expect(_scopeOf(mountless).tracksLoading, isFalse);
    });

    test('stops the search at a nested scope with mount hooks', () {
      final outer = _compile(
        _section(
          _section(const {
            '_type': 'text',
            'value': 'x',
            '_skeleton': {'_type': 'skeleton'},
          }),
        ),
      );
      expect(_scopeOf(outer).tracksLoading, isFalse);
      final inner =
          ((outer as ScopeDirective).child as PlainDirective).children.single;
      expect(_scopeOf(inner).tracksLoading, isTrue);
    });

    test('rejects a node _skeleton below a scope _skeleton', () {
      expect(
        () => _compile(
          _section(
            const {
              '_type': 'text',
              'value': 'x',
              '_skeleton': {'_type': 'skeleton'},
            },
            skeleton: const {'_type': 'skeleton'},
          ),
        ),
        _fails('"_scope._skeleton" and a node "_skeleton"'),
      );
    });

    test('rejects a node _skeleton on a node with its own mount scope', () {
      expect(
        () => _compile(
          _section(const {'_type': 'text', 'value': 'x'})
            ..['_skeleton'] = {'_type': 'skeleton'},
        ),
        _fails('use "_scope._skeleton"'),
      );
    });

    test('rejects an unknown form', () {
      expect(
        () => _compile(
          _section(const {'_type': 'text', 'value': 'x', '_skeleton': 3}),
        ),
        _fails('"_skeleton" must be'),
      );
    });

    test('is allowed on cond and switch nodes', () {
      expect(
        () => _compile(
          _section(const {
            '_type': 'cond',
            '_skeleton': {'_type': 'skeleton'},
            '_children': [
              {'_type': 'text', 'value': 'a', '_if': r'${user != null}'},
            ],
          }),
        ),
        returnsNormally,
      );
      expect(
        () => _compile(
          _section(const {
            '_type': 'switch',
            '_value': r'${user}',
            '_skeleton': {'_type': 'skeleton'},
            '_children': [
              {'_type': 'text', 'value': 'a', '_case': 'a'},
            ],
          }),
        ),
        returnsNormally,
      );
    });
  });

  group('derived bones (_skeleton: true)', () {
    test('keep frames and static text, one text bone per bound text', () {
      final bones = _bones(const {
        '_type': 'container',
        'padding': 20,
        'decoration': {'color': r'${user.tint}', 'border_radius': 16},
        '_on': {'tap': 'load'},
        '_motion': 'fade_in',
        '_skeleton': true,
        '_child': {
          '_type': 'column',
          'spacing': 8,
          '_children': [
            {
              '_type': 'text',
              'value': '내 적립',
              'style': {'font_size': 16},
            },
            {
              '_type': 'text',
              'value': r'${user.a}/1000원',
              'style': {'font_size': 28, 'color': r'${user.c}'},
              'max_lines': 2,
            },
          ],
        },
      });
      expect(bones.type, 'container');
      expect(bones.on, isEmpty);
      expect(bones.motions, isEmpty);
      expect(_literal(bones), {
        'padding': 20,
        'decoration': {'border_radius': 16},
      });
      final column = bones.children.single as PlainDirective;
      expect(column.props, {'spacing': 8});
      final [label, value] = column.children.cast<PlainDirective>();
      expect(label.type, 'text');
      expect(label.props['value'], '내 적립');
      expect(value.type, 'skeleton');
      expect(value.props, {
        'of': 'text',
        'style': {'font_size': 28},
        'max_lines': 2,
      });
      expect(value.roots, isEmpty);
    });

    test('turn a bound image into a box bone, a circle in clip_oval', () {
      final bones = _bones(const {
        '_type': 'row',
        '_skeleton': true,
        '_children': [
          {
            '_type': 'clip_oval',
            '_child': {
              '_type': 'image',
              'src': r'${user.avatar}',
              'width': 40,
              'height': 40,
            },
          },
          {
            '_type': 'image',
            'src': r'${user.banner}',
            'width': 120,
            'height': 60,
            'radius': 12,
          },
        ],
      });
      final [oval, banner] = bones.children.cast<PlainDirective>();
      expect((oval.children.single as PlainDirective).props, {
        'width': 40,
        'height': 40,
        'shape': 'circle',
      });
      expect(banner.type, 'skeleton');
      expect(banner.props, {'width': 120, 'height': 60, 'radius': 12});
    });

    test('turn a bound icon into a square bone of its size', () {
      final bones = _bones(const {
        '_type': 'row',
        '_skeleton': true,
        '_children': [
          {'_type': 'icon', 'name': r'${user.icon}'},
          {'_type': 'icon', 'name': r'${user.icon}', 'size': 16},
          {'_type': 'icon', 'name': 'star', 'color': r'${user.c}'},
        ],
      });
      final [plain, sized, fixed] = bones.children.cast<PlainDirective>();
      expect(plain.props, {'width': 24, 'height': 24});
      expect(sized.props, {'width': 16, 'height': 16});
      expect(fixed.type, 'icon');
      expect(fixed.props, {'name': 'star'});
    });

    test('use a nested node _skeleton for that node', () {
      final bones = _bones(const {
        '_type': 'column',
        '_skeleton': true,
        '_children': [
          {
            '_type': 'text',
            'value': r'${user.point}',
            '_skeleton': {'width': 120},
          },
          {
            '_type': 'text',
            'value': r'${user.name}',
            '_if': r'${user != null}',
            '_skeleton': {'_type': 'skeleton', 'height': 20},
          },
        ],
      });
      final [point, name] = bones.children.cast<PlainDirective>();
      expect(point.props, {'of': 'text', 'width': 120});
      expect(name.props, {'height': 20});
    });

    test('refuse a bound size prop', () {
      expect(
        () => _bones(const {
          '_type': 'text',
          'value': r'${user.a}',
          'style': {'font_size': r'${user.size}'},
          '_skeleton': true,
        }),
        _fails('"style.font_size"'),
      );
      expect(
        () => _bones(const {
          '_type': 'container',
          'height': r'${user.h}',
          '_skeleton': true,
        }),
        _fails('"height"'),
      );
    });

    test('refuse a bound image without a literal size', () {
      expect(
        () => _bones(const {
          '_type': 'image',
          'src': r'${user.a}',
          'width': 40,
          '_skeleton': true,
        }),
        _fails('literal "width" and "height"'),
      );
    });

    test('refuse nested control flow without its own _skeleton', () {
      for (final nested in const [
        {'_type': 'text', 'value': 'a', '_if': r'${user != null}'},
        {
          '_type': 'text',
          'value': 'a',
          '_loop': {'_in': r'${user}', '_key': r'${item}'},
        },
        {
          '_type': 'cond',
          '_children': [
            {'_type': 'text', 'value': 'a', '_else': true},
          ],
        },
      ]) {
        expect(
          () => _bones({
            '_type': 'column',
            '_skeleton': true,
            '_children': [nested],
          }),
          _fails('needs its own "_skeleton"'),
        );
      }
    });

    test('refuse another bound leaf', () {
      expect(
        () => _bones(const {
          '_type': 'badge',
          'label': r'${user.count}',
          '_skeleton': true,
        }),
        _fails('"label"'),
      );
    });

    test('width override applies only to a derived leaf', () {
      expect(
        () => _bones(const {
          '_type': 'column',
          '_skeleton': {'width': 120},
        }),
        _fails('"width"'),
      );
    });
  });

  group('loop _skeleton', () {
    Map<String, Object?> loop(Object? skeleton, {Object wrap = 'column'}) => {
      '_type': 'text',
      'value': r'${item.name}',
      'style': {'font_size': 14},
      '_loop': {
        '_in': r'${user}',
        '_as': 'item',
        '_key': r'${item.id}',
        '_wrap': wrap,
      },
      '_skeleton': skeleton,
    };

    LoopDirective boneLoop(Map<String, Object?> node) =>
        (_sectionChild(_compile(_section(node))) as SkeletonDirective).bones
            as LoopDirective;

    test('true repeats the derived row three times in the same wrap', () {
      final bones = boneLoop(
        loop(true, wrap: const {'_type': 'column', 'spacing': 12}),
      );
      expect(bones.source, [0, 1, 2]);
      expect(bones.wrap, 'column');
      expect(bones.wrapParams, {'spacing': 12});
      expect((bones.child as PlainDirective).props, {
        'of': 'text',
        'style': {'font_size': 14},
      });
    });

    test('{count, tree} repeats the given tree', () {
      final bones = boneLoop(
        loop(const {
          'count': 2,
          'tree': {'_type': 'skeleton', 'height': 30},
        }),
      );
      expect(bones.source, [0, 1]);
      expect((bones.child as PlainDirective).props, {'height': 30});
    });

    test('{count} derives the row', () {
      final bones = boneLoop(loop(const {'count': 5}));
      expect(bones.source, hasLength(5));
      expect((bones.child as PlainDirective).type, 'skeleton');
    });

    test('rejects a lazy or sliver wrap', () {
      for (final wrap in const ['list', 'grid', 'sliver_list', 'sliver_grid']) {
        expect(
          () => _compile(_section(loop(true, wrap: wrap))),
          _fails('lazy or sliver'),
        );
      }
    });

    test('rejects a bone tree without count and a bad count', () {
      expect(
        () => _compile(_section(loop(const {'_type': 'skeleton'}))),
        _fails('{count, tree}'),
      );
      expect(
        () => _compile(_section(loop(const {'count': 0}))),
        _fails('"count"'),
      );
    });
  });

  group('validation', () {
    test('passes a derived section', () {
      expect(
        () => _validate(
          _section(const {
            '_type': 'text',
            'value': r'${user.name}',
            '_skeleton': true,
          }),
        ),
        returnsNormally,
      );
    });

    test('walks the bones', () {
      expect(
        () => _validate(
          _section(const {
            '_type': 'text',
            'value': 'x',
            '_skeleton': {'_type': 'no_such_widget'},
          }),
        ),
        _fails('no_such_widget'),
      );
    });

    test('rejects a _skeleton on a parent-data node', () {
      expect(
        () => _validate({
          '_type': 'row',
          '_scope': {
            '_state': {'user': null},
            '_action': {
              'load': {'_type': 'set', 'user': null},
            },
            '_lifecycle': _mount,
          },
          '_children': [
            {
              '_type': 'expanded',
              '_skeleton': {'_type': 'skeleton'},
              '_child': {'_type': 'text', 'value': 'x'},
            },
          ],
        }),
        _fails('parent-data'),
      );
    });

    test('rejects a _skeleton on a sliver node', () {
      expect(
        () => _validate(
          _section(const {
            '_type': 'custom_scroll_view',
            '_children': [
              {
                '_type': 'sliver_to_box_adapter',
                '_skeleton': {'_type': 'skeleton'},
                '_child': {'_type': 'text', 'value': 'x'},
              },
            ],
          }),
        ),
        _fails('layout protocol mismatch'),
      );
    });
  });
}
