import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/anchoring_driver.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

/// A driver-facing double: obeys the [AnchorScopeController] timing contract
/// (its future resolves [duration] after `launch`) without touching Flutter's
/// real ticker, so the stagger/ordering tests below can run under
/// [fakeAsync] instead of a widget-bound clock.
class _FakeController implements AnchorScopeController {
  _FakeController({this.rects = const {}, this.items = const {}});

  final Map<String, Rect> rects;
  final Set<String> items;
  final List<Map<String, Object?>> launches = [];

  @override
  Rect? rectFor(String anchorId) => rects[anchorId];

  @override
  bool hasItem(String item) => items.contains(item);

  @override
  Future<void> launch({
    required String item,
    required Offset from,
    required Offset to,
    required Duration duration,
    required Curve curve,
  }) {
    launches.add({
      'item': item,
      'from': from,
      'to': to,
      'duration': duration,
      'curve': curve,
    });
    return Future<void>.delayed(duration);
  }
}

DriverContext _ctx(
  Map<String, Object?> params, {
  EngineRegistries? registries,
  bool Function() isCancelled = _never,
}) => DriverContext(
  params: params,
  state: _NoState(),
  isCancelled: isCancelled,
  host: registries == null ? null : EngineHost(registries: registries),
);

bool _never() => false;

const _rewards = Rect.fromLTWH(0, 0, 10, 10);
const _header = Rect.fromLTWH(100, 0, 10, 10);

EngineRegistries _mounted(_FakeController controller, {String id = 'rewards'}) {
  final registries = EngineRegistries();
  registries.anchorScopes.register(id, controller);
  return registries;
}

void main() {
  group('AnchoringDriver', () {
    group('method', () {
      test('미지 method는 throw', () async {
        await expectLater(
          const AnchoringDriver().run(_ctx({'method': 'nope'})),
          throwsArgumentError,
        );
      });
    });

    group('move — no-op 경로 (throw 안 함)', () {
      test('registries가 아예 없으면(엔진 밖) no-op', () async {
        final result = await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'item': 'coin',
            'from': 'bag',
            'to': 'header',
          }),
        );
        expect(result, isNull);
      });

      test('scope 미등록이면 no-op, launch 안 함', () async {
        final controller = _FakeController(
          rects: {'bag': _rewards, 'header': _header},
          items: {'coin'},
        );
        final result = await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'scope': 'nope',
            'item': 'coin',
            'from': 'bag',
            'to': 'header',
          }, registries: _mounted(controller)),
        );
        expect(result, isNull);
        expect(controller.launches, isEmpty);
      });

      test('스코프가 하나뿐이면 scope 생략 가능', () async {
        final controller = _FakeController(
          rects: {'bag': _rewards, 'header': _header},
          items: {'coin'},
        );
        await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'item': 'coin',
            'from': 'bag',
            'to': 'header',
            'count': 1,
          }, registries: _mounted(controller)),
        );
        expect(controller.launches, hasLength(1));
      });

      test('미지 item이면 no-op, launch 안 함', () async {
        final controller = _FakeController(
          rects: {'bag': _rewards, 'header': _header},
          items: {'coin'},
        );
        final result = await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'item': 'ghost',
            'from': 'bag',
            'to': 'header',
          }, registries: _mounted(controller)),
        );
        expect(result, isNull);
        expect(controller.launches, isEmpty);
      });

      test('미등록 anchor(from/to)면 no-op, launch 안 함', () async {
        final controller = _FakeController(
          rects: {'bag': _rewards}, // 'header' 없음
          items: {'coin'},
        );
        final result = await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'item': 'coin',
            'from': 'bag',
            'to': 'header',
          }, registries: _mounted(controller)),
        );
        expect(result, isNull);
        expect(controller.launches, isEmpty);
      });
    });

    group('move — count', () {
      test('상한(50)을 넘는 count는 캡핑된다', () async {
        final controller = _FakeController(
          rects: {'bag': _rewards, 'header': _header},
          items: {'coin'},
        );
        await const AnchoringDriver().run(
          _ctx({
            'method': 'move',
            'item': 'coin',
            'from': 'bag',
            'to': 'header',
            'count': 10000,
            'stagger': 0,
            'duration': 0,
          }, registries: _mounted(controller)),
        );
        expect(controller.launches, hasLength(50));
      });
    });

    group('move — 순서 (fake_async로 시간 통제)', () {
      test('future는 마지막 개체가 도착한 뒤에만 resolve된다', () {
        fakeAsync((async) {
          final controller = _FakeController(
            rects: {'bag': _rewards, 'header': _header},
            items: {'coin'},
          );
          var done = false;
          const AnchoringDriver()
              .run(
                _ctx({
                  'method': 'move',
                  'item': 'coin',
                  'from': 'bag',
                  'to': 'header',
                  'count': 3,
                  'stagger': 100,
                  'duration': 200,
                }, registries: _mounted(controller)),
              )
              .then((_) => done = true);

          // 발사 시각: 0, 100, 200ms. 각자 착지: 200, 300, 400ms.
          async.elapse(const Duration(milliseconds: 399));
          expect(controller.launches, hasLength(3)); // 셋 다 발사는 끝났고
          expect(done, isFalse); // 마지막(400ms)은 아직

          async.elapse(const Duration(milliseconds: 2));
          expect(done, isTrue); // 마지막 착지 이후 resolve
        });
      });

      test('isCancelled면 이후 개체를 더 발사하지 않는다', () {
        fakeAsync((async) {
          final controller = _FakeController(
            rects: {'bag': _rewards, 'header': _header},
            items: {'coin'},
          );
          var cancelled = false;
          var done = false;
          const AnchoringDriver()
              .run(
                _ctx(
                  {
                    'method': 'move',
                    'item': 'coin',
                    'from': 'bag',
                    'to': 'header',
                    'count': 5,
                    'stagger': 100,
                    'duration': 50,
                  },
                  registries: _mounted(controller),
                  isCancelled: () => cancelled,
                ),
              )
              .then((_) => done = true);

          async.elapse(const Duration(milliseconds: 50)); // 1개 발사(t=0)·착지(t=50)
          expect(controller.launches, hasLength(1));

          cancelled = true; // 취소 — 남은 stagger 대기 중 다음 발사를 접는다
          async.elapse(const Duration(milliseconds: 200));

          expect(controller.launches, hasLength(1)); // 더는 안 늘어남
          expect(done, isTrue); // 이미 발사된 것의 완료로 정상 resolve
        });
      });
    });
  });
}
