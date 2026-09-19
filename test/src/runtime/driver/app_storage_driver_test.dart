import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/app_storage.dart';
import 'package:sdui_engine/src/runtime/driver/app_storage_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

/// 인메모리 fake — 쓰기 호출도 기록해 삭제(null)를 검증한다.
class _FakeStore implements AppStorage {
  _FakeStore([Map<String, Object?>? initial]) : data = {...?initial};

  final Map<String, Object?> data;
  final sets = <MapEntry<String, Object?>>[];

  @override
  Object? get(String key) => data[key];

  @override
  Future<void> set(String key, Object? value) async {
    sets.add(MapEntry(key, value));
    if (value == null) {
      data.remove(key);
    } else {
      data[key] = value;
    }
  }
}

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

DriverContext _ctx(Map<String, Object?> params, {bool cancelled = false}) =>
    DriverContext(
      params: params,
      state: _NoState(),
      isCancelled: () => cancelled,
    );

void main() {
  group('AppStorageDriver', () {
    late _FakeStore store;
    late AppStorageDriver driver;

    setUp(() {
      store = _FakeStore({'seen': true, 'count': 3});
      driver = AppStorageDriver(store: store);
    });

    group('get', () {
      test('저장값을 반환한다', () async {
        expect(await driver.run(_ctx({'method': 'get', 'key': 'seen'})), true);
      });

      test('없는 키는 null', () async {
        expect(
          await driver.run(_ctx({'method': 'get', 'key': 'nope'})),
          isNull,
        );
      });
    });

    group('set', () {
      test('값을 쓰고 쓴 값을 반환한다', () async {
        final result = await driver.run(
          _ctx({'method': 'set', 'key': 'seen', 'value': false}),
        );
        expect(store.data['seen'], false);
        expect(result, false);
      });

      test('method 기본은 set', () async {
        await driver.run(_ctx({'key': 'lang', 'value': 'ko'}));
        expect(store.data['lang'], 'ko');
      });

      test('value 없으면 그 키를 삭제한다', () async {
        await driver.run(_ctx({'method': 'set', 'key': 'seen'}));
        expect(store.data.containsKey('seen'), isFalse);
        expect(store.sets.single.value, isNull);
      });

      test('value: null도 삭제', () async {
        await driver.run(_ctx({'method': 'set', 'key': 'seen', 'value': null}));
        expect(store.data.containsKey('seen'), isFalse);
      });

      test('owner가 이미 사라졌으면(isCancelled) 쓰지 않는다 (유령 write 방지)', () async {
        // 소멸한 화면의 늦은 set이 새 화면 값을 덮지 않게 — 문서화된 isCancelled 계약을 지킨다.
        // (best-effort: 쓰기 시작 전 창만 닫는다.)
        final result = await driver.run(
          _ctx({
            'method': 'set',
            'key': 'seen',
            'value': false,
          }, cancelled: true),
        );
        expect(store.sets, isEmpty); // 저장소에 안 씀
        expect(store.data['seen'], true); // 기존 값 그대로
        expect(result, false); // 반환은 유지(죽은 flow라 무의미하지만 계약 일관)
      });
    });

    group('stamp', () {
      test('현재 시각을 epoch ms(int)로 쓰고 그 값을 반환한다', () async {
        final fixed = DateTime(2026, 8, 19, 10, 30);
        final clocked = AppStorageDriver(store: store, now: () => fixed);
        final result = await clocked.run(
          _ctx({'method': 'stamp', 'key': 'lastSeen'}),
        );
        expect(result, fixed.millisecondsSinceEpoch);
        expect(store.data['lastSeen'], fixed.millisecondsSinceEpoch);
      });

      test('owner가 이미 사라졌으면(isCancelled) 쓰지 않는다', () async {
        final fixed = DateTime(2026, 8, 19, 10, 30);
        final clocked = AppStorageDriver(store: store, now: () => fixed);
        final result = await clocked.run(
          _ctx({'method': 'stamp', 'key': 'lastSeen'}, cancelled: true),
        );
        expect(store.sets, isEmpty);
        expect(result, fixed.millisecondsSinceEpoch);
      });
    });

    group('due', () {
      test('키가 없으면 true (한번도 stamp 안 됨)', () async {
        expect(
          await driver.run(_ctx({'method': 'due', 'key': 'popup.daily'})),
          isTrue,
        );
      });

      test('저장값이 int가 아니면 true (구 set이 남긴 다른 타입)', () async {
        store.data['popup.daily'] = 'yes';
        expect(
          await driver.run(_ctx({'method': 'due', 'key': 'popup.daily'})),
          isTrue,
        );
      });

      test('같은 날 이전에 stamp 됐으면 false', () async {
        final now = DateTime(2026, 8, 19, 18, 0);
        store.data['popup.daily'] = DateTime(
          2026,
          8,
          19,
          9,
          0,
        ).millisecondsSinceEpoch;
        final clocked = AppStorageDriver(store: store, now: () => now);
        expect(
          await clocked.run(_ctx({'method': 'due', 'key': 'popup.daily'})),
          isFalse,
        );
      });

      test('전날 23:50에 stamp, 다음날 00:10이면 true (달력일 경계)', () async {
        store.data['popup.daily'] = DateTime(
          2026,
          8,
          18,
          23,
          50,
        ).millisecondsSinceEpoch;
        final now = DateTime(2026, 8, 19, 0, 10);
        final clocked = AppStorageDriver(store: store, now: () => now);
        expect(
          await clocked.run(_ctx({'method': 'due', 'key': 'popup.daily'})),
          isTrue,
        );
      });

      test('days: 7 — 6일 경과는 false', () async {
        store.data['popup.weekly'] = DateTime(
          2026,
          8,
          13,
        ).millisecondsSinceEpoch;
        final now = DateTime(2026, 8, 19);
        final clocked = AppStorageDriver(store: store, now: () => now);
        expect(
          await clocked.run(
            _ctx({'method': 'due', 'key': 'popup.weekly', 'days': 7}),
          ),
          isFalse,
        );
      });

      test('days: 7 — 7일 경과는 true', () async {
        store.data['popup.weekly'] = DateTime(
          2026,
          8,
          12,
        ).millisecondsSinceEpoch;
        final now = DateTime(2026, 8, 19);
        final clocked = AppStorageDriver(store: store, now: () => now);
        expect(
          await clocked.run(
            _ctx({'method': 'due', 'key': 'popup.weekly', 'days': 7}),
          ),
          isTrue,
        );
      });

      test('stamp가 미래면 true (기기 시계가 뒤로 감긴 경우 영구 잠금 방지)', () async {
        store.data['popup.daily'] = DateTime(
          2026,
          8,
          20,
        ).millisecondsSinceEpoch;
        final now = DateTime(2026, 8, 19);
        final clocked = AppStorageDriver(store: store, now: () => now);
        expect(
          await clocked.run(_ctx({'method': 'due', 'key': 'popup.daily'})),
          isTrue,
        );
      });

      test('days가 int가 아니면 throw', () async {
        await expectLater(
          driver.run(
            _ctx({'method': 'due', 'key': 'popup.daily', 'days': '7'}),
          ),
          throwsArgumentError,
        );
      });

      test('days가 음수면 throw', () async {
        await expectLater(
          driver.run(_ctx({'method': 'due', 'key': 'popup.daily', 'days': -1})),
          throwsArgumentError,
        );
      });
    });

    group('validation', () {
      test('key 없으면 throw', () async {
        await expectLater(
          driver.run(_ctx({'method': 'get'})),
          throwsArgumentError,
        );
      });

      test('빈 key는 throw', () async {
        await expectLater(
          driver.run(_ctx({'method': 'get', 'key': ''})),
          throwsArgumentError,
        );
      });

      test('미지 method는 throw', () async {
        await expectLater(
          driver.run(_ctx({'method': 'frobnicate', 'key': 'x'})),
          throwsArgumentError,
        );
      });
    });
  });
}
