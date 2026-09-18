import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';

/// 테스트용 모션 — 애니값 t를 Opacity로 노출해 컨트롤러 진행을 관측 가능하게 한다.
class _ProbeMotion extends Motion {
  const _ProbeMotion({
    this.repeat = false,
    this.reverse = false,
    this.delay = Duration.zero,
  });

  final bool repeat;
  final bool reverse;
  final Duration delay;

  @override
  String get type => 'probe';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan(
    duration: const Duration(milliseconds: 100),
    repeat: repeat,
    reverse: reverse,
    delay: delay,
    trigger: params.raw('trigger'),
  );

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) =>
      Opacity(opacity: t, child: child);
}

double _opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;

Widget _host(Motion m, [Map<String, Object?> params = const {}]) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: MotionWrapper(
        motion: m,
        params: MotionParams(params),
        child: const SizedBox(width: 10, height: 10),
      ),
    );

void main() {
  group('MotionWrapper', () {
    testWidgets('one-shot: t가 0→1로 전진하고 끝에 머문다', (tester) async {
      await tester.pumpWidget(_host(const _ProbeMotion()));
      expect(_opacity(tester), 0.0);
      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacity(tester), greaterThan(0.0));
      expect(_opacity(tester), lessThan(1.0));
      await tester.pump(const Duration(milliseconds: 60));
      expect(_opacity(tester), 1.0);
      // 더 펌프해도 1.0에 머문다(반복 아님).
      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacity(tester), 1.0);
    });

    testWidgets('delay: 지연 동안은 시작 전(0), 지연 후 전진', (tester) async {
      await tester.pumpWidget(
        _host(const _ProbeMotion(delay: Duration(milliseconds: 100))),
      );
      expect(_opacity(tester), 0.0);
      await tester.pump(const Duration(milliseconds: 50)); // 아직 지연 중
      expect(_opacity(tester), 0.0);
      await tester.pump(
        const Duration(milliseconds: 70),
      ); // 지연(100ms) 넘김 → forward 시작
      await tester.pump(const Duration(milliseconds: 40)); // 애니 tick
      expect(_opacity(tester), greaterThan(0.0));
      await tester.pumpAndSettle();
    });

    testWidgets('repeat: 계속 진행한다(끝에 안 멈춤)', (tester) async {
      await tester.pumpWidget(
        _host(const _ProbeMotion(repeat: true, reverse: true)),
      );
      await tester.pump(const Duration(milliseconds: 100)); // 한 사이클 끝
      // 왕복이라 되돌아오는 중 — 계속 애니 중.
      final a = _opacity(tester);
      await tester.pump(const Duration(milliseconds: 30));
      expect(_opacity(tester), isNot(a));
      // 정리를 위해 위젯 제거(무한 애니라 pumpAndSettle 금지).
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('trigger 변경 → didUpdateWidget에서 재생(0부터)', (tester) async {
      const m = _ProbeMotion();
      await tester.pumpWidget(_host(m, const {'trigger': 1}));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_opacity(tester), 1.0); // 첫 재생 완료
      // 트리거 바꿔 재-펌프 → 같은 위치·타입이라 State 재사용 → 재생.
      await tester.pumpWidget(_host(m, const {'trigger': 2}));
      await tester.pump(const Duration(milliseconds: 10));
      expect(_opacity(tester), lessThan(1.0)); // 다시 0 근처에서 전진
      await tester.pumpAndSettle();
    });

    testWidgets('dispose: 제거해도 ticker 누수·예외 없음', (tester) async {
      await tester.pumpWidget(_host(const _ProbeMotion()));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpWidget(const SizedBox()); // 언마운트
      await tester.pump(const Duration(milliseconds: 200)); // 늦은 콜백에도 안전
      expect(tester.takeException(), isNull);
    });
  });
}
