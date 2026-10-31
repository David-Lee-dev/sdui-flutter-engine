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
    test('keep frames, one text bone per text, literal or bound', () {
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
      expect(label.type, 'skeleton');
      expect(label.props, {
        'of': 'text',
        'style': {'font_size': 16},
      });
      expect(value.type, 'skeleton');
      expect(value.props, {
        'of': 'text',
        'style': {'font_size': 28},
        'max_lines': 2,
      });
      expect(value.roots, isEmpty);
    });

    test('turn an image into a box bone, a circle in clip_oval', () {
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
          {
            '_type': 'image',
            'src': 'assets/logo.png',
            'width': 32,
            'height': 16,
          },
        ],
      });
      final [oval, banner, logo] = bones.children.cast<PlainDirective>();
      expect((oval.children.single as PlainDirective).props, {
        'width': 40,
        'height': 40,
        'shape': 'circle',
      });
      expect(banner.type, 'skeleton');
      expect(banner.props, {'width': 120, 'height': 60, 'radius': 12});
      expect(logo.type, 'skeleton');
      expect(logo.props, {'width': 32, 'height': 16});
    });

    test('turn an icon into a square bone of its size', () {
      final bones = _bones(const {
        '_type': 'row',
        '_skeleton': true,
        '_children': [
          {'_type': 'icon', 'name': r'${user.icon}'},
          {'_type': 'icon', 'name': r'${user.icon}', 'size': 16},
          {'_type': 'icon', 'name': 'star', 'color': r'${user.c}'},
          {'_type': 'icon', 'name': 'star', 'size': 20},
        ],
      });
      final [plain, sized, fixed, fixedSized] = bones.children
          .cast<PlainDirective>();
      expect(plain.props, {'width': 24, 'height': 24});
      expect(sized.props, {'width': 16, 'height': 16});
      expect(fixed.type, 'skeleton');
      expect(fixed.props, {'width': 24, 'height': 24});
      expect(fixedSized.type, 'skeleton');
      expect(fixedSized.props, {'width': 20, 'height': 20});
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

    test('refuse an image without a literal size', () {
      for (final src in const [r'${user.a}', 'assets/logo.png']) {
        expect(
          () => _bones({
            '_type': 'image',
            'src': src,
            'width': 40,
            '_skeleton': true,
          }),
          _fails('literal "width" and "height"'),
        );
      }
    });

    test('width override applies to a literal text', () {
      final bone = _bones(const {
        '_type': 'text',
        'value': '내 적립',
        '_skeleton': {'width': 60},
      });
      expect(bone.props, {'of': 'text', 'width': 60});
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

    test('turn an input or action widget into one box of its literal size', () {
      final bones = _bones(const {
        '_type': 'column',
        '_skeleton': true,
        '_children': [
          {'_type': 'toggle', 'bind': 'user', 'width': 52, 'height': 32},
          {
            '_type': 'refresh_indicator',
            'on_refresh': 'load',
            'width': 300,
            'height': 200,
            '_child': {'_type': 'text', 'value': 'list'},
          },
          {
            '_type': 'page_view',
            'on_changed': 'load',
            'width': 300,
            'height': 120,
            '_children': [
              {'_type': 'text', 'value': 'page'},
            ],
          },
        ],
      });
      final [toggle, refresh, pages] = bones.children.cast<PlainDirective>();
      for (final (bone, width, height) in [
        (toggle, 52, 32),
        (refresh, 300, 200),
        (pages, 300, 120),
      ]) {
        expect(bone.type, 'skeleton');
        expect(bone.props, {'width': width, 'height': height});
        expect(bone.children, isEmpty);
      }
    });

    test('keep the literal radius and shape of an input or action box', () {
      final bones = _bones(const {
        '_type': 'column',
        '_skeleton': true,
        '_children': [
          {
            '_type': 'text_field',
            'bind': 'user',
            'width': 200,
            'height': 48,
            'radius': 12,
          },
          {
            '_type': 'checkbox',
            'bind': 'user',
            'width': 24,
            'height': 24,
            'shape': 'circle',
          },
          {
            '_type': 'toggle',
            'bind': 'user',
            'width': 52,
            'height': 32,
            'radius': r'${user.r}',
          },
        ],
      });
      final [field, check, toggle] = bones.children.cast<PlainDirective>();
      expect(field.props, {'width': 200, 'height': 48, 'radius': 12});
      expect(check.props, {'width': 24, 'height': 24, 'shape': 'circle'});
      expect(toggle.props, {'width': 52, 'height': 32});
    });

    test('refuse an input or action widget without a literal size', () {
      expect(
        () => _bones(const {
          '_type': 'row',
          '_skeleton': true,
          '_children': [
            {'_type': 'checkbox', 'bind': 'user'},
          ],
        }),
        _fails('"checkbox" takes input or runs actions'),
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

    test('lays interactive wraps out as a plain column or row', () {
      for (final type in const [
        'reorderable',
        'dismissible',
        'swipe',
        'spin_grid',
        'auto_scroll',
      ]) {
        final bones = boneLoop(
          loop(
            true,
            wrap: {
              '_type': type,
              'bind': 'user',
              'on_finish': 'load',
              'on_changed': 'load',
              'spacing': 6,
              'main_axis_alignment': 'center',
              'cross_axis_alignment': 'start',
              'shrink_wrap': true,
            },
          ),
        );
        expect(bones.wrap, 'column', reason: type);
        expect(bones.wrapParams, {
          'spacing': 6,
          'main_axis_alignment': 'center',
          'cross_axis_alignment': 'start',
        }, reason: type);
      }
      final row = boneLoop(
        loop(
          true,
          wrap: const {
            '_type': 'reorderable',
            'scroll_direction': 'horizontal',
          },
        ),
      );
      expect(row.wrap, 'row');
      expect(row.wrapParams, isEmpty);
    });

    test('keep an interactive wrap padding around the bone rows', () {
      final padded =
          (_sectionChild(
                        _compile(
                          _section(
                            loop(
                              true,
                              wrap: const {
                                '_type': 'dismissible',
                                'bind': 'user',
                                'padding': 8,
                              },
                            ),
                          ),
                        ),
                      )
                      as SkeletonDirective)
                  .bones
              as PlainDirective;
      expect(padded.type, 'padding');
      expect(padded.props, {'padding': 8});
      final bones = padded.children.single as LoopDirective;
      expect(bones.wrap, 'column');
      expect(bones.wrapParams, isEmpty);
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
