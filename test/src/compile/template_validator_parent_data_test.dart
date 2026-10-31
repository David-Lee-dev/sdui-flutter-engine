import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

void _validate(Map<String, Object?> template) => TemplateValidator.validate(
  TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template)),
  {'items'},
);

final _rejected = throwsA(isA<InvalidTemplateException>());

const _text = {'_type': 'text', 'value': 'x'};
const _expanded = {'_type': 'expanded', '_child': _text};
const _positioned = {'_type': 'positioned', '_child': _text};

Map<String, Object?> _parent(String type, Map<String, Object?> child) => {
  '_type': type,
  '_children': [child],
};

Map<String, Object?> _loop(String wrap, Map<String, Object?> item) => {
  ...item,
  '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it}', '_wrap': wrap},
};

Map<String, Object?> _cond(List<Map<String, Object?>> bodies) => {
  '_type': 'cond',
  '_children': [
    for (final (i, body) in bodies.indexed)
      i == bodies.length - 1
          ? {...body, '_else': true}
          : {...body, '_if': r'${items}'},
  ],
};

void main() {
  setUp(WidgetFactory.ensureRegistered);
  tearDown(WidgetFactory.reset);

  group('부모가 받는 parent data 와 다른 자식은 컴파일 오류', () {
    test('padding > expanded', () {
      expect(() => _validate(_parent('padding', _expanded)), _rejected);
    });

    test('stack > expanded', () {
      expect(() => _validate(_parent('stack', _expanded)), _rejected);
    });

    test('column > positioned', () {
      expect(() => _validate(_parent('column', _positioned)), _rejected);
    });

    test('row > positioned_fill', () {
      expect(
        () => _validate(
          _parent('row', {'_type': 'positioned_fill', '_child': _text}),
        ),
        _rejected,
      );
    });

    test('slot 의 expanded', () {
      expect(
        () => _validate({
          '_type': 'scaffold',
          '_slots': {'body': _expanded},
        }),
        _rejected,
      );
    });

    test('루트의 expanded', () {
      expect(() => _validate(_expanded), _rejected);
    });

    test('scope 와 morph 를 지나도 stack > expanded', () {
      expect(
        () => _validate(
          _parent('stack', {
            ..._expanded,
            '_scope': {
              '_state': {'x': 0},
            },
            '_morph': {'_to': 1, '_as': 'p'},
          }),
        ),
        _rejected,
      );
    });

    test('padding > 내장 container > expanded', () {
      expect(
        () => _validate(
          _parent('padding', {'_type': 'container', '_child': _expanded}),
        ),
        _rejected,
      );
    });

    test('indexed_stack > positioned', () {
      expect(() => _validate(_parent('indexed_stack', _positioned)), _rejected);
    });

    test('indexed_stack > positioned_fill', () {
      expect(
        () => _validate(
          _parent('indexed_stack', {
            '_type': 'positioned_fill',
            '_child': _text,
          }),
        ),
        _rejected,
      );
    });
  });

  group('자식과의 사이에 위젯을 넣는 container 는 parent data 를 넘기지 않는다', () {
    for (final props in <Map<String, Object?>>[
      {'padding': 8},
      {'margin': 8},
      {'color': '#ff0000'},
      {'width': 10},
      {'height': 10},
      {'alignment': 'center'},
      {
        'constraints': {'max_width': 100},
      },
      {
        'decoration': {'color': '#00ff00'},
      },
      {
        'foreground_decoration': {'color': '#80000000'},
      },
      {
        'transform': {
          'scale': [-1, 1],
        },
      },
      {
        'decoration': {'color': '#00ff00'},
        'clip_behavior': 'hard_edge',
      },
      {'padding': r'${items}'},
      {'clip_behavior': r'${items}'},
    ]) {
      test('column > container($props) > expanded', () {
        expect(
          () => _validate(
            _parent('column', {
              '_type': 'container',
              ...props,
              '_child': _expanded,
            }),
          ),
          _rejected,
        );
      });

      test('stack > container($props) > positioned', () {
        expect(
          () => _validate(
            _parent('stack', {
              '_type': 'container',
              ...props,
              '_child': _positioned,
            }),
          ),
          _rejected,
        );
      });
    }

    test('clip_behavior: none 과 transform_alignment 만 있으면 넘긴다', () {
      _validate(
        _parent('column', {
          '_type': 'container',
          'clip_behavior': 'none',
          'transform_alignment': 'center',
          '_child': _expanded,
        }),
      );
    });
  });

  group('부모가 받는 parent data 의 자식은 허용', () {
    final valid = <String, Map<String, Object?>>{
      'row > expanded': _parent('row', _expanded),
      'column > flexible': _parent('column', {
        '_type': 'flexible',
        '_child': _text,
      }),
      'flex > spacer': _parent('flex', {'_type': 'spacer'}),
      'serpentine_row > expanded': _parent('serpentine_row', _expanded),
      'stack > positioned': _parent('stack', _positioned),
      'column > 내장 container > expanded': _parent('column', {
        '_type': 'container',
        '_child': _expanded,
      }),
      'padding > text': _parent('padding', _text),
    };
    for (final MapEntry(key: name, value: template) in valid.entries) {
      test(name, () => _validate(template));
    }
  });

  group('loop 항목은 _wrap 이 놓는 위젯의 parent data 를 따른다', () {
    test('row 로 놓인 expanded 는 허용', () {
      _validate(_parent('sizedbox', _loop('row', _expanded)));
    });

    test('column 으로 놓인 positioned 는 컴파일 오류', () {
      expect(
        () => _validate(_parent('sizedbox', _loop('column', _positioned))),
        _rejected,
      );
    });

    test('wrap 으로 놓인 expanded 는 컴파일 오류', () {
      expect(
        () => _validate(_parent('sizedbox', _loop('wrap', _expanded))),
        _rejected,
      );
    });

    test('list 로 놓인 expanded 는 컴파일 오류', () {
      expect(
        () => _validate(_parent('sizedbox', _loop('list', _expanded))),
        _rejected,
      );
    });
  });

  group('cond 는 분기마다 부모가 받는 parent data 를 검사한다', () {
    test('column 아래 expanded | positioned 는 컴파일 오류', () {
      expect(
        () => _validate(_parent('column', _cond([_expanded, _positioned]))),
        _rejected,
      );
    });

    test('column 아래 expanded | text 는 허용', () {
      _validate(_parent('column', _cond([_expanded, _text])));
    });
  });

  group('visibility 는 maintain_* 이 꺼져 있을 때만 자식의 parent data 를 넘긴다', () {
    Map<String, Object?> visibility(
      Map<String, Object?> child, [
      Map<String, Object?> props = const {},
    ]) => {'_type': 'visibility', ...props, '_child': child};

    test('maintain_* 이 없으면 row > visibility > expanded 는 허용', () {
      _validate(
        _parent('row', visibility(_expanded, {'visible': r'${items}'})),
      );
    });

    test(
      'maintain_* 이 literal false 면 stack > visibility > positioned 는 허용',
      () {
        _validate(
          _parent(
            'stack',
            visibility(_positioned, {
              'maintain_state': false,
              'maintain_size': false,
            }),
          ),
        );
      },
    );

    test('padding > visibility > expanded 는 컴파일 오류', () {
      expect(
        () => _validate(_parent('padding', visibility(_expanded))),
        _rejected,
      );
    });

    for (final props in <Map<String, Object?>>[
      {'maintain_state': true},
      {'maintain_size': true},
      {'maintain_state': r'${items}'},
      {'maintain_size': r'${items}'},
    ]) {
      test('$props 면 row > visibility > expanded 는 컴파일 오류', () {
        expect(
          () => _validate(_parent('row', visibility(_expanded, props))),
          _rejected,
        );
      });
    }

    test('넘기는 visibility 의 `_motion` 은 컴파일 오류', () {
      expect(
        () => _validate(
          _parent(
            'row',
            visibility(_expanded, {
              '_motion': {'type': 'fade'},
            }),
          ),
        ),
        _rejected,
      );
    });
  });

  group('앱 위젯', () {
    test('선언하지 않은 앱 부모는 parent-data 자식을 받지 않는다', () {
      WidgetFactory.register(
        'app_box',
        EagerSpec((context, props, children) => children.single),
      );

      expect(
        () => _validate(_parent('app_box', _expanded)),
        throwsA(
          isA<InvalidTemplateException>().having(
            (e) => e.toString(),
            'message',
            contains('childParentData'),
          ),
        ),
      );
      expect(() => _validate(_parent('app_box', _positioned)), _rejected);
      _validate(_parent('app_box', _text));
    });

    test('flex 를 받는다고 선언한 앱 부모는 expanded 를 받는다', () {
      WidgetFactory.register(
        'app_row',
        EagerSpec(
          (context, props, children) => Row(children: children),
          childParentData: ParentDataKind.flex,
        ),
      );

      _validate(_parent('app_row', _expanded));
      expect(() => _validate(_parent('app_row', _positioned)), _rejected);
    });

    test('stack 을 받는다고 선언한 앱 부모는 positioned 만 받는다', () {
      WidgetFactory.register(
        'app_stack',
        EagerSpec(
          (context, props, children) => Stack(children: children),
          childParentData: ParentDataKind.stack,
        ),
      );

      _validate(_parent('app_stack', _positioned));
      expect(() => _validate(_parent('app_stack', _expanded)), _rejected);
    });

    test('flex parent data 로 선언한 앱 위젯은 stack 아래 컴파일 오류', () {
      WidgetFactory.register(
        'app_expanded',
        EagerSpec(
          (context, props, children) => Expanded(child: children.single),
          parentData: ParentDataKind.flex,
        ),
      );

      _validate(_parent('row', {'_type': 'app_expanded', '_child': _text}));
      expect(
        () => _validate(
          _parent('stack', {'_type': 'app_expanded', '_child': _text}),
        ),
        _rejected,
      );
    });

    test('Padding 으로 다시 등록하고 선언하지 않은 container 의 '
        'column > container(_motion) > expanded 는 컴파일 오류', () {
      WidgetFactory.register(
        'container',
        EagerSpec(
          (context, props, children) =>
              Padding(padding: EdgeInsets.zero, child: children.single),
        ),
      );

      expect(
        () => _validate(
          _parent('column', {
            '_type': 'container',
            '_motion': {'type': 'fade'},
            '_child': _expanded,
          }),
        ),
        _rejected,
      );
    });
  });
}
