import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/haptic_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

/// 실제 진동 없이 호출 시퀀스를 기록하는 fake player.
class _FakeHapticPlayer implements HapticPlayer {
  final calls = <String>[];

  @override
  Future<void> impact(HapticLevel level) async =>
      calls.add('impact:${level.name}');

  @override
  Future<void> selection() async => calls.add('selection');

  @override
  Future<void> vibrate() async => calls.add('vibrate');
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
  group('HapticDriver', () {
    late _FakeHapticPlayer player;
    late HapticDriver driver;

    setUp(() {
      player = _FakeHapticPlayer();
      driver = HapticDriver(player: player);
    });

    group('run', () {
      test('variant 없으면 light 단발', () async {
        await driver.run(_ctx(const {}));
        expect(player.calls, ['impact:light']);
      });

      test(
        'semantic success = base light에 offsets [0,1] → light,medium',
        () async {
          await driver.run(_ctx(const {'variant': 'success'}));
          expect(player.calls, ['impact:light', 'impact:medium']);
        },
      );

      test('semantic error = base strong에 3펄스', () async {
        await driver.run(_ctx(const {'variant': 'error'}));
        expect(player.calls, [
          'impact:strong',
          'impact:strong',
          'impact:strong',
        ]);
      });

      test('intensity가 semantic base를 덮는다 (offset은 clamp)', () async {
        await driver.run(
          _ctx(const {'variant': 'success', 'intensity': 'strong'}),
        );
        expect(player.calls, ['impact:strong', 'impact:strong']);
      });

      test('legacy selection/vibrate는 직결', () async {
        await driver.run(_ctx(const {'variant': 'selection'}));
        expect(player.calls, ['selection']);
        player.calls.clear();
        await driver.run(_ctx(const {'variant': 'vibrate'}));
        expect(player.calls, ['vibrate']);
      });

      test('legacy medium/heavy 단발', () async {
        await driver.run(_ctx(const {'variant': 'medium'}));
        expect(player.calls, ['impact:medium']);
        player.calls.clear();
        await driver.run(_ctx(const {'variant': 'heavy'}));
        expect(player.calls, ['impact:strong']);
      });

      test('미지 variant는 light로 폴백', () async {
        await driver.run(_ctx(const {'variant': 'nonsense'}));
        expect(player.calls, ['impact:light']);
      });

      test('반환은 null', () async {
        expect(await driver.run(_ctx(const {})), isNull);
      });

      test('isCancelled면 아무것도 안 친다', () async {
        await driver.run(_ctx(const {'variant': 'error'}, cancelled: true));
        expect(player.calls, isEmpty);
      });
    });
  });

  group('HapticSemantics', () {
    late _FakeHapticPlayer player;

    setUp(() => player = _FakeHapticPlayer());

    group('play', () {
      test('어휘에 있는 이름은 리듬을 치고 true', () async {
        expect(await HapticSemantics.play('error', player: player), isTrue);
        expect(player.calls, [
          'impact:strong',
          'impact:strong',
          'impact:strong',
        ]);
      });

      test('어휘 밖 이름은 아무것도 안 치고 false — 호출부가 단발로 폴백한다', () async {
        expect(await HapticSemantics.play('medium', player: player), isFalse);
        expect(await HapticSemantics.play(null, player: player), isFalse);
        expect(player.calls, isEmpty);
      });

      test('intensity는 base만 덮고 리듬은 그대로', () async {
        await HapticSemantics.play(
          'success',
          intensity: HapticLevel.medium,
          player: player,
        );
        expect(player.calls, ['impact:medium', 'impact:strong']);
      });

      test('isCancelled면 남은 펄스를 멈춘다', () async {
        await HapticSemantics.play(
          'error',
          player: player,
          isCancelled: () => player.calls.isNotEmpty,
        );
        expect(player.calls, ['impact:strong']);
      });
    });

    group('level', () {
      test('세기 이름을 읽는다 — heavy는 strong 별칭', () {
        expect(HapticSemantics.level('light'), HapticLevel.light);
        expect(HapticSemantics.level('medium'), HapticLevel.medium);
        expect(HapticSemantics.level('strong'), HapticLevel.strong);
        expect(HapticSemantics.level('heavy'), HapticLevel.strong);
      });

      test('모르는 값은 null — 패턴 기본 base가 살아난다', () {
        expect(HapticSemantics.level('nonsense'), isNull);
        expect(HapticSemantics.level(null), isNull);
      });
    });
  });
}
