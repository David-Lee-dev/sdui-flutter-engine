import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/haptic/haptic_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

/// 실제 진동 없이 호출 시퀀스를 기록하는 fake player.
class _FakeHapticPlayer implements HapticPlayer {
  _FakeHapticPlayer({this.taps = false});

  /// 기기가 native tap을 지원하는지.
  final bool taps;
  final calls = <String>[];

  @override
  Future<bool> supportsTaps() async => taps;

  @override
  Future<void> tap(double intensity, double sharpness) async =>
      calls.add('tap:$intensity/$sharpness');

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

    group('pattern', () {
      test('지원 기기는 variant를 무시하고 tap을 값 clamp·delay대로 친다', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          HapticDriver(player: taps).run(
            _ctx(const {
              'variant': 'error',
              'pattern': [
                {'intensity': 0.4},
                {'intensity': 1.5, 'sharpness': 0.7, 'delay': 90},
                {'intensity': 0.2, 'sharpness': 2, 'delay': 90},
              ],
            }),
          );

          async.flushMicrotasks();
          expect(taps.calls, ['tap:0.4/0.5']);
          async.elapse(const Duration(milliseconds: 89));
          expect(taps.calls, hasLength(1));
          async.elapse(const Duration(milliseconds: 1));
          expect(taps.calls, ['tap:0.4/0.5', 'tap:1.0/0.7']);
          async.elapse(const Duration(milliseconds: 90));
          expect(taps.calls, ['tap:0.4/0.5', 'tap:1.0/0.7', 'tap:0.2/1.0']);
          async.elapse(const Duration(seconds: 1));
          expect(taps.calls, hasLength(3));
        });
      });

      test('첫 펄스의 delay는 그 앞의 대기, 음수 delay는 0', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          HapticDriver(player: taps).run(
            _ctx(const {
              'pattern': [
                {'delay': 50},
                {'delay': -30},
              ],
            }),
          );

          async.elapse(const Duration(milliseconds: 49));
          expect(taps.calls, isEmpty);
          async.elapse(const Duration(milliseconds: 1));
          expect(taps.calls, ['tap:1.0/0.5', 'tap:1.0/0.5']);
        });
      });

      test('intensity 0(음수 clamp 포함) 펄스는 치지 않고 delay만 지킨다', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          HapticDriver(player: taps).run(
            _ctx(const {
              'pattern': [
                {'intensity': 0.5},
                {'intensity': 0, 'delay': 100},
                {'intensity': 0.7, 'delay': 100},
                {'intensity': -1, 'delay': 100},
              ],
            }),
          );

          async.flushMicrotasks();
          expect(taps.calls, ['tap:0.5/0.5']);
          async.elapse(const Duration(milliseconds: 199));
          expect(taps.calls, ['tap:0.5/0.5']);
          async.elapse(const Duration(milliseconds: 1));
          expect(taps.calls, ['tap:0.5/0.5', 'tap:0.7/0.5']);
          async.elapse(const Duration(seconds: 1));
          expect(taps.calls, ['tap:0.5/0.5', 'tap:0.7/0.5']);
        });
      });

      test('빠졌거나 숫자가 아닌 키는 기본값 intensity 1, sharpness 0.5, delay 0', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          HapticDriver(player: taps).run(
            _ctx(const {
              'pattern': [
                <String, Object?>{},
                {'intensity': 'x', 'sharpness': null, 'delay': '90'},
              ],
            }),
          );

          async.flushMicrotasks();
          expect(taps.calls, ['tap:1.0/0.5', 'tap:1.0/0.5']);
        });
      });

      test('미지원 기기는 legacy variant로 친다', () async {
        await driver.run(
          _ctx(const {
            'variant': 'success',
            'pattern': [
              {'intensity': 0.4},
            ],
          }),
        );
        expect(player.calls, ['impact:light', 'impact:medium']);
      });

      test('미지원 기기에 variant가 없거나 모르는 이름이면 아무것도 안 친다', () async {
        const pattern = [
          {'intensity': 0.4},
        ];
        await driver.run(_ctx(const {'pattern': pattern}));
        await driver.run(_ctx(const {'pattern': pattern, 'variant': 'wave'}));
        expect(player.calls, isEmpty);
      });

      test('비어 있지 않은 map 목록이 아니면 pattern이 없는 것으로 본다', () async {
        final taps = _FakeHapticPlayer(taps: true);
        const malformed = <Object?>[
          'buzz',
          <Object?>[],
          [1, 2],
          {'intensity': 0.4},
          [
            {'intensity': 0.4},
            3,
          ],
        ];
        for (final pattern in malformed) {
          await HapticDriver(
            player: taps,
          ).run(_ctx({'variant': 'medium', 'pattern': pattern}));
        }
        expect(taps.calls, List.filled(malformed.length, 'impact:medium'));
      });

      test('첫 펄스 전에 취소되면 아무것도 안 친다', () async {
        final taps = _FakeHapticPlayer(taps: true);
        await HapticDriver(player: taps).run(
          _ctx(const {
            'pattern': [
              {'intensity': 0.4},
            ],
          }, cancelled: true),
        );
        expect(taps.calls, isEmpty);
      });

      test('펄스 사이에 취소되면 남은 펄스를 멈춘다', () async {
        final taps = _FakeHapticPlayer(taps: true);
        await HapticDriver(player: taps).run(
          DriverContext(
            params: const {
              'pattern': [
                {'intensity': 0.4},
                {'intensity': 0.9},
              ],
            },
            state: _NoState(),
            isCancelled: () => taps.calls.isNotEmpty,
          ),
        );
        expect(taps.calls, ['tap:0.4/0.5']);
      });

      test('delay 동안 취소되면 그 뒤 펄스를 치지 않는다', () {
        final taps = _FakeHapticPlayer(taps: true);
        var cancelled = false;
        fakeAsync((async) {
          HapticDriver(player: taps).run(
            DriverContext(
              params: const {
                'pattern': [
                  {'intensity': 0.4},
                  {'intensity': 0.9, 'delay': 90},
                ],
              },
              state: _NoState(),
              isCancelled: () => cancelled,
            ),
          );

          async.elapse(const Duration(milliseconds: 40));
          cancelled = true;
          async.elapse(const Duration(seconds: 1));
          expect(taps.calls, ['tap:0.4/0.5']);
        });
      });
    });

    group('preset variant', () {
      const legacy = {
        'success',
        'warning',
        'error',
        'light',
        'medium',
        'heavy',
        'strong',
        'selection',
        'vibrate',
      };

      test('지원 기기에서 crescendo는 표의 세기·날카로움·간격대로 7번 친다', () {
        final taps = _FakeHapticPlayer(taps: true);
        const expected = [
          (1, 'tap:0.303/0.303'),
          (98, 'tap:0.397/0.397'),
          (103, 'tap:0.506/0.506'),
          (98, 'tap:0.609/0.609'),
          (99, 'tap:0.703/0.703'),
          (103, 'tap:0.809/0.809'),
          (99, 'tap:0.981/0.981'),
        ];
        fakeAsync((async) {
          HapticDriver(player: taps).run(_ctx(const {'variant': 'crescendo'}));

          async.flushMicrotasks();
          for (var i = 0; i < expected.length; i++) {
            final (delay, call) = expected[i];
            async.elapse(Duration(milliseconds: delay - 1));
            expect(taps.calls, hasLength(i), reason: call);
            async.elapse(const Duration(milliseconds: 1));
            expect(taps.calls, [for (final e in expected.take(i + 1)) e.$2]);
          }
          async.elapse(const Duration(seconds: 1));
          expect(taps.calls, hasLength(7));
        });
      });

      test('미지원 기기에서 preset 이름은 아무것도 안 친다', () async {
        await driver.run(_ctx(const {'variant': 'crescendo'}));
        expect(player.calls, isEmpty);
      });

      test('pattern이 있으면 preset 대신 pattern을 친다', () async {
        final taps = _FakeHapticPlayer(taps: true);
        await HapticDriver(player: taps).run(
          _ctx(const {
            'variant': 'crescendo',
            'pattern': [
              {'intensity': 0.4},
            ],
          }),
        );
        expect(taps.calls, ['tap:0.4/0.5']);
      });

      test('표 무결성 — 45개, 비어 있지 않음, 값 범위, snake_case, legacy와 안 겹침', () {
        expect(hapticPresets, hasLength(45));
        for (final MapEntry(:key, :value) in hapticPresets.entries) {
          expect(key, matches(RegExp(r'^[a-z]+(_[a-z]+)*$')));
          expect(legacy, isNot(contains(key)), reason: key);
          expect(value, isNotEmpty, reason: key);
          for (final p in value) {
            expect(p.intensity, inInclusiveRange(0, 1), reason: key);
            expect(p.sharpness, inInclusiveRange(0, 1), reason: key);
            expect(p.delay, greaterThanOrEqualTo(Duration.zero), reason: key);
          }
        }
      });
    });

    group('legacy preset (지원 기기)', () {
      test('success는 0.5 tap, 정확히 70ms 뒤 0.7 tap', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          HapticDriver(player: taps).run(_ctx(const {'variant': 'success'}));

          async.flushMicrotasks();
          expect(taps.calls, ['tap:0.5/0.5']);
          async.elapse(const Duration(milliseconds: 69));
          expect(taps.calls, ['tap:0.5/0.5']);
          async.elapse(const Duration(milliseconds: 1));
          expect(taps.calls, ['tap:0.5/0.5', 'tap:0.7/0.5']);
          async.elapse(const Duration(seconds: 1));
          expect(taps.calls, hasLength(2));
        });
      });

      test('error는 1.0 tap 3번, warning은 0.7 tap 2번 — 130ms 간격', () {
        final taps = _FakeHapticPlayer(taps: true);
        fakeAsync((async) {
          for (final (variant, call, count) in [
            ('error', 'tap:1.0/0.5', 3),
            ('warning', 'tap:0.7/0.5', 2),
          ]) {
            taps.calls.clear();
            HapticDriver(player: taps).run(_ctx({'variant': variant}));

            async.flushMicrotasks();
            expect(taps.calls, [call], reason: variant);
            for (var i = 2; i <= count; i++) {
              async.elapse(const Duration(milliseconds: 129));
              expect(taps.calls, hasLength(i - 1), reason: variant);
              async.elapse(const Duration(milliseconds: 1));
              expect(taps.calls, List.filled(i, call), reason: variant);
            }
            async.elapse(const Duration(seconds: 1));
            expect(taps.calls, hasLength(count), reason: variant);
          }
        });
      });

      test('light는 0.5 tap 한 번', () async {
        final taps = _FakeHapticPlayer(taps: true);
        await HapticDriver(player: taps).run(_ctx(const {'variant': 'light'}));
        expect(taps.calls, ['tap:0.5/0.5']);
      });

      test('intensity 이름은 legacy preset tap을 바꾸지 않는다', () async {
        final taps = _FakeHapticPlayer(taps: true);
        await HapticDriver(
          player: taps,
        ).run(_ctx(const {'variant': 'warning', 'intensity': 'heavy'}));
        expect(taps.calls, ['tap:0.7/0.5', 'tap:0.7/0.5']);
      });

      test('표 무결성 — 4개 키, 값 범위, delay >= 0', () {
        expect(
          legacyPresets.keys,
          unorderedEquals(const ['light', 'success', 'warning', 'error']),
        );
        for (final MapEntry(:key, :value) in legacyPresets.entries) {
          for (final p in value) {
            expect(p.intensity, inInclusiveRange(0, 1), reason: key);
            expect(p.sharpness, inInclusiveRange(0, 1), reason: key);
            expect(p.delay, greaterThanOrEqualTo(Duration.zero), reason: key);
          }
        }
      });
    });

    group('legacy variant (지원 기기, legacy preset 밖)', () {
      late _FakeHapticPlayer taps;

      setUp(() => taps = _FakeHapticPlayer(taps: true));

      Future<List<String>> play(Map<String, Object?> params) async {
        taps.calls.clear();
        await HapticDriver(player: taps).run(_ctx(params));
        return List.of(taps.calls);
      }

      test('각 이름은 예전 호출 그대로', () async {
        expect(await play({'variant': 'medium'}), ['impact:medium']);
        expect(await play({'variant': 'heavy'}), ['impact:strong']);
        expect(await play({'variant': 'strong'}), ['impact:strong']);
        expect(await play({'variant': 'selection'}), ['selection']);
        expect(await play({'variant': 'vibrate'}), ['vibrate']);
      });
    });

    group('legacy variant (미지원 기기)', () {
      Future<List<String>> play(Map<String, Object?> params) async {
        player.calls.clear();
        await driver.run(_ctx(params));
        return List.of(player.calls);
      }

      test('legacy preset 이름도 예전 호출 그대로', () async {
        expect(await play({'variant': 'success'}), [
          'impact:light',
          'impact:medium',
        ]);
        expect(await play({'variant': 'warning'}), [
          'impact:medium',
          'impact:medium',
        ]);
        expect(await play({'variant': 'error'}), [
          'impact:strong',
          'impact:strong',
          'impact:strong',
        ]);
        expect(await play({'variant': 'light'}), ['impact:light']);
      });

      test('리듬 간격 — success 70ms, warning·error 130ms', () {
        fakeAsync((async) {
          for (final (variant, gap) in [
            ('success', 70),
            ('warning', 130),
            ('error', 130),
          ]) {
            player.calls.clear();
            driver.run(_ctx({'variant': variant}));
            async.flushMicrotasks();
            expect(player.calls, hasLength(1), reason: variant);
            async.elapse(Duration(milliseconds: gap - 1));
            expect(player.calls, hasLength(1), reason: variant);
            async.elapse(const Duration(milliseconds: 1));
            expect(player.calls, hasLength(2), reason: variant);
            async.elapse(const Duration(seconds: 1));
          }
        });
      });

      test('intensity 이름이 리듬의 base를 덮는다 — heavy는 strong', () async {
        expect(await play({'variant': 'warning', 'intensity': 'heavy'}), [
          'impact:strong',
          'impact:strong',
        ]);
      });
    });

    group('run', () {
      test('variant 없으면 아무것도 안 친다 (0.4.0부터, 예전엔 light 단발)', () async {
        await driver.run(_ctx(const {}));
        expect(player.calls, isEmpty);
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

      test('미지 variant는 아무것도 안 친다 (0.4.0부터, 예전엔 light 폴백)', () async {
        await driver.run(_ctx(const {'variant': 'nonsense'}));
        expect(player.calls, isEmpty);
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
