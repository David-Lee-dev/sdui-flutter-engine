import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

final _throwsInvalid = throwsA(isA<InvalidTemplateException>());

PresenceConfig _ifPresence(Object? presence) {
  final directive = _compile({
    '_type': 'text',
    'value': 'x',
    '_if': r'${show}',
    '_presence': presence,
  });
  return (directive as ConditionDirective).presence;
}

void main() {
  group('_presence', () {
    test('is on by default with the style timing', () {
      final directive = _compile({
        '_type': 'text',
        'value': 'x',
        '_if': r'${show}',
      });
      final presence = (directive as ConditionDirective).presence;

      expect(presence.enabled, isTrue);
      expect(presence.space, isTrue);
      expect(presence.sequential, isFalse);
      expect(presence.durationMs, isNull);
      expect(presence.curve, isNull);
    });

    test('false turns it off and true keeps it on', () {
      expect(_ifPresence(false).enabled, isFalse);
      expect(_ifPresence(true).enabled, isTrue);
    });

    test('a map sets space, order, duration and curve', () {
      final presence = _ifPresence({
        'space': false,
        'order': 'sequential',
        'duration': 120,
        'curve': [0.2, 0, 0, 1],
      });

      expect(presence.enabled, isTrue);
      expect(presence.space, isFalse);
      expect(presence.sequential, isTrue);
      expect(presence.durationMs, 120);
      expect(presence.curve, [0.2, 0, 0, 1]);
    });

    test('malformed values take their defaults', () {
      final presence = _ifPresence({
        'space': 'no',
        'order': 'bogus',
        'duration': -5,
        'curve': 3,
      });

      expect(presence.space, isTrue);
      expect(presence.sequential, isFalse);
      expect(presence.durationMs, isNull);
      expect(presence.curve, isNull);
    });

    test('an unknown key or a non-map value fails to compile', () {
      expect(() => _ifPresence({'speed': 1}), _throwsInvalid);
      expect(() => _ifPresence('fast'), _throwsInvalid);
    });

    test('applies to every structural directive of its node', () {
      final directive = _compile({
        '_type': 'text',
        'value': r'${it}',
        '_presence': false,
        '_loop': {'_in': r'${items}', '_as': 'it', '_key': r'${it}'},
        '_if': r'${show}',
        '_scope': {
          '_state': {'x': 1},
          '_skeleton': {'_type': 'sizedbox'},
        },
      });

      final loop = directive as LoopDirective;
      final cond = loop.child as ConditionDirective;
      final scope = cond.branches.single.body as ScopeDirective;
      expect(loop.presence.enabled, isFalse);
      expect(cond.presence.enabled, isFalse);
      expect(scope.presence.enabled, isFalse);
    });

    test('cond and switch nodes accept it', () {
      final cond = _compile({
        '_type': 'cond',
        '_presence': {'order': 'sequential'},
        '_children': [
          {'_type': 'text', 'value': 'a', '_if': r'${a}'},
        ],
      });
      final sw = _compile({
        '_type': 'switch',
        '_value': r'${tab}',
        '_presence': false,
        '_children': [
          {'_type': 'text', 'value': 'a', '_case': 'a'},
        ],
      });

      expect((cond as ConditionDirective).presence.sequential, isTrue);
      expect((sw as SwitchDirective).presence.enabled, isFalse);
    });
  });

  group('_motion on', () {
    List<({String type, Map<String, Object?> params})> motions(Object? on) =>
        (_compile({
                  '_type': 'text',
                  'value': 'x',
                  '_motion': {'type': 'fade', 'on': on},
                })
                as PlainDirective)
            .motions;

    test('accepts enter, exit and both', () {
      for (final on in ['enter', 'exit', 'both']) {
        expect(motions(on).single.params['on'], on);
      }
    });

    test('rejects any other phase', () {
      expect(() => motions('leave'), _throwsInvalid);
      expect(() => motions(r'${phase}'), _throwsInvalid);
    });
  });

  test('presence_v1 is a known _requires feature', () {
    expect(
      () => _compile({
        '_type': 'text',
        'value': 'x',
        '_requires': ['presence_v1'],
      }),
      returnsNormally,
    );
  });
}
