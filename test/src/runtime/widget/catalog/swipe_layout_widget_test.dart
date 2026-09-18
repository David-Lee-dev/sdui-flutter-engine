import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/swipe_layout_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/swipe_pane_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller_scope.dart';

class _FakeSink implements ActionSink {
  final List<(String, Object?)> calls = <(String, Object?)>[];

  @override
  void handle(String action, {Object? event, ActionInvocation? invocation}) =>
      calls.add((action, event));

  @override
  Future<void> handleAwaitable(
    String action, {
    Object? event,
    ActionInvocation? invocation,
  }) async => calls.add((action, event));
}

/// A pane so the layout has something to drive; irrelevant children otherwise.
Widget _pane(BuildContext context) => SwipePaneWidget.build(
  context,
  const {},
  const [Text('p0'), Text('p1'), Text('p2')],
);

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
}) => tester.pumpWidget(
  MaterialApp(
    home: EngineMetrics(
      scale: 1.0,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 300,
          child: Builder(
            builder: (context) => SwipeLayoutWidget.build(
              context,
              props,
              const [Builder(builder: _pane)],
              dispatch,
            ),
          ),
        ),
      ),
    ),
  ),
);

SwipeControllerScope _scope(WidgetTester tester) =>
    tester.widget<SwipeControllerScope>(find.byType(SwipeControllerScope));

void main() {
  group('SwipeLayoutWidget', () {
    group('build', () {
      testWidgets('provides a controller sized to length at the bound index', (
        tester,
      ) async {
        await _pump(tester, const {'length': 3, 'index': 1});
        final controller = _scope(tester).controller;
        expect(controller.length, 3);
        expect(controller.index, 1);
      });
    });

    group('scope binding', () {
      testWidgets('writes the settled index back through on_changed', (
        tester,
      ) async {
        final sink = _FakeSink();
        await _pump(tester, const {
          'length': 3,
          'on_changed': 'set_tab',
        }, dispatch: sink);
        final controller = _scope(tester).controller;

        // Do not await: goTo's future tracks the pane animation, which only
        // advances under pump. onSettled fires synchronously inside goTo, so the
        // dispatch has already happened by the next frame.
        unawaited(controller.goTo(2));
        await tester.pumpAndSettle();

        expect(sink.calls, contains(('set_tab', 2)));
      });

      testWidgets('follows a scope-driven index change', (tester) async {
        final index = ValueNotifier<int>(0);
        addTearDown(index.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: EngineMetrics(
              scale: 1.0,
              child: SizedBox(
                width: 400,
                height: 300,
                child: ValueListenableBuilder<int>(
                  valueListenable: index,
                  builder: (context, value, _) => Builder(
                    builder: (c) => SwipeLayoutWidget.build(
                      c,
                      {'length': 3, 'index': value},
                      const [Builder(builder: _pane)],
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(_scope(tester).controller.index, 0);

        index.value = 2;
        await tester.pump();

        expect(_scope(tester).controller.index, 2);
        await tester.pumpAndSettle(); // flush the pane animation
      });
    });

    group('autoplay', () {
      testWidgets('advances on the interval and stops when disposed', (
        tester,
      ) async {
        await _pump(tester, const {
          'length': 3,
          'autoplay_interval': 100,
          'loop': true,
        });
        final controller = _scope(tester).controller;
        expect(controller.index, 0);

        await tester.pump(const Duration(milliseconds: 120));
        expect(controller.index, 1);

        await tester.pumpWidget(const SizedBox()); // dispose → cancel timers
      });

      testWidgets('pauses while the user is interacting', (tester) async {
        await _pump(tester, const {'length': 3, 'autoplay_interval': 100});
        final controller = _scope(tester).controller;

        controller.beginInteraction('user'); // fires onInteractionStart → pause
        await tester.pump(const Duration(milliseconds: 250));
        expect(controller.index, 0); // did not advance while paused

        controller.endInteraction('user', 0); // schedules resume
        await tester.pumpWidget(const SizedBox()); // dispose → cancel timers
      });
    });
  });
}
