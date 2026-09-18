import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/blur.dart';

void main() {
  group('BlurMotion', () {
    group('frame', () {
      testWidgets('sigma가 0.01 미만이면 원본 child를 그대로 반환한다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );
        const child = SizedBox(key: ValueKey('child'));

        final result = const BlurMotion().frame(
          context,
          0.5,
          child,
          const MotionParams({'begin': 0.01, 'end': 0}),
        );
        expect(identical(result, child), isTrue);
      });

      testWidgets('기본 8→0에서 t=0은 필터, t=1은 원본 child다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );
        const child = SizedBox(key: ValueKey('child'));
        const motion = BlurMotion();

        expect(
          motion.frame(context, 0, child, const MotionParams({})),
          isA<ImageFiltered>(),
        );
        expect(
          identical(
            motion.frame(context, 1, child, const MotionParams({})),
            child,
          ),
          isTrue,
        );
      });
    });
  });
}
