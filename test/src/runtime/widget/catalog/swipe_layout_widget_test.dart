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

/// Fails its unmount, so Flutter abandons the rest of that frame's unmounts:
/// the subtrees it leaves behind stay deactivated, never disposed.
class _FailsUnmount extends StatefulWidget {
  const _FailsUnmount();

  @override
  State<_FailsUnmount> createState() => _FailsUnmountState();
}

class _FailsUnmountState extends State<_FailsUnmount> {
  @override
  void dispose() {
    super.dispose();
    throw StateError('unmount failed');
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A column whose [child] comes after a [_FailsUnmount], so removing the
/// column leaves [child] deactivated but never unmounted.
Widget _strandable(Widget child) => Column(
  children: [
    const _FailsUnmount(),
    Expanded(child: child),
  ],
);

/// An autoplaying layout around [child] (its pane by default).
Widget _autoplaying(Widget child) => MaterialApp(
  home: Center(
    child: SizedBox(
      width: 400,
      height: 300,
      child: Builder(
        builder: (context) => SwipeLayoutWidget.build(
          context,
          const {'length': 3, 'autoplay_interval': 100, 'loop': true},
          [child],
          null,
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

      testWidgets('stops while the layout is deactivated and never unmounted', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: _strandable(_autoplaying(const Builder(builder: _pane))),
          ),
        );
        await tester.pump(const Duration(milliseconds: 120));
        expect(_scope(tester).controller.index, 1);

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(tester.takeException(), isStateError);

        // A tick would animate the stranded pane's inactive viewport.
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);
      });

      testWidgets('does not move a pane that is deactivated and never '
          'unmounted', (tester) async {
        await tester.pumpWidget(
          _autoplaying(_strandable(const Builder(builder: _pane))),
        );
        final controller = _scope(tester).controller;
        await tester.pump(const Duration(milliseconds: 120));
        expect(controller.index, 1);

        await tester.pumpWidget(_autoplaying(const SizedBox()));
        expect(tester.takeException(), isStateError);

        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        expect(controller.index, 2); // the layout still autoplays
        await tester.pump(const Duration(milliseconds: 350));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('resumes when the layout moves to a new parent', (
        tester,
      ) async {
        final key = GlobalKey();
        Widget at(bool left) => MaterialApp(
          home: Row(
            children: [
              Expanded(
                child: left
                    ? KeyedSubtree(
                        key: key,
                        child: _autoplaying(const Builder(builder: _pane)),
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: left
                    ? const SizedBox()
                    : Center(
                        child: KeyedSubtree(
                          key: key,
                          child: _autoplaying(const Builder(builder: _pane)),
                        ),
                      ),
              ),
            ],
          ),
        );
        await tester.pumpWidget(at(true));
        final controller = _scope(tester).controller;
        await tester.pump(const Duration(milliseconds: 120));
        expect(controller.index, 1);

        await tester.pumpWidget(at(false));
        expect(identical(_scope(tester).controller, controller), isTrue);
        await tester.pump(const Duration(milliseconds: 120));
        expect(controller.index, 2);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
      });
    });
  });
}
