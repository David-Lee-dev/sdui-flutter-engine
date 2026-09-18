import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/spin_grid_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

class _RecordingSink implements ActionSink {
  final calls = <(String, Object?)>[];

  @override
  void handle(String action, {Object? event, ActionInvocation? invocation}) =>
      calls.add((action, event));

  @override
  Future<void> handleAwaitable(
    String action, {
    Object? event,
    ActionInvocation? invocation,
  }) async => handle(action, event: event);
}

const _children = <Widget>[
  SizedBox(key: ValueKey('cell-0')),
  SizedBox(key: ValueKey('cell-1')),
  SizedBox(key: ValueKey('cell-2')),
  SizedBox(key: ValueKey('cell-3')),
];

Future<void> _pumpGrid(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: EngineMetrics(
        scale: 1,
        child: SizedBox(
          width: 300,
          child: Builder(
            builder: (context) =>
                SpinGridWidget.build(context, props, _children, dispatch),
          ),
        ),
      ),
    ),
  );
  // A controller created during the first build receives its initial ticker
  // timestamp on the following frame.
  await tester.pump();
}

List<double> _opacities(WidgetTester tester) => [
  for (final widget in tester.widgetList<Opacity>(find.byType(Opacity)))
    widget.opacity,
];

double _cellOpacity(WidgetTester tester, int index) {
  final opacity = find.ancestor(
    of: find.byKey(ValueKey('cell-$index')),
    matching: find.byType(Opacity),
  );
  return tester.widget<Opacity>(opacity).opacity;
}

void main() {
  group('SpinGridWidget', () {
    testWidgets('leaves every child fully visible before a cycle', (
      tester,
    ) async {
      await _pumpGrid(tester, const {'winner_index': 2});

      expect(_opacities(tester), everyElement(1.0));
    });

    testWidgets('leaves every child fully visible for an invalid winner', (
      tester,
    ) async {
      await _pumpGrid(tester, const {
        'winner_index': 8,
        'trigger': 1,
        'duration': 300,
      });
      await tester.pump(const Duration(milliseconds: 301));

      expect(_opacities(tester), everyElement(1.0));
    });

    testWidgets('lights exactly one child while cycling', (tester) async {
      await _pumpGrid(tester, const {
        'winner_index': 2,
        'trigger': 1,
        'duration': 300,
        'steps': 6,
        'dim_opacity': 0.4,
      });
      await tester.pump(const Duration(milliseconds: 80));

      final opacities = _opacities(tester);
      expect(opacities.where((opacity) => opacity == 1.0), hasLength(1));
      expect(opacities.where((opacity) => opacity == 0.4), hasLength(3));
    });

    testWidgets('settles on the winner and leaves only it lit', (tester) async {
      await _pumpGrid(tester, const {
        'winner_index': 2,
        'trigger': 1,
        'duration': 300,
        'steps': 6,
      });

      await tester.pump(const Duration(milliseconds: 301));

      expect(_cellOpacity(tester, 2), 1.0);
      expect(
        _opacities(tester).where((opacity) => opacity == 0.5),
        hasLength(3),
      );
    });

    testWidgets('dispatches on_finish once per cycle rather than per hop', (
      tester,
    ) async {
      final sink = _RecordingSink();
      await _pumpGrid(tester, const {
        'winner_index': 2,
        'trigger': 1,
        'duration': 300,
        'steps': 6,
        'on_finish': 'award',
      }, dispatch: sink);

      await tester.pump(const Duration(milliseconds: 151));
      expect(sink.calls, isEmpty);
      await tester.pump(const Duration(milliseconds: 150));
      expect(sink.calls, [('award', null)]);
      await tester.pump(const Duration(milliseconds: 301));
      expect(sink.calls, [('award', null)]);
    });

    testWidgets('a new trigger restarts and completes another cycle', (
      tester,
    ) async {
      final sink = _RecordingSink();
      const baseProps = {
        'winner_index': 2,
        'duration': 300,
        'steps': 6,
        'on_finish': 'award',
      };
      await _pumpGrid(tester, {...baseProps, 'trigger': 1}, dispatch: sink);
      await tester.pump(const Duration(milliseconds: 301));
      expect(sink.calls, hasLength(1));

      await _pumpGrid(tester, {...baseProps, 'trigger': 2}, dispatch: sink);
      expect(
        _opacities(tester).where((opacity) => opacity == 1.0),
        hasLength(1),
      );
      expect(sink.calls, hasLength(1));

      await tester.pump(const Duration(milliseconds: 301));
      expect(sink.calls, hasLength(2));
      expect(_cellOpacity(tester, 2), 1.0);
    });

    testWidgets('changing only winner_index does not restart the cycle', (
      tester,
    ) async {
      final sink = _RecordingSink();
      const props = {
        'trigger': 1,
        'duration': 300,
        'steps': 6,
        'on_finish': 'award',
      };
      await _pumpGrid(tester, {...props, 'winner_index': 2}, dispatch: sink);
      await tester.pump(const Duration(milliseconds: 300));

      await _pumpGrid(tester, {...props, 'winner_index': 1}, dispatch: sink);
      await tester.pump(const Duration(milliseconds: 300));

      expect(sink.calls, hasLength(1));
      expect(_cellOpacity(tester, 2), 1.0);
    });

    test('is registered as an action widget and loop wrap', () {
      expect(WidgetFactory.specFor('spin_grid'), isA<ActionSpec>());

      const template = {
        '_type': 'text',
        'value': r'${item}',
        '_loop': {
          '_in': r'${items}',
          '_as': 'item',
          '_key': r'${item}',
          '_wrap': 'spin_grid',
        },
      };
      final node = TemplateParser.buildUiTree(template);
      final directive = TemplateCompiler.buildDirectiveTree(node);

      expect(
        () => TemplateValidator.validate(directive, const {'items'}),
        returnsNormally,
      );
    });
  });
}
