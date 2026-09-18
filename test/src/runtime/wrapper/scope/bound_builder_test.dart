import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/telemetry_sink.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/bound_builder.dart';

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

  group('BoundBuilder', () {
    group('input trail', () {
      testWidgets('records counts and submission without any payload value', (
        tester,
      ) async {
        final sink = _Sink();
        Telemetry.install(sink);
        ValueChanged<Object?>? change;
        ValueChanged<Object?>? submit;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BoundBuilder(
              bind: null,
              fieldId: 'email',
              validation: 'invalid',
              on: const {'change': 'changed', 'submit': 'submitted'},
              builder: (context, value, onChanged, onSubmit) {
                change = onChanged;
                submit = onSubmit;
                return const SizedBox();
              },
            ),
          ),
        );

        change!({
          'value': 'private',
          'nested': {'token': 'secret'},
        });
        submit!('private');

        expect(sink.events, hasLength(2));
        expect(sink.events.first.properties, {
          'field_id': 'email',
          'changed_count': 1,
          'submitted': false,
          'validation': 'invalid',
        });
        expect(sink.events.last.properties['submitted'], isTrue);
        expect(sink.events.toString(), isNot(contains('private')));
        expect(sink.events.toString(), isNot(contains('secret')));
      });
    });
  });
}
