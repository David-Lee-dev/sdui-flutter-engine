import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/move.dart';

void main() {
  group('MoveMotion', () {
    group('plan', () {
      test('기본값: one-shot, 300ms, easeOut(MotionPlan.from 봉투)', () {
        final plan = const MoveMotion().plan(const MotionParams({}));
        expect(plan.duration, const Duration(milliseconds: 300));
        expect(plan.curve, Curves.easeOut);
        expect(plan.repeat, isFalse);
      });

      test('repeat/reverse를 디코드(float 등 루프 컴포짓용)', () {
        final plan = const MoveMotion().plan(
          const MotionParams({'repeat': true, 'reverse': true}),
        );
        expect(plan.repeat, isTrue);
        expect(plan.reverse, isTrue);
      });
    });

    group('frame', () {
      testWidgets('offset = lerp(begin, end, t)', (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        );
        const m = MoveMotion();
        // vector_math는 transitive 의존이라 직접 import하지 않고, 이동 성분(열-major 4열 —
        // storage[12]=x, storage[13]=y)을 storage 배열에서 바로 읽는다.
        Offset off(double t, [Map<String, Object?> p = const {}]) {
          final storage =
              (m.frame(ctx, t, const SizedBox(), MotionParams(p)) as Transform)
                  .transform
                  .storage;
          return Offset(storage[12], storage[13]);
        }

        expect(
          off(0, {
            'begin': [0, 24],
            'end': [0, 0],
          }),
          const Offset(0, 24),
        );
        expect(
          off(1, {
            'begin': [0, 24],
            'end': [0, 0],
          }),
          const Offset(0, 0),
        );
        expect(
          off(0.5, {
            'begin': [0, 24],
            'end': [0, 0],
          }),
          const Offset(0, 12),
        );
        // begin/end 없으면 기본 Offset.zero → 항상 원점.
        expect(off(0.5), Offset.zero);
      });
    });
  });
}
