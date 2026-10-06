import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/schema/language_catalog.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';

void main() {
  final catalog = LanguageCatalog.builtin();
  final screen = <String, Object?>{
    '_type': 'text',
    'value': 'ready',
    '_transition': {
      'type': 'fade',
      'duration': 120,
      'reverse_duration': 80,
      'curve': 'ease_in',
      'params': {
        'nested': [
          1,
          {'value': true},
        ],
      },
    },
  };

  group('root _transition', () {
    test(
      'decodes immutable metadata and leaves the directive tree unchanged',
      () {
        final withTransition = Compile.build(
          screen,
          const {},
          catalog: catalog,
          screen: true,
        );
        final withoutTransition = Compile.build(
          {'_type': 'text', 'value': 'ready'},
          const {},
          catalog: catalog,
          screen: true,
        );

        final transition = withTransition.transition!;
        expect(transition.type, 'fade');
        expect(transition.durationMs, 120);
        expect(transition.reverseDurationMs, 80);
        expect(transition.curve, 'ease_in');
        expect(
          transition.contentTiming,
          PageTransitionContentTiming.duringShared,
        );
        expect(
          withTransition.directive.runtimeType,
          withoutTransition.directive.runtimeType,
        );
        expect(withTransition.nodeCount, withoutTransition.nodeCount);
        expect(() => transition.params['x'] = 1, throwsUnsupportedError);
        expect(
          () => (transition.params['nested'] as List).add(2),
          throwsUnsupportedError,
        );
        expect(
          () => ((transition.params['nested'] as List)[1] as Map)['x'] = 1,
          throwsUnsupportedError,
        );
      },
    );

    test('rejects malformed declarations and expressions', () {
      final bad = <Object?>[
        'no',
        {'type': 'fade', 'unknown': true},
        {'type': ''},
        {'type': 'missing'},
        {'type': 'fade', 'curve': 'missing'},
        {'type': 'fade', 'duration': -1},
        {'type': 'fade', 'duration': double.infinity},
        {'type': 'fade', 'content_timing': 'later'},
        {'type': 'fade', 'params': []},
        {
          'type': 'fade',
          'params': {'nested': r'${data}'},
        },
      ];
      for (final transition in bad) {
        expect(
          () => Compile.build(
            {'_type': 'text', 'value': 'x', '_transition': transition},
            const {},
            catalog: catalog,
            screen: true,
          ),
          throwsA(isA<InvalidTemplateException>()),
        );
      }
    });

    test('only permits the key at a screen root', () {
      expect(
        () => Compile.build(
          {
            '_type': 'column',
            '_child': {
              '_type': 'text',
              'value': 'x',
              '_transition': {'type': 'fade'},
            },
          },
          const {},
          catalog: catalog,
          screen: true,
        ),
        throwsA(isA<InvalidTemplateException>()),
      );
      expect(
        () => Compile.build(screen, const {}, catalog: catalog),
        throwsA(isA<InvalidTemplateException>()),
      );
    });

    testWidgets('EngineRunner accepts a screen root but rejects a modal root', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: EngineRunner(template: screen)),
      );
      expect(find.text('ready'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: EngineRunner(
            key: const ValueKey('modal'),
            template: screen,
            surfaceType: 'modal',
          ),
        ),
      );
      expect(find.text('This screen could not be loaded.'), findsOneWidget);
      expect(tester.takeException(), isA<InvalidTemplateException>());
    });
  });
}
