import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';

void compileWait(Map<String, Object?> command, {bool requires = true}) {
  final tree = TemplateCompiler.buildRoot(
    TemplateParser.buildUiTree({
      '_type': 'text',
      if (requires) '_requires': ['wait_v1'],
      '_scope': {
        '_state': {'p': 0},
        '_action': {'go': command},
      },
      'value': 'ready',
    }),
  );
  TemplateValidator.validate(tree, {});
}

void main() {
  test('wait shape checks count explicit null and require one expression', () {
    for (final params in [
      {'until': null, 'timeout': 300},
      {'until': true, 'timeout': 300},
      {'until': r'prefix ${p}', 'timeout': 300},
      {'duration': null, 'until': r'${p}', 'timeout': 300},
      {'until': null},
    ]) {
      expect(
        () => compileWait({'_type': 'wait', ...params}),
        throwsA(isA<InvalidTemplateException>()),
        reason: '$params',
      );
    }
    expect(
      () => compileWait({'_type': 'wait', 'until': r'${p}', 'timeout': null}),
      returnsNormally,
    );
  });

  test('wait feature gate reaches every recursive continuation lane', () {
    for (final lane in ['_then', '_error', '_dismiss', '_always']) {
      final wait = {'_type': 'wait', 'duration': 1};
      expect(
        () => compileWait({
          '_type': 'set',
          'p': 1,
          lane: lane == '_error' ? {'_': wait} : wait,
        }, requires: false),
        throwsA(
          isA<InvalidTemplateException>().having(
            (e) => e.toString(),
            'feature',
            contains('wait_v1'),
          ),
        ),
        reason: lane,
      );
    }
  });
  test('WAIT-AC11', () {
    expect(
      () => compileWait({'_type': 'wait', 'duration': 1}, requires: false),
      throwsA(
        isA<InvalidTemplateException>().having(
          (e) => e.toString(),
          'feature',
          contains('wait_v1'),
        ),
      ),
    );
  });
  test('WAIT-AC12', () {
    expect(
      () => compileWait({'_type': 'wait', 'duration': 1}),
      returnsNormally,
    );
  });
  test('WAIT-AC20', () {
    expect(
      () => compileWait({'_type': 'wait', 'until': r'${p}'}),
      throwsA(isA<InvalidTemplateException>()),
    );
  });
  test('WAIT-AC21', () {
    expect(
      () => compileWait({
        '_type': 'wait',
        'duration': 100,
        'until': r'${p}',
        'timeout': 500,
      }),
      throwsA(isA<InvalidTemplateException>()),
    );
  });
  test('CAP-AC7', () {
    final root = TemplateCompiler.buildRoot(
      TemplateParser.buildUiTree({
        '_type': 'circular_progress_indicator',
        'stroke_cap': 'round',
      }),
    );
    expect(() => TemplateValidator.validate(root, {}), returnsNormally);
  });
  test('CAP-AC8', () {
    expect(
      () => TemplateCompiler.buildRoot(
        TemplateParser.buildUiTree({
          '_type': 'circular_progress_indicator',
          '_requires': ['progress_stroke_cap_v1'],
          'stroke_cap': 'round',
        }),
      ),
      returnsNormally,
    );
  });
}
