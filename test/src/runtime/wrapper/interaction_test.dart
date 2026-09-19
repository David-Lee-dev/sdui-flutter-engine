import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';

class _Sink implements TelemetrySink {
  final events = <TelemetryEvent>[];

  @override
  void record(TelemetryEvent event) => events.add(event);

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) =>
      throw UnimplementedError();
}

void main() {
  tearDown(Telemetry.reset);

  group('InteractionWrapper', () {
    group('handler', () {
      testWidgets('accepted gesture records node and invocation identity', (
        tester,
      ) async {
        final sink = _Sink();
        Telemetry.install(sink);
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: TelemetryScope(
              screenId: 'home',
              screenViewId: 'view-1',
              child: InteractionWrapper(
                on: {'tap': 'open'},
                node: ActionNode(type: 'text', path: r'$[0]'),
                feedback: false,
                child: SizedBox(width: 40, height: 40),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector), warnIfMissed: false);

        final event = sink.events.single;
        expect(event.event, 'action_intent');
        expect(event.screenViewId, 'view-1');
        expect(event.properties['accepted'], isTrue);
        expect(event.properties['node_type'], 'text');
        expect(event.properties['node_path'], r'$[0]');
        expect(event.properties['invocation_id'], event.correlationId);
      });

      testWidgets(
        'throttled attempts are aggregated after the three-second window',
        (tester) async {
          final sink = _Sink();
          Telemetry.install(sink);
          await tester.pumpWidget(
            const Directionality(
              textDirection: TextDirection.ltr,
              child: InteractionWrapper(
                on: {'tap': 'open'},
                node: ActionNode(type: 'text', path: r'$[0]'),
                timing: {'tap': EventTiming.throttle(Duration(seconds: 1))},
                feedback: false,
                child: SizedBox(width: 40, height: 40),
              ),
            ),
          );

          await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
          await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
          await tester.pump(const Duration(seconds: 3));

          expect(sink.events, hasLength(2));
          expect(sink.events.first.properties['accepted'], isTrue);
          expect(sink.events.last.properties, containsPair('accepted', false));
          expect(sink.events.last.properties, containsPair('count', 1));
          expect(sink.events.last.properties, isNot(contains('invocation_id')));
        },
      );
    });
  });
}
