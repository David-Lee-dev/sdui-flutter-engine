import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/fade.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';

void main() {
  group('FadeMotion', () {
    group('plan', () {
      test('기본값: one-shot, 300ms, easeOut', () {
        final plan = const FadeMotion().plan(const MotionParams({}));
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
        expect(plan.repeat, isFalse);
      });

      test('관대 디코드: 잘못된 duration/curve는 기본값', () {
        final plan = const FadeMotion().plan(
          const MotionParams({'duration': 'nope', 'curve': 42}),
        );
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
      });

      test('trigger는 원본을 그대로 싣는다', () {
        expect(
          const FadeMotion().plan(const MotionParams({'trigger': 5})).trigger,
          5,
        );
      });

      test('repeat/reverse를 디코드(blink 등 루프 컴포짓용)', () {
        final plan = const FadeMotion().plan(
          const MotionParams({'repeat': true, 'reverse': true}),
        );
        expect(plan.repeat, isTrue);
        expect(plan.reverse, isTrue);
      });
    });

    group('frame', () {
      testWidgets('opacity = begin + (end-begin)*t, 0..1 클램프', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = FadeMotion();
        double op(double t, [Map<String, Object?> p = const {}]) =>
            (m.frame(ctx, t, const SizedBox(), MotionParams(p)) as Opacity)
                .opacity;

        expect(op(0), 0.0); // 기본 begin=0
        expect(op(1), 1.0); // 기본 end=1
        expect(op(0.5), 0.5);
        expect(op(0.5, {'begin': 1, 'end': 0}), 0.5); // 역방향 페이드
        expect(op(1, {'begin': 0.2, 'end': 0.8}), closeTo(0.8, 1e-9));
        // 범위 밖 값도 클램프(잘못된 begin/end에도 opacity는 유효 범위).
        expect(op(2, {'begin': 0, 'end': 1}), 1.0);
      });
    });

    test('fade는 빌트인으로 등록돼 있다', () {
      expect(MotionFactory.resolve('fade'), isA<FadeMotion>());
    });
  });
}
