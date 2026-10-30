import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/shimmer.dart';
import 'package:sdui_engine/src/runtime/util/engine_curve.dart';

void main() {
  group('MotionParams (관대 디코더)', () {
    // 0.7.0: 유한하지만 거대한 값은 변환 사각형을 넘쳐 렌더 단계에서 터지므로 fallback.
    test('±1e6을 넘는 number·offset·duration은 fallback', () {
      const p = MotionParams({
        'big': 1e308,
        'neg': -1000001,
        'edge': 1e6,
        'xy': [1e308, 0],
        'ok': [-1e6, 1e6],
      });
      expect(p.number('big', 7), 7);
      expect(p.number('neg', 7), 7);
      expect(p.number('edge', 7), 1e6);
      expect(p.offset('xy', Offset.zero), Offset.zero);
      expect(p.offset('ok', Offset.zero), const Offset(-1e6, 1e6));
      expect(
        p.duration('big', const Duration(milliseconds: 5)),
        const Duration(milliseconds: 5),
      );
      expect(
        p.duration('edge', Duration.zero),
        const Duration(milliseconds: 1000000),
      );
    });

    group('number', () {
      test('유한 수는 그대로, 아니면 fallback', () {
        expect(const MotionParams({'x': 3}).number('x', 0), 3);
        expect(const MotionParams({'x': 2.5}).number('x', 0), 2.5);
        expect(const MotionParams({'x': 'nope'}).number('x', 9), 9);
        expect(const MotionParams({}).number('x', 9), 9);
        expect(const MotionParams({'x': double.nan}).number('x', 9), 9);
      });
    });

    group('duration', () {
      test('비음수 밀리초 수를 Duration으로', () {
        expect(
          const MotionParams({'d': 300}).duration('d', Duration.zero),
          const Duration(milliseconds: 300),
        );
      });
      test('음수·비수는 fallback', () {
        const fb = Duration(milliseconds: 100);
        expect(const MotionParams({'d': -5}).duration('d', fb), fb);
        expect(const MotionParams({'d': 'x'}).duration('d', fb), fb);
        expect(const MotionParams({}).duration('d', fb), fb);
      });
    });

    group('curve', () {
      test('아는 이름은 매핑, 미지·비문자열은 fallback', () {
        expect(
          const MotionParams({'c': 'elastic_out'}).curve('c', Curves.linear),
          Curves.elasticOut,
        );
        expect(
          const MotionParams({'c': 'bogus'}).curve('c', Curves.linear),
          Curves.linear,
        );
        expect(
          const MotionParams({'c': 42}).curve('c', Curves.ease),
          Curves.ease,
        );
      });

      test('atom의 알려진 커브와 atom별 fallback을 그대로 쓴다', () {
        const atom = ShimmerMotion();

        expect(
          atom.plan(const MotionParams({'curve': 'elastic_out'})).curve,
          Curves.elasticOut,
        );
        expect(
          atom.plan(const MotionParams({'curve': 'unknown'})).curve,
          Curves.linear,
        );
      });
    });

    group('color', () {
      test('유효한 hex는 Color로, 잘못되거나 없으면 fallback', () {
        const fallback = Color(0xFFABCDEF);
        expect(
          const MotionParams({'c': '#112233'}).color('c', fallback),
          const Color(0xFF112233),
        );
        expect(
          const MotionParams({'c': '#80112233'}).color('c', fallback),
          const Color(0x80112233),
        );
        expect(
          const MotionParams({'c': 'nope'}).color('c', fallback),
          fallback,
        );
        expect(const MotionParams({}).color('c', fallback), fallback);
      });
    });

    group('flag / text / raw', () {
      test('flag은 bool만', () {
        expect(
          const MotionParams({'b': true}).flag('b', fallback: false),
          isTrue,
        );
        expect(
          const MotionParams({'b': 'yes'}).flag('b', fallback: false),
          isFalse,
        );
      });
      test('text는 문자열만, 아니면 null', () {
        expect(const MotionParams({'s': 'left'}).text('s'), 'left');
        expect(const MotionParams({'s': 1}).text('s'), isNull);
      });
      test('raw는 원본 그대로(트리거 비교용)', () {
        expect(const MotionParams({'t': 7}).raw('t'), 7);
        expect(const MotionParams({}).raw('t'), isNull);
      });
    });

    group('offset', () {
      test('[dx,dy] 수 리스트를 Offset으로', () {
        expect(
          const MotionParams({
            'p': [4, -8],
          }).offset('p', Offset.zero),
          const Offset(4, -8),
        );
        expect(
          const MotionParams({
            'p': [1, 2.5],
          }).offset('p', Offset.zero),
          const Offset(1, 2.5),
        );
      });
      test('길이·타입·값이 어긋나면 fallback', () {
        const fb = Offset(1, 1);
        expect(
          const MotionParams({
            'p': [1],
          }).offset('p', fb),
          fb,
        );
        expect(
          const MotionParams({
            'p': [1, 2, 3],
          }).offset('p', fb),
          fb,
        );
        expect(
          const MotionParams({
            'p': ['a', 'b'],
          }).offset('p', fb),
          fb,
        );
        expect(
          const MotionParams({
            'p': [double.nan, 0],
          }).offset('p', fb),
          fb,
        );
        expect(const MotionParams({}).offset('p', fb), fb);
      });
    });
  });

  group('MotionPlan', () {
    group('from', () {
      test('빈 params면 기본값 전부', () {
        final plan = MotionPlan.from(const MotionParams({}));
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
        expect(plan.delay, Duration.zero);
        expect(plan.repeat, isFalse);
        expect(plan.reverse, isFalse);
        expect(plan.trigger, isNull);
      });

      test(
        'params가 있으면 봉투(duration/curve/delay/repeat/reverse/trigger)를 전부 디코드',
        () {
          final plan = MotionPlan.from(
            const MotionParams({
              'duration': 700,
              'curve': 'ease_in_out',
              'delay': 50,
              'repeat': true,
              'reverse': true,
              'trigger': 3,
            }),
          );
          expect(plan.duration, const Duration(milliseconds: 700));
          expect(plan.curve, Curves.easeInOut);
          expect(plan.delay, const Duration(milliseconds: 50));
          expect(plan.repeat, isTrue);
          expect(plan.reverse, isTrue);
          expect(plan.trigger, 3);
        },
      );

      test('호출부가 준 duration/curve 기본값을 쓴다(atom별 커스텀 폴백)', () {
        final plan = MotionPlan.from(
          const MotionParams({}),
          duration: const Duration(milliseconds: 600),
          curve: Curves.linear,
        );
        expect(plan.duration, const Duration(milliseconds: 600));
        expect(plan.curve, Curves.linear);
      });
    });

    group('0.9.0', () {
      test('기본 plan은 횟수 제한·반복 사이 쉼이 없다', () {
        final plan = MotionPlan.from(const MotionParams({}));
        expect(plan.repeatCount, isNull);
        expect(plan.repeatDelay, Duration.zero);
      });

      test('스프링 곡선에 duration이 없으면 정착 시간이 길이가 된다', () {
        final plan = MotionPlan.from(
          const MotionParams({'curve': 'spatial_slow'}),
        );
        expect(plan.duration, EngineCurve.settleDuration('spatial_slow'));
        expect(plan.curve, EngineCurve.resolve('spatial_slow'));
      });

      test('명시한 duration이 스프링 정착 시간보다 우선한다', () {
        final plan = MotionPlan.from(
          const MotionParams({'curve': 'spatial_slow', 'duration': 120}),
        );
        expect(plan.duration, const Duration(milliseconds: 120));
      });

      test('곡선 목록은 큐빅 베지어로 해석한다', () {
        final plan = MotionPlan.from(
          const MotionParams({
            'curve': [0.2, 0, 0, 1],
          }),
        );
        expect(plan.curve, isA<Cubic>());
      });

      test('repeat: 정수 1..1000은 그 횟수만큼 반복한다', () {
        for (final n in [1, 3, 1000, 4.0]) {
          final plan = MotionPlan.from(MotionParams({'repeat': n}));
          expect(plan.repeat, isTrue, reason: '$n');
          expect(plan.repeatCount, n.toInt(), reason: '$n');
        }
        final forever = MotionPlan.from(const MotionParams({'repeat': true}));
        expect(forever.repeat, isTrue);
        expect(forever.repeatCount, isNull);
      });

      test('범위 밖·정수가 아닌 repeat은 기본값(반복 없음)', () {
        for (final bad in <Object?>[0, -1, 1001, 2.5, 'x', double.nan, null]) {
          final plan = MotionPlan.from(MotionParams({'repeat': bad}));
          expect(plan.repeat, isFalse, reason: '$bad');
          expect(plan.repeatCount, isNull, reason: '$bad');
        }
      });

      test('repeat_delay는 반복 사이 쉼(ms), 잘못되면 0', () {
        expect(
          MotionPlan.from(
            const MotionParams({'repeat_delay': 250}),
          ).repeatDelay,
          const Duration(milliseconds: 250),
        );
        for (final bad in <Object?>[-1, 'x', 1e7, double.infinity]) {
          expect(
            MotionPlan.from(MotionParams({'repeat_delay': bad})).repeatDelay,
            Duration.zero,
            reason: '$bad',
          );
        }
      });

      test('shimmer도 repeat 횟수·repeat_delay·스프링 곡선 길이를 따른다', () {
        const atom = ShimmerMotion();
        final plan = atom.plan(
          const MotionParams({'repeat': 2, 'repeat_delay': 40}),
        );
        expect(plan.repeat, isTrue);
        expect(plan.repeatCount, 2);
        expect(plan.repeatDelay, const Duration(milliseconds: 40));
        expect(atom.plan(const MotionParams({})).repeat, isTrue);
        expect(
          atom.plan(const MotionParams({'curve': 'spatial_fast'})).duration,
          EngineCurve.settleDuration('spatial_fast'),
        );
      });
    });
  });
}
