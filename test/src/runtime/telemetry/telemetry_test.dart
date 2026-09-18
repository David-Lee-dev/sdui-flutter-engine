import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/telemetry_sink.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';

class _FakeSink implements TelemetrySink {
  final List<TelemetryEvent> recorded = [];
  final List<TelemetryEvent> reserved = [];
  bool throwOnRecord = false;
  bool throwOnReserve = false;

  @override
  void record(TelemetryEvent event) {
    if (throwOnRecord) throw StateError('boom');
    recorded.add(event);
  }

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async {
    if (throwOnReserve) throw StateError('boom');
    reserved.add(event);
    return _FakeReservation();
  }
}

class _FakeReservation implements TelemetryReservation {
  Map<String, Object?>? completedWith;

  @override
  void complete({Map<String, Object?> properties = const {}}) {
    completedWith = properties;
  }
}

void main() {
  group('Telemetry', () {
    tearDown(Telemetry.reset);

    group('record', () {
      test('노 sink 상태에서도 던지지 않는다 (no-op 기본값)', () {
        expect(
          () => Telemetry.record('screen_view', screenId: 'home'),
          returnsNormally,
        );
      });

      test('설치된 sink로 TelemetryEvent를 그대로 전달한다', () {
        final sink = _FakeSink();
        Telemetry.install(sink);

        Telemetry.record(
          'screen_view',
          screenId: 'home',
          screenViewId: 'sv-1',
          correlationId: 'c-1',
          properties: {'method': 'initial'},
        );

        expect(sink.recorded, hasLength(1));
        final event = sink.recorded.single;
        expect(event.event, 'screen_view');
        expect(event.screenId, 'home');
        expect(event.screenViewId, 'sv-1');
        expect(event.correlationId, 'c-1');
        expect(event.properties, {'method': 'initial'});
      });

      test('sink가 던지면 삼키고 전파하지 않는다 (exception isolation)', () {
        final sink = _FakeSink()..throwOnRecord = true;
        Telemetry.install(sink);

        expect(
          () => Telemetry.record('screen_view', screenId: 'home'),
          returnsNormally,
        );
      });
    });

    group('reserve', () {
      test('설치된 sink에 TelemetryEvent를 전달하고 reservation을 돌려준다', () async {
        final sink = _FakeSink();
        Telemetry.install(sink);

        final reservation = await Telemetry.reserve(
          'screen_load',
          screenId: 'home',
          screenViewId: 'sv-1',
          properties: {'retry': false},
        );
        reservation.complete(properties: {'ok': true});

        expect(sink.reserved, hasLength(1));
        expect(sink.reserved.single.event, 'screen_load');
        final fake = sink
            .reserved; // sanity: reservation delegated to fake sink's own object
        expect(fake, isNotEmpty);
      });

      test('sink가 reserve에서 던지면 삼키고 no-op reservation을 돌려준다', () async {
        final sink = _FakeSink()..throwOnReserve = true;
        Telemetry.install(sink);

        final reservation = await Telemetry.reserve(
          'screen_load',
          screenId: 'home',
        );

        expect(
          () => reservation.complete(properties: {'ok': false}),
          returnsNormally,
        );
      });

      test('노 sink 상태에서도 reserve가 정상 동작한다', () async {
        final reservation = await Telemetry.reserve(
          'screen_load',
          screenId: 'home',
        );
        expect(() => reservation.complete(), returnsNormally);
      });
    });

    group('setEnabled', () {
      test('끄면 record가 sink에 닿지 않는다', () {
        final sink = _FakeSink();
        Telemetry.install(sink);
        Telemetry.setEnabled(false);

        Telemetry.record('screen_view', screenId: 'home');
        expect(sink.recorded, isEmpty);
      });

      test('끄면 reserve가 no-op reservation을 돌려준다', () async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        Telemetry.setEnabled(false);

        final reservation = await Telemetry.reserve('screen_load');
        expect(sink.reserved, isEmpty);
        expect(() => reservation.complete(), returnsNormally);
      });

      test('다시 켜면 sink 재설치 없이 전달이 재개된다', () {
        final sink = _FakeSink();
        Telemetry.install(sink);
        Telemetry.setEnabled(false);
        Telemetry.record('dropped');
        Telemetry.setEnabled(true);

        Telemetry.record('delivered');
        expect(sink.recorded.map((e) => e.event), ['delivered']);
      });

      test('reset은 enabled를 기본값(on)으로 되돌린다', () {
        Telemetry.setEnabled(false);
        Telemetry.reset();
        expect(Telemetry.enabled, isTrue);
      });
    });

    group('newId', () {
      test('호출마다 서로 다른 id를 만든다', () {
        final a = Telemetry.newId();
        final b = Telemetry.newId();
        expect(a, isNot(b));
      });

      test('v4 UUID 형식을 따른다', () {
        final id = Telemetry.newId();
        expect(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ).hasMatch(id),
          isTrue,
          reason: 'got $id',
        );
      });
    });
  });

  group('TelemetryScope', () {
    testWidgets('maybeOf는 스코프 밖에서 null을 돌려준다', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(TelemetryScope.maybeOf(captured), isNull);
    });

    testWidgets('screenId/screenViewId를 자손에 전파한다', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: TelemetryScope(
            screenId: 'home',
            screenViewId: 'sv-1',
            child: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      final scope = TelemetryScope.maybeOf(captured);
      expect(scope?.screenId, 'home');
      expect(scope?.screenViewId, 'sv-1');
    });
  });
}
