import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/shimmer.dart';

void main() {
  group('MotionParams (관대 디코더)', () {
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
  });
}
