import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/telemetry_sink.dart';
import 'package:sdui_engine/src/impl/noop_telemetry_sink.dart';

void main() {
  group('NoopTelemetrySink', () {
    group('record', () {
      test('drops the event without throwing', () {
        const sink = NoopTelemetrySink();
        expect(
          () => sink.record(const TelemetryEvent(event: 'screen_view')),
          returnsNormally,
        );
      });
    });

    group('reserve', () {
      test('returns a reservation whose complete is a no-op', () async {
        const sink = NoopTelemetrySink();
        final reservation = await sink.reserve(
          const TelemetryEvent(event: 'screen_load'),
        );
        expect(
          () => reservation.complete(properties: {'ms': 1}),
          returnsNormally,
        );
      });
    });
  });
}
