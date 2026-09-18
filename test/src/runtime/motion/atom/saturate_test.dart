import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/saturate.dart';

void main() {
  group('SaturateMotion', () {
    group('frame', () {
      testWidgets('t=0 회색조와 t=1 원본 행렬이 서로 다르고 안전하게 생성된다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );

        ColorFilter filter(double t) =>
            (const SaturateMotion().frame(
                      context,
                      t,
                      const SizedBox(),
                      const MotionParams({}),
                    )
                    as ColorFiltered)
                .colorFilter;

        expect(filter(0), isNot(equals(filter(1))));
        expect(
          filter(1),
          const ColorFilter.matrix([
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
        );
      });
    });
  });
}
