import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/page_view_widget.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

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

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  List<Widget> children = const [],
  ActionSink? dispatch,
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: EngineMetrics(
      scale: 1.0,
      child: Builder(
        builder: (context) =>
            PageViewWidget.build(context, props, children, dispatch),
      ),
    ),
  ),
);

void main() {
  group('PageViewWidget', () {
    group('build', () {
      testWidgets('scrollDirection을 읽는다', (tester) async {
        await _pump(
          tester,
          const {'scroll_direction': 'vertical'},
          children: [const Text('a'), const Text('b')],
        );
        expect(
          tester.widget<PageView>(find.byType(PageView)).scrollDirection,
          Axis.vertical,
        );
      });

      testWidgets('scrollDirection 기본은 horizontal', (tester) async {
        await _pump(tester, const {}, children: [const Text('a')]);
        expect(
          tester.widget<PageView>(find.byType(PageView)).scrollDirection,
          Axis.horizontal,
        );
      });

      testWidgets('viewportFraction을 내부 PageController에 반영하고 unmount 때 폐기한다', (
        tester,
      ) async {
        await _pump(
          tester,
          const {'viewport_fraction': 0.8},
          children: [const Text('a'), const Text('b')],
        );
        final controller = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        expect(controller.viewportFraction, 0.8);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('onPageChanged 액션에 새 page index를 event로 보낸다', (tester) async {
        final sink = _RecordingSink();
        await _pump(
          tester,
          const {'on_page_changed': 'turn'},
          dispatch: sink,
          children: [const Text('a'), const Text('b')],
        );

        await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
        await tester.pumpAndSettle();

        expect(sink.calls, [('turn', 1)]);
      });
    });
  });
}
