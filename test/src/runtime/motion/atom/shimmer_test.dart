import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/shimmer.dart';

void main() {
  group('ShimmerMotion', () {
    group('plan', () {
      test('repeat 기본값은 true이고 명시한 false로 덮어쓴다', () {
        expect(
          const ShimmerMotion().plan(const MotionParams({})).repeat,
          isTrue,
        );
        expect(
          const ShimmerMotion()
              .plan(const MotionParams({'repeat': false}))
              .repeat,
          isFalse,
        );
      });
    });

    group('frame', () {
      testWidgets('자식 픽셀에 srcATop ShaderMask를 적용한다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );

        final frame = const ShimmerMotion().frame(
          context,
          0.5,
          const SizedBox(),
          const MotionParams({}),
        );
        expect(frame, isA<ShaderMask>());
        expect((frame as ShaderMask).blendMode, BlendMode.srcATop);
      });
    });
  });
}
