import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/engine_curve.dart';
import 'package:sdui_engine/src/ir/model/engine_spring.dart';
import 'package:sdui_engine/src/runtime/util/engine_curve.dart';
import 'package:sdui_engine/src/runtime/util/engine_spring.dart';

void main() {
  test('지원하는 9개 이름을 같은 Curve로 해석한다', () {
    const expected = <String, Curve>{
      'linear': Curves.linear,
      'ease': Curves.ease,
      'ease_in': Curves.easeIn,
      'ease_out': Curves.easeOut,
      'ease_in_out': Curves.easeInOut,
      'fast_out_slow_in': Curves.fastOutSlowIn,
      'bounce_out': Curves.bounceOut,
      'elastic_out': Curves.elasticOut,
      'decelerate': Curves.decelerate,
    };

    for (final entry in expected.entries) {
      expect(EngineCurve.resolve(entry.key), entry.value, reason: entry.key);
    }
  });

  test('미지 이름과 null은 호출부 fallback을 따른다', () {
    expect(EngineCurve.resolve('unknown'), Curves.linear);
    expect(EngineCurve.resolve(null), Curves.linear);
    expect(
      EngineCurve.resolve('unknown', fallback: Curves.bounceIn),
      Curves.bounceIn,
    );
    expect(EngineCurve.resolve(null, fallback: Curves.easeIn), Curves.easeIn);
  });

  group('0.9.0 큐빅 베지어 목록', () {
    test('[x1,y1,x2,y2]는 같은 Cubic으로 해석한다', () {
      final curve = EngineCurve.resolve([0.2, 0, 0, 1]);
      const expected = Cubic(0.2, 0, 0, 1);
      for (final t in [0.1, 0.3, 0.5, 0.7, 0.9]) {
        expect(curve.transform(t), closeTo(expected.transform(t), 1e-9));
      }
    });

    test('x는 0..1로 자른다', () {
      final curve = EngineCurve.resolve([-1, 0.5, 3, 0.5]) as Cubic;
      expect([curve.a, curve.b, curve.c, curve.d], [0, 0.5, 1, 0.5]);
    });

    test('길이·타입이 틀리거나 비유한수, |y| > 10이면 fallback', () {
      for (final bad in <Object?>[
        <Object?>[],
        [0.2, 0, 0],
        [0.2, 0, 0, 1, 1],
        [0.2, 'x', 0, 1],
        [0.2, null, 0, 1],
        [double.nan, 0, 0, 1],
        [0.2, double.infinity, 0, 1],
        [0.2, 11, 0, 1],
        [0.2, 0, 0, -10.5],
        <String, Object?>{'a': 1},
      ]) {
        expect(
          EngineCurve.resolve(bad, fallback: Curves.bounceIn),
          Curves.bounceIn,
          reason: '$bad',
        );
      }
    });
  });

  group('0.24.0 구간 곡선 목록', () {
    final hop = <Object?>[
      {'until': 0.35, 'to': 1, 'curve': 'ease_out'},
      {'until': 1, 'to': 0, 'curve': 'bounce_out'},
    ];

    test('구간마다 이전 to에서 자기 to까지 자기 곡선을 따른다', () {
      final curve = EngineCurve.resolve(hop, fallback: Curves.bounceIn);
      expect(curve.transform(0), 0);
      expect(curve.transform(0.35), closeTo(1, 1e-9));
      expect(curve.transform(1), 0);
      for (final s in [0.1, 0.4, 0.7]) {
        expect(
          curve.transform(0.35 * s),
          closeTo(Curves.easeOut.transform(s), 1e-9),
          reason: 'rise @ $s',
        );
        expect(
          curve.transform(0.35 + 0.65 * s),
          closeTo(1 - Curves.bounceOut.transform(s), 1e-9),
          reason: 'fall @ $s',
        );
      }
    });

    test('t = 1은 마지막 to이다(1이 아니어도)', () {
      final curve = EngineCurve.resolve([
        {'until': 0.5, 'to': 1},
        {'until': 1, 'to': 0.5},
      ]);
      expect(curve.transform(1), 0.5);
      expect(curve.transform(0.75), closeTo(0.75, 1e-9));
    });

    test('curve를 빼면 linear이다', () {
      final curve = EngineCurve.resolve([
        {'until': 1, 'to': 2},
      ]);
      for (final t in [0.25, 0.5, 0.8]) {
        expect(curve.transform(t), closeTo(2 * t, 1e-9));
      }
    });

    test('잘못된 목록은 fallback이다', () {
      for (final bad in <Object?>[
        [
          {'until': 1, 'to': 0},
          'x',
        ],
        ['x'],
        [
          {'to': 1},
        ],
        [
          {'until': '1', 'to': 1},
        ],
        [
          {'until': 0.5, 'to': 1},
          {'until': 0.5, 'to': 0},
          {'until': 1, 'to': 0},
        ],
        [
          {'until': 0.6, 'to': 1},
          {'until': 0.4, 'to': 0},
        ],
        [
          {'until': 0, 'to': 1},
          {'until': 1, 'to': 0},
        ],
        [
          {'until': 0.5, 'to': 1},
        ],
        [
          {'until': 1.5, 'to': 1},
        ],
        [
          {'until': double.nan, 'to': 1},
        ],
        [
          {'until': 1},
        ],
        [
          {'until': 1, 'to': 'a'},
        ],
        [
          {'until': 1, 'to': double.infinity},
        ],
        [
          {'until': 1, 'to': 10.5},
        ],
        [
          {'until': 1, 'to': -11},
        ],
        [
          {'until': 1, 'to': 1, 'curve': 'nope'},
        ],
        [
          {'until': 1, 'to': 1, 'curve': 3},
        ],
        [
          {
            'until': 1,
            'to': 1,
            'curve': [0.2, 0, 0],
          },
        ],
      ]) {
        expect(
          EngineCurve.resolve(bad, fallback: Curves.bounceIn),
          Curves.bounceIn,
          reason: '$bad',
        );
      }
    });

    test('구간 안에 구간 목록을 넣으면 fallback이다', () {
      expect(
        EngineCurve.resolve([
          {'until': 1, 'to': 1, 'curve': hop},
        ], fallback: Curves.bounceIn),
        Curves.bounceIn,
      );
    });

    test('안쪽 곡선으로 베지어·스프링 이름을 쓸 수 있다', () {
      final curve = EngineCurve.resolve([
        {
          'until': 0.5,
          'to': 1,
          'curve': [0.2, 0, 0, 1],
        },
        {'until': 1, 'to': 1, 'curve': 'spatial_fast'},
      ]);
      expect(
        curve.transform(0.25),
        closeTo(const Cubic(0.2, 0, 0, 1).transform(0.5), 1e-9),
      );
      expect(curve.transform(1), 1);
    });

    test('구간 목록은 스프링이 아니다(정착 시간 null)', () {
      expect(EngineCurve.settleDuration(hop), isNull);
    });
  });

  test('Material 3 이름은 M3 easing 곡선으로 해석한다', () {
    const expected = <String, Curve>{
      'emphasized': Curves.easeInOutCubicEmphasized,
      'emphasized_decelerate': Cubic(0.05, 0.7, 0.1, 1),
      'emphasized_accelerate': Cubic(0.3, 0, 0.8, 0.15),
      'standard': Cubic(0.2, 0, 0, 1),
      'standard_decelerate': Cubic(0, 0, 0, 1),
      'standard_accelerate': Cubic(0.3, 0, 1, 1),
    };
    expect(expected.keys.toSet(), EngineCurveNames.material3);
    for (final entry in expected.entries) {
      final curve = EngineCurve.resolve(entry.key);
      for (final t in [0.1, 0.25, 0.5, 0.75, 0.9]) {
        expect(
          curve.transform(t),
          closeTo(entry.value.transform(t), 1e-9),
          reason: '${entry.key} @ $t',
        );
      }
    }
  });

  group('스프링 곡선 이름', () {
    test('이름 목록은 스프링 프리셋과 같다', () {
      expect(EngineCurveNames.spring, EngineSpringNames.presets.keys.toSet());
    });

    for (final name in EngineCurveNames.spring) {
      test('$name: 0→1 스프링을 정착 시간에 맞춰 0..1로 정규화한다', () {
        final spec = EngineSpringNames.presets[name]!;
        final settle = EngineCurve.settleDuration(name)!;
        final seconds = settle.inMicroseconds / 1e6;
        final sim = SpringSimulation(
          EngineSpring.describe(spec),
          0,
          1,
          0,
          tolerance: const Tolerance(distance: 1e-3, velocity: 1e-2),
        );
        expect(seconds, greaterThan(0));
        expect(seconds, lessThanOrEqualTo(5));
        expect(sim.isDone(seconds), isTrue);
        expect(sim.isDone(seconds - 0.002), isFalse);

        final curve = EngineCurve.resolve(name);
        expect(curve.transform(0), 0);
        expect(curve.transform(1), 1);
        for (final t in [0.05, 0.2, 0.5, 0.8, 0.95]) {
          expect(curve.transform(t), closeTo(sim.x(t * seconds), 1e-9));
        }
      });
    }

    test('스프링이 아닌 곡선의 정착 시간은 null', () {
      for (final v in <Object?>[
        'ease_out',
        'emphasized',
        'bogus',
        null,
        3,
        [0.2, 0, 0, 1],
      ]) {
        expect(EngineCurve.settleDuration(v), isNull, reason: '$v');
      }
    });
  });
}
