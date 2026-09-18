import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/scratch_card_widget.dart';
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
  SizedBox(key: ValueKey('revealed')),
  SizedBox(key: ValueKey('foil')),
];

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
  Size size = const Size(200, 100),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: EngineMetrics(
        scale: 1,
        child: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Builder(
              builder: (context) =>
                  ScratchCardWidget.build(context, props, _children, dispatch),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Drags a straight line across the card, sampling every [step] logical pixels.
Future<void> _scratch(
  WidgetTester tester, {
  required Offset from,
  required Offset to,
  int steps = 20,
}) async {
  final gesture = await tester.startGesture(from);
  for (var i = 1; i <= steps; i++) {
    await gesture.moveTo(Offset.lerp(from, to, i / steps)!);
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

void main() {
  group('ScratchCardWidget', () {
    testWidgets('두 자식을 겹쳐 그린다 — 아래가 당첨면, 위가 긁는 면', (tester) async {
      await _pump(tester, const {});

      expect(find.byKey(const ValueKey('revealed')), findsOneWidget);
      expect(find.byKey(const ValueKey('foil')), findsOneWidget);
    });

    testWidgets('긁기 전에는 진행도를 알리지 않는다', (tester) async {
      final sink = _RecordingSink();
      await _pump(tester, const {'on_changed': 'report'}, dispatch: sink);

      expect(sink.calls, isEmpty);
    });

    testWidgets('긁으면 진행도를 정수 퍼센트로 올려 보낸다', (tester) async {
      final sink = _RecordingSink();
      await _pump(tester, const {
        'on_changed': 'report',
        'brush_size': 40.0,
      }, dispatch: sink);

      await _scratch(
        tester,
        from: tester.getTopLeft(find.byType(Stack)) + const Offset(10, 50),
        to: tester.getTopLeft(find.byType(Stack)) + const Offset(190, 50),
      );

      expect(sink.calls, isNotEmpty);
      expect(sink.calls.every((call) => call.$1 == 'report'), isTrue);
      final percents = sink.calls.map((call) => call.$2! as int).toList();
      expect(percents.first, greaterThan(0));
      expect(percents, orderedEquals(percents.toList()..sort()));
    });

    testWidgets('임계치를 넘으면 on_threshold 가 정확히 한 번 발화한다', (tester) async {
      final sink = _RecordingSink();
      await _pump(tester, const {
        'on_threshold': 'claim',
        'threshold': 10,
        'brush_size': 80.0,
      }, dispatch: sink);

      final origin = tester.getTopLeft(find.byType(Stack));
      await _scratch(
        tester,
        from: origin + const Offset(10, 50),
        to: origin + const Offset(190, 50),
      );
      await _scratch(
        tester,
        from: origin + const Offset(10, 20),
        to: origin + const Offset(190, 20),
      );

      expect(sink.calls.where((call) => call.$1 == 'claim'), hasLength(1));
    });

    testWidgets('임계치를 넘긴 뒤에는 더 긁어도 진행도만 오른다', (tester) async {
      final sink = _RecordingSink();
      await _pump(tester, const {
        'on_changed': 'report',
        'on_threshold': 'claim',
        'threshold': 5,
        'brush_size': 80.0,
      }, dispatch: sink);

      final origin = tester.getTopLeft(find.byType(Stack));
      await _scratch(
        tester,
        from: origin + const Offset(10, 50),
        to: origin + const Offset(190, 50),
      );
      final afterFirst = sink.calls.length;
      await _scratch(
        tester,
        from: origin + const Offset(10, 80),
        to: origin + const Offset(190, 80),
      );

      expect(sink.calls.length, greaterThan(afterFirst));
      expect(sink.calls.where((call) => call.$1 == 'claim'), hasLength(1));
    });

    testWidgets('reset_token 이 바뀌면 지운 자국과 임계치 걸쇠가 함께 풀린다', (tester) async {
      final sink = _RecordingSink();
      await _pump(tester, const {
        'on_threshold': 'claim',
        'threshold': 5,
        'brush_size': 80.0,
        'reset_token': 1,
      }, dispatch: sink);

      final origin = tester.getTopLeft(find.byType(Stack));
      await _scratch(
        tester,
        from: origin + const Offset(10, 50),
        to: origin + const Offset(190, 50),
      );
      expect(sink.calls.where((call) => call.$1 == 'claim'), hasLength(1));

      await _pump(tester, const {
        'on_threshold': 'claim',
        'threshold': 5,
        'brush_size': 80.0,
        'reset_token': 2,
      }, dispatch: sink);
      await _scratch(
        tester,
        from: origin + const Offset(10, 50),
        to: origin + const Offset(190, 50),
      );

      expect(sink.calls.where((call) => call.$1 == 'claim'), hasLength(2));
    });

    testWidgets('reset_token 이 그대로면 임계치는 다시 걸리지 않는다', (tester) async {
      final sink = _RecordingSink();
      const props = {
        'on_threshold': 'claim',
        'threshold': 5,
        'brush_size': 80.0,
        'reset_token': 1,
      };
      await _pump(tester, props, dispatch: sink);

      final origin = tester.getTopLeft(find.byType(Stack));
      await _scratch(
        tester,
        from: origin + const Offset(10, 50),
        to: origin + const Offset(190, 50),
      );
      await _pump(tester, props, dispatch: sink);
      await _scratch(
        tester,
        from: origin + const Offset(10, 20),
        to: origin + const Offset(190, 20),
      );

      expect(sink.calls.where((call) => call.$1 == 'claim'), hasLength(1));
    });

    testWidgets('카탈로그에 action 위젯으로 등록돼 있다', (tester) async {
      WidgetFactory.ensureRegistered();

      expect(WidgetFactory.knows('scratch_card'), isTrue);
    });
  });
}
