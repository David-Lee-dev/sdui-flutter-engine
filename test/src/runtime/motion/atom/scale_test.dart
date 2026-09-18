import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/scale.dart';

void main() {
  group('ScaleMotion', () {
    group('plan', () {
      test('기본값: one-shot, 300ms, easeOut(MotionPlan.from 봉투)', () {
        final plan = const ScaleMotion().plan(const MotionParams({}));
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
        expect(plan.repeat, isFalse);
      });
    });

    group('frame', () {
      testWidgets('scale = begin + (end-begin)*t, 기본값 1→1(고정)', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = ScaleMotion();
        // z축은 스케일하지 않는(2D 위젯 트랜스폼) Transform.scale의 관례라 x축 성분(entry 0,0)으로
        // 본다 — getMaxScaleOnAxis()는 항상 고정된 z=1.0을 주워 검증에 못 쓴다.
        double sc(double t, [Map<String, Object?> p = const {}]) =>
            (m.frame(ctx, t, const SizedBox(), MotionParams(p)) as Transform)
                .transform
                .entry(0, 0);

        expect(sc(0.5), 1.0); // 기본 begin=end=1 → 항상 1
        expect(sc(0, {'begin': 0.8, 'end': 1.0}), closeTo(0.8, 1e-9));
        expect(sc(1, {'begin': 0.8, 'end': 1.0}), closeTo(1.0, 1e-9));
        expect(sc(0.5, {'begin': 0.8, 'end': 1.0}), closeTo(0.9, 1e-9));
      });

      testWidgets('중심 정렬(alignment: center)로 스케일한다', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = ScaleMotion();
        final widget = m.frame(
          ctx,
          0.5,
          const SizedBox(),
          const MotionParams({}),
        );
        expect((widget as Transform).alignment, Alignment.center);
      });
    });
  });
}
