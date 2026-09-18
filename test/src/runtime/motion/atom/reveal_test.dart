import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/reveal.dart';

void main() {
  group('RevealMotion', () {
    group('frame', () {
      testWidgets('up은 아래 기준으로 높이를 0→0.5→1만큼 드러낸다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );

        Align align(double t, [String? direction]) {
          final params = direction == null
              ? const MotionParams({})
              : MotionParams({'direction': direction});
          final clip =
              const RevealMotion().frame(context, t, const SizedBox(), params)
                  as ClipRect;
          return clip.child as Align;
        }

        expect(align(0).heightFactor, 0);
        expect(align(0.5).heightFactor, 0.5);
        expect(align(1).heightFactor, 1);
        expect(align(0).widthFactor, isNull);
        expect(align(0).alignment, Alignment.bottomCenter);
        expect(align(-1).heightFactor, 0); // 잘못된 진행률도 안전하게 클램프.
      });

      testWidgets('방향별 factor와 기준 정렬, 미지 방향 폴백', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );

        Align align(String direction) =>
            (const RevealMotion().frame(
                          context,
                          0.5,
                          const SizedBox(),
                          MotionParams({'direction': direction}),
                        )
                        as ClipRect)
                    .child
                as Align;

        expect(align('down').alignment, Alignment.topCenter);
        expect(align('down').heightFactor, 0.5);
        expect(align('left').alignment, Alignment.centerRight);
        expect(align('left').widthFactor, 0.5);
        expect(align('right').alignment, Alignment.centerLeft);
        expect(align('right').widthFactor, 0.5);
        expect(align('bogus').alignment, Alignment.bottomCenter);
        expect(align('bogus').heightFactor, 0.5);
      });
    });
  });
}
