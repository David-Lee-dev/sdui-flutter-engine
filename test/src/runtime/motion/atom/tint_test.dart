import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/tint.dart';

void main() {
  group('TintMotion', () {
    group('frame', () {
      testWidgets('t=0은 begin, t=1은 end 색 필터를 만든다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );
        const params = MotionParams({'begin': '#FF112233', 'end': '#80445566'});

        ColorFilter filter(double t) =>
            (const TintMotion().frame(context, t, const SizedBox(), params)
                    as ColorFiltered)
                .colorFilter;

        expect(
          filter(0),
          const ColorFilter.mode(Color(0xFF112233), BlendMode.srcATop),
        );
        expect(
          filter(1),
          const ColorFilter.mode(Color(0x80445566), BlendMode.srcATop),
        );
      });

      testWidgets('아는 blend를 매핑하고 미지 값은 srcATop으로 폴백한다', (tester) async {
        late BuildContext context;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        );

        ColorFilter filter(String blend) =>
            (const TintMotion().frame(
                      context,
                      0,
                      const SizedBox(),
                      MotionParams({'blend': blend}),
                    )
                    as ColorFiltered)
                .colorFilter;

        for (final entry in const {
          'src_atop': BlendMode.srcATop,
          'modulate': BlendMode.modulate,
          'overlay': BlendMode.overlay,
          'color': BlendMode.color,
          'screen': BlendMode.screen,
          'bogus': BlendMode.srcATop,
        }.entries) {
          expect(
            filter(entry.key),
            ColorFilter.mode(const Color(0x66000000), entry.value),
          );
        }
      });
    });
  });
}
