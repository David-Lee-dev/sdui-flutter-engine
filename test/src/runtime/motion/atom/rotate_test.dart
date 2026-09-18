import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/rotate.dart';

void main() {
  group('RotateMotion', () {
    group('plan', () {
      test('기본값: one-shot, 300ms, easeOut(MotionPlan.from 봉투)', () {
        final plan = const RotateMotion().plan(const MotionParams({}));
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
      });
    });

    group('frame', () {
      testWidgets("axis 기본/'z': Transform.rotate(angle)", (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        final widget = m.frame(
          ctx,
          1,
          const SizedBox(),
          const MotionParams({'begin': 0.0, 'end': math.pi / 2}),
        );
        expect(widget, isA<Transform>());
        final angle = math.atan2(
          (widget as Transform).transform.entry(1, 0),
          widget.transform.entry(0, 0),
        );
        expect(angle, closeTo(math.pi / 2, 1e-9));
      });

      testWidgets("axis:'x'/'y'는 perspective Matrix4로 감싼다", (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        for (final axis in ['x', 'y']) {
          final widget = m.frame(
            ctx,
            1,
            const SizedBox(),
            MotionParams({'axis': axis, 'begin': 0.0, 'end': 1.0}),
          );
          expect(widget, isA<Transform>());
          expect((widget as Transform).alignment, Alignment.center);
          // z축 회전과 달리 perspective 성분(3,2)이 회전과 섞여 non-zero로 남는다(정확히 0.001은
          // 아니다 — rotateX/Y가 그 성분에도 회전을 곱해 cos(angle) 배가 된다).
          expect(widget.transform.entry(3, 2), isNot(0.0));
        }
      });

      testWidgets("align: 회전 pivot을 옮긴다 — z축", (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        final widget = m.frame(
          ctx,
          1,
          const SizedBox(),
          const MotionParams({'begin': 0.0, 'end': 1.0, 'align': 'top_center'}),
        );
        expect((widget as Transform).alignment, Alignment.topCenter);
      });

      testWidgets("align: 회전 pivot을 옮긴다 — x/y축", (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        final widget = m.frame(
          ctx,
          1,
          const SizedBox(),
          const MotionParams({
            'axis': 'y',
            'begin': 0.0,
            'end': 1.0,
            'align': 'bottom_left',
          }),
        );
        expect((widget as Transform).alignment, Alignment.bottomLeft);
      });

      testWidgets('align 생략/오타는 center', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        for (final params in [
          const MotionParams({'begin': 0.0, 'end': 1.0}),
          const MotionParams({'begin': 0.0, 'end': 1.0, 'align': 'nope'}),
        ]) {
          final widget = m.frame(ctx, 1, const SizedBox(), params);
          expect((widget as Transform).alignment, Alignment.center);
        }
      });

      testWidgets('begin/end 기본값 0 → 무회전', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = RotateMotion();
        final widget = m.frame(
          ctx,
          0.5,
          const SizedBox(),
          const MotionParams({}),
        );
        expect(widget, isA<Transform>());
        expect((widget as Transform).transform, Matrix4.identity());
      });
    });
  });
}
