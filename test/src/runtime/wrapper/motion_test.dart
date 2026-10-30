import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/atom/fade.dart';
import 'package:sdui_engine/src/runtime/motion/atom/move.dart';
import 'package:sdui_engine/src/runtime/motion/atom/reveal.dart';
import 'package:sdui_engine/src/runtime/motion/atom/shimmer.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/swipe_pane_widget.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller_scope.dart';
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
    startAtMount: params.text('start') == 'mount',
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

Widget _fade(
  Map<String, Object?> params, {
  bool reduce = false,
  Motion motion = const FadeMotion(),
}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduce),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MotionWrapper(
      motion: motion,
      params: MotionParams({'curve': 'linear', 'duration': 100, ...params}),
      child: const SizedBox(width: 10, height: 10),
    ),
  ),
);

/// Advances [ms] in 10 ms frames, as a device would.
///
/// A controller reports a leg done on the first frame after it is due
/// (`isDone` is strict), so a following leg may start one frame late.
Future<void> _advance(WidgetTester tester, int ms) async {
  for (var left = ms; left > 0; left -= 10) {
    await tester.pump(Duration(milliseconds: left < 10 ? left : 10));
  }
}

/// One 10 ms frame of a 100 ms linear leg, the tolerance of a leg start.
const _frame = 0.11;

Finder get _boundaryInside => find.descendant(
  of: find.byType(MotionWrapper),
  matching: find.byType(RepaintBoundary),
);

void main() {
  group('MotionWrapper 0.9.0 repeat 횟수·repeat_delay', () {
    testWidgets('repeat: 2는 두 번 돌고 끝 상태에 멈춘다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': 2}));
      await _advance(tester, 50);
      expect(_opacity(tester), closeTo(0.5, _frame));
      await _advance(tester, 100);
      expect(_opacity(tester), closeTo(0.5, _frame));
      await _advance(tester, 100);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 300);
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('repeat: 2 + reverse는 갔다가 돌아와 시작 상태에서 멈춘다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': 2, 'reverse': true}));
      await _advance(tester, 100);
      await _advance(tester, 25);
      expect(_opacity(tester), closeTo(0.75, _frame));
      await _advance(tester, 100);
      expect(_opacity(tester), 0.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('repeat_delay는 다리 사이에 끝 상태로 쉰 뒤 다음 다리를 탄다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': true, 'repeat_delay': 50}));
      await _advance(tester, 100);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 40);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 10);
      await _advance(tester, 30);
      expect(_opacity(tester), closeTo(0.3, _frame));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('repeat_delay + reverse는 양 끝에서 쉬며 왕복한다', (tester) async {
      await tester.pumpWidget(
        _fade({'repeat': 3, 'reverse': true, 'repeat_delay': 20}),
      );
      await _advance(tester, 110);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 20);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 60);
      expect(_opacity(tester), closeTo(0.4, _frame));
      await _advance(tester, 60);
      expect(_opacity(tester), 0.0);
      await _advance(tester, 120);
      expect(_opacity(tester), 1.0);
      await _advance(tester, 200);
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('trigger 변경은 횟수를 처음부터 다시 센다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': 2, 'trigger': 1}));
      await _advance(tester, 250);
      expect(_opacity(tester), 1.0);
      await tester.pumpWidget(_fade({'repeat': 2, 'trigger': 2}));
      await _advance(tester, 150);
      expect(_opacity(tester), closeTo(0.5, _frame));
      await _advance(tester, 100);
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('쉬는 중 dispose해도 남는 timer·예외가 없다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': true, 'repeat_delay': 500}));
      await _advance(tester, 150);
      await tester.pumpWidget(const SizedBox());
      await _advance(tester, 1000);
      expect(tester.takeException(), isNull);
    });
  });

  group('MotionWrapper 0.9.0 reduced motion', () {
    testWidgets('one-shot은 첫 프레임부터 끝 상태이고 애니메이션이 없다', (tester) async {
      await tester.pumpWidget(_fade({'delay': 300}, reduce: true));
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(milliseconds: 400));
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('반복 모션도 끝 상태에 멈춘다', (tester) async {
      await tester.pumpWidget(
        _fade({'repeat': true, 'reverse': true}, reduce: true),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('shimmer는 정지한 끝 상태로 그린다', (tester) async {
      await tester.pumpWidget(
        _fade(const {}, reduce: true, motion: const ShimmerMotion()),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('trigger가 바뀌어도 끝 상태에 머문다', (tester) async {
      await tester.pumpWidget(_fade({'trigger': 1}, reduce: true));
      await tester.pumpWidget(_fade({'trigger': 2}, reduce: true));
      await tester.pump(const Duration(milliseconds: 10));
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('도중에 reduced motion이 켜지면 끝 상태로 건너뛴다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': true}));
      await tester.pump(const Duration(milliseconds: 30));
      expect(_opacity(tester), lessThan(1.0));
      await tester.pumpWidget(_fade({'repeat': true}, reduce: true));
      expect(_opacity(tester), 1.0);
      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacity(tester), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('MotionWrapper 0.9.0 RepaintBoundary', () {
    testWidgets('반복 모션은 자식을 RepaintBoundary로 감싼다', (tester) async {
      await tester.pumpWidget(_fade({'repeat': true}));
      expect(_boundaryInside, findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('one-shot 모션의 트리는 그대로다(RepaintBoundary 없음)', (tester) async {
      await tester.pumpWidget(_fade(const {}));
      expect(_boundaryInside, findsNothing);
      final opacity = find.byType(Opacity);
      expect(
        find.descendant(of: opacity, matching: find.byType(SizedBox)),
        findsOneWidget,
      );
      expect(
        tester
            .element(find.byType(SizedBox))
            .findAncestorWidgetOfExactType<Opacity>(),
        isNotNull,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('sliver 노드의 반복 모션은 RepaintBoundary를 넣지 않는다', (tester) async {
      MotionFactory.register(const _SliverSafeMotion());
      addTearDown(MotionFactory.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'custom_scroll_view',
                '_children': [
                  {
                    '_type': 'sliver_to_box_adapter',
                    '_motion': {'type': 'sliver_safe'},
                    '_child': {'_type': 'text', 'value': 'hi'},
                  },
                ],
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(find.text('hi'), findsOneWidget);
      expect(_boundaryInside, findsNothing);
      // The start gate measured the visible sliver and let the layer run.
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

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

  group('MotionWrapper — scroll-aware start gate', () {
    // 아직 lazy-build 되지 않은(화면 밖) 위젯은 "시작 전"과 동치이므로 0.0으로 본다.
    double opacityOf(WidgetTester tester, Key key) {
      final finder = find.descendant(
        of: find.byKey(key),
        matching: find.byType(Opacity),
      );
      if (finder.evaluate().isEmpty) return 0.0;
      return tester.widget<Opacity>(finder).opacity;
    }

    testWidgets('B: PageView 2쪽 모션은 드래그 중엔 대기, 정착 후 delay부터 시작', (
      tester,
    ) async {
      const probeKey = ValueKey('probe');
      final pageController = PageController();
      addTearDown(pageController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 400,
            child: PageView(
              controller: pageController,
              children: [
                const SizedBox(key: ValueKey('page0')),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(
                      delay: Duration(milliseconds: 100),
                    ),
                    params: const MotionParams({}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 페이지2로 애니메이션 이동 중 — 아직 settle 전.
      unawaited(
        pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        ),
      );
      await tester.pump();
      expect(opacityOf(tester, probeKey), 0.0);
      // 이동 도중 추가로 펌프해도 settle 전이라 시작하지 않는다.
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester, probeKey), 0.0);

      // 정착(애니메이션 완료)까지 펌프.
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacityOf(tester, probeKey), 0.0); // settle 직후, delay 아직

      await tester.pump(const Duration(milliseconds: 110)); // delay(100ms) 넘김
      await tester.pump(const Duration(milliseconds: 40)); // 애니 진행 틱(기준점)
      await tester.pump(const Duration(milliseconds: 40)); // 애니 진행 틱(실제 전진)
      expect(opacityOf(tester, probeKey), greaterThan(0.0));
    });

    testWidgets('B2: start=mount이면 스크롤이 계속 움직이는 중에도 바로 시작한다', (tester) async {
      const probeKey = ValueKey('probe-mount-scrolling');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(key: ValueKey('spacer-mount-scrolling'), height: 200),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(),
                    params: const MotionParams({'start': 'mount'}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      unawaited(
        scrollController.animateTo(
          50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        ),
      );
      await tester.pump();
      // 스크롤이 아직 멈추지 않았는데도(isScrollingNotifier == true) gate 없이 진행된다.
      expect(scrollController.position.isScrollingNotifier.value, isTrue);
      await tester.pump(const Duration(milliseconds: 50));
      expect(opacityOf(tester, probeKey), greaterThan(0.0));
      await tester.pumpWidget(const SizedBox()); // 정리
    });

    testWidgets('C: swipe_layout 두 pane — follower(jumpTo)도 settle까지 대기', (
      tester,
    ) async {
      const probeKey = ValueKey('probe-follower');
      final controller = SwipeController(length: 2);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: EngineMetrics(
            scale: 1.0,
            child: Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: SwipeControllerScope(
                  controller: controller,
                  child: Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) =>
                              SwipePaneWidget.build(context, const {}, const [
                                SizedBox(key: ValueKey('driver-0')),
                                SizedBox(key: ValueKey('driver-1')),
                              ]),
                        ),
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) =>
                              SwipePaneWidget.build(context, const {}, [
                                const SizedBox(key: ValueKey('follower-0')),
                                KeyedSubtree(
                                  key: probeKey,
                                  child: MotionWrapper(
                                    motion: const _ProbeMotion(
                                      delay: Duration(milliseconds: 100),
                                    ),
                                    params: const MotionParams({}),
                                    child: const SizedBox(
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      unawaited(controller.goTo(1));
      await tester.pump();
      expect(opacityOf(tester, probeKey), 0.0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester, probeKey), 0.0); // moveTo(300ms) 아직 진행 중

      // 정착 + delay(100ms)까지 여유 있게.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(milliseconds: 40)); // 기준점 틱
      await tester.pump(const Duration(milliseconds: 40)); // 실제 전진 틱
      expect(opacityOf(tester, probeKey), greaterThan(0.0));
    });

    testWidgets('D: ListView 화면 밖 항목 — 보이고 스크롤이 멈출 때까지 대기', (tester) async {
      const probeKey = ValueKey('probe-list');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(key: ValueKey('spacer'), height: 1000),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(),
                    params: const MotionParams({}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(opacityOf(tester, probeKey), 0.0); // 화면 밖 — 시작 안 함

      scrollController.jumpTo(1000);
      await tester.pump();
      expect(opacityOf(tester, probeKey), 0.0); // 보이지만 아직 틱 중일 수 있음

      await tester.pumpAndSettle();
      expect(opacityOf(tester, probeKey), greaterThan(0.0)); // 보이고 멈춤 → 시작
    });

    testWidgets('D2: start=mount 이면 화면 밖에서도 delay부터 바로 시작한다', (tester) async {
      const probeKey = ValueKey('probe-mount');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(key: ValueKey('spacer-mount'), height: 400),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(
                      delay: Duration(milliseconds: 300),
                    ),
                    params: const MotionParams({'start': 'mount'}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      // 스크롤 없이도 delay(300ms)가 지나면 진행된다.
      await tester.pump(const Duration(milliseconds: 310));
      await tester.pump(const Duration(milliseconds: 40));
      expect(opacityOf(tester, probeKey), greaterThan(0.0));
    });

    testWidgets('D3: start 기본값(visible)은 화면 밖이면 그대로 대기한다', (tester) async {
      const probeKey = ValueKey('probe-default-visible');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(
                  key: ValueKey('spacer-default-visible'),
                  height: 1000,
                ),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(
                      delay: Duration(milliseconds: 300),
                    ),
                    params: const MotionParams({'start': 'visible'}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 310));
      expect(opacityOf(tester, probeKey), 0.0); // 아직 화면 밖 — 대기
    });

    testWidgets('D4: start에 잘못된 값이면 visible로 대체되어 화면 밖이면 대기한다', (tester) async {
      const probeKey = ValueKey('probe-invalid-start');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(
                  key: ValueKey('spacer-invalid-start'),
                  height: 1000,
                ),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(
                      delay: Duration(milliseconds: 300),
                    ),
                    params: const MotionParams({'start': 'mnt'}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 310));
      expect(opacityOf(tester, probeKey), 0.0); // 잘못된 값 → visible로 대체, 대기
    });

    testWidgets('E: settle 이후라도 trigger 변경은 즉시 재생', (tester) async {
      const probeKey = ValueKey('probe-trigger');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      Widget host(int trigger) => MaterialApp(
        home: SizedBox(
          width: 400,
          height: 300,
          child: ListView(
            controller: scrollController,
            children: [
              KeyedSubtree(
                key: probeKey,
                child: MotionWrapper(
                  motion: const _ProbeMotion(),
                  params: MotionParams({'trigger': trigger}),
                  child: const SizedBox(width: 10, height: 10),
                ),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      );

      await tester.pumpWidget(host(1));
      await tester.pumpAndSettle();
      expect(opacityOf(tester, probeKey), 1.0); // 첫 재생 완료(화면 안, 정지 상태)

      await tester.pumpWidget(host(2));
      await tester.pump(const Duration(milliseconds: 10));
      expect(opacityOf(tester, probeKey), lessThan(1.0)); // trigger로 즉시 재시작
      await tester.pumpAndSettle();
    });

    testWidgets('F: 시작 후 스크롤로 밖으로 나갔다 돌아와도 재시작하지 않는다', (tester) async {
      const probeKey = ValueKey('probe-norestart');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(),
                    params: const MotionParams({}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(opacityOf(tester, probeKey), 1.0); // 끝까지 재생 완료

      scrollController.jumpTo(900); // 화면 밖으로
      await tester.pumpAndSettle();
      scrollController.jumpTo(0); // 다시 화면 안으로
      await tester.pumpAndSettle();

      expect(opacityOf(tester, probeKey), 1.0); // 재시작 없이 그대로 완료 상태
    });

    testWidgets('G: repeat 모션도 같은 gate를 따른다', (tester) async {
      const probeKey = ValueKey('probe-repeat');
      final pageController = PageController();
      addTearDown(pageController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 400,
            child: PageView(
              controller: pageController,
              children: [
                const SizedBox(key: ValueKey('rpage0')),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(repeat: true, reverse: true),
                    params: const MotionParams({}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      unawaited(
        pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        ),
      );
      await tester.pump();
      expect(opacityOf(tester, probeKey), 0.0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester, probeKey), 0.0); // 정착 전에는 repeat도 대기

      await tester.pump(const Duration(milliseconds: 150)); // 정착
      await tester.pump(const Duration(milliseconds: 40)); // 기준점 틱
      await tester.pump(const Duration(milliseconds: 40)); // 실제 전진 틱
      expect(
        opacityOf(tester, probeKey),
        greaterThan(0.0),
      ); // settle 후 repeat 진행

      await tester.pumpWidget(const SizedBox()); // 무한 애니라 정리
    });

    testWidgets('G2: start=mount인 repeat 모션은 화면 밖에서도 돈다', (tester) async {
      const probeKey = ValueKey('probe-repeat-mount');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(
                  key: ValueKey('spacer-repeat-mount'),
                  height: 400,
                ),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(repeat: true, reverse: true),
                    params: const MotionParams({'start': 'mount'}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(opacityOf(tester, probeKey), greaterThan(0.0)); // 화면 밖이어도 진행

      await tester.pumpWidget(const SizedBox()); // 무한 애니라 정리
    });

    testWidgets('H: 화면 밖 모션은 정착 후 유휴 상태 — 보류 중인 프레임/타이머 없음', (tester) async {
      const probeKey = ValueKey('probe-idle');
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(key: ValueKey('spacer-idle'), height: 1000),
                KeyedSubtree(
                  key: probeKey,
                  child: MotionWrapper(
                    motion: const _ProbeMotion(),
                    params: const MotionParams({}),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
                const SizedBox(height: 1000),
              ],
            ),
          ),
        ),
      );

      // pumpAndSettle must return without timing out even though the gate
      // never passes (the motion stays off-screen) — proving there is no
      // periodic polling keeping frames/timers alive.
      await tester.pumpAndSettle();
      expect(opacityOf(tester, probeKey), 0.0); // still gated — never started
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('I: 폭 0에서 펼쳐지는 reveal 도 보이면 시작해 끝까지 펼친다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              children: [
                // settle_card 막대처럼 느슨한 폭(align) 안 — 시작 프레임의 폭이 실제로 0이 된다.
                Align(
                  alignment: Alignment.centerLeft,
                  child: MotionWrapper(
                    motion: const RevealMotion(),
                    params: const MotionParams({'direction': 'right'}),
                    child: const SizedBox(width: 200, height: 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final align = tester.widget<Align>(
        find
            .descendant(
              of: find.byType(MotionWrapper),
              matching: find.byType(Align),
            )
            .first,
      );
      expect(align.widthFactor, 1.0); // 시작 프레임 폭 0이 '안 보임'으로 판정돼 멈추지 않는다
    });

    testWidgets('J: 화면 밖에서 들어오는 move 도 자리가 보이면 시작한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              children: [
                MotionWrapper(
                  motion: const MoveMotion(),
                  params: const MotionParams({
                    'begin': [-1000, 0],
                    'end': [0, 0],
                  }),
                  child: const SizedBox(width: 200, height: 40),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final translate = tester.widget<Transform>(
        find.descendant(
          of: find.byType(MotionWrapper),
          matching: find.byType(Transform),
        ),
      );
      // 모션이 시작 프레임에 자식을 화면 밖으로 옮겨도, 판정은 자식이 놓일 자리로 한다.
      expect(translate.transform.getTranslation().x, 0.0);
    });

    for (final direction in ['left', 'up']) {
      testWidgets('K: 왼쪽 위 자리의 reveal($direction)도 보이면 시작한다', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 400,
              height: 300,
              child: ListView(
                children: [
                  SizedBox(
                    height: 100,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: MotionWrapper(
                        motion: const RevealMotion(),
                        params: MotionParams({'direction': direction}),
                        child: const SizedBox(width: 200, height: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        final align = tester.widget<Align>(
          find
              .descendant(
                of: find.byType(MotionWrapper),
                matching: find.byType(Align),
              )
              .first,
        );
        expect(align.widthFactor ?? align.heightFactor, 1.0);
      });
    }

    testWidgets('L: reveal 을 감싼 fade 도 보이면 시작한다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: MotionWrapper(
                    motion: const FadeMotion(),
                    params: const MotionParams({}),
                    child: MotionWrapper(
                      motion: const RevealMotion(),
                      params: const MotionParams({'direction': 'right'}),
                      child: const SizedBox(width: 200, height: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
    });

    // 중첩 스크롤(세로 → 탭뷰 → 세로) 안의 목록 항목.
    Widget probe(Key key) => KeyedSubtree(
      key: key,
      child: MotionWrapper(
        motion: const _ProbeMotion(),
        params: const MotionParams({}),
        child: const SizedBox(height: 80),
      ),
    );

    testWidgets('M: 중첩 스크롤 안에서 화면에 보이는 항목은 모두 시작한다', (tester) async {
      final keys = [for (var i = 0; i < 6; i++) ValueKey('item-$i')];
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 600,
            child: ListView(
              children: [
                const SizedBox(height: 100),
                SizedBox(
                  height: 500,
                  child: PageView(
                    children: [
                      ListView(children: [for (final k in keys) probe(k)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      for (final k in keys) {
        expect(opacityOf(tester, k), 1.0, reason: '$k');
      }
    });

    testWidgets('N: 중첩 스크롤 안 PageView 2쪽은 넘기는 중엔 대기, 정착 후 시작', (tester) async {
      const key = ValueKey('page-2');
      final pages = PageController();
      addTearDown(pages.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 600,
            child: ListView(
              children: [
                const SizedBox(height: 100),
                SizedBox(
                  height: 500,
                  child: PageView(
                    controller: pages,
                    allowImplicitScrolling: true,
                    children: [
                      const SizedBox(),
                      ListView(children: [probe(key)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(opacityOf(tester, key), 0.0);

      unawaited(
        pages.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacityOf(tester, key), 0.0); // 넘기는 중

      await tester.pumpAndSettle();
      expect(opacityOf(tester, key), 1.0);
    });

    testWidgets('O: 바깥 스크롤 화면 밖의 중첩 항목은 보일 때까지 대기', (tester) async {
      const key = ValueKey('below');
      final outer = ScrollController();
      addTearDown(outer.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 600,
            child: ListView(
              controller: outer,
              cacheExtent: 2000,
              children: [
                const SizedBox(height: 700),
                SizedBox(
                  height: 500,
                  child: PageView(
                    children: [
                      ListView(children: [probe(key)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(opacityOf(tester, key), 0.0);

      outer.jumpTo(400);
      await tester.pumpAndSettle();
      expect(opacityOf(tester, key), 1.0);
    });
  });

  // 0.7.0: 한 모션 레이어의 실패는 그 레이어만 노드 수명 동안 끈다. 자식은 그
  // 레이어가 없던 것처럼 그려지고 다른 레이어는 계속 돌며, 아무것도 보고하지 않는다.
  group('MotionWrapper 실패 격리', () {
    late List<SduiError> errors;
    late List<String> logs;

    setUp(() {
      errors = [];
      logs = [];
      EngineErrors.observer = _Capture(errors);
      EngineLog.configure(output: logs.add);
      MotionFactory.registerAll(const [
        _MarkerMotion(),
        _MarkerMotion(type: 'bad_plan', throwsInPlan: true),
        _MarkerMotion(type: 'bad_frame', throwsAfter: 0),
        _MarkerMotion(type: 'halfway', throwsAfter: 0.5),
      ]);
      FunctionRegistry.register(
        'boom',
        (args) => args.first == 0 ? throw ArgumentError('boom') : args.first,
      );
    });
    tearDown(() {
      EngineErrors.reset();
      EngineLog.configure(output: debugPrint);
      MotionFactory.reset();
      FunctionRegistry.reset();
    });

    Finder marker() => find.byWidgetPredicate(
      (w) => w is ColoredBox && w.color == _MarkerMotion.color,
    );

    Widget mount(Object? motion, {Map<String, Object?> data = const {}}) =>
        MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              rootData: data,
              template: {'_type': 'text', 'value': 'hi', '_motion': motion},
            ),
          ),
        );

    for (final bad in ['bad_plan', 'bad_frame']) {
      testWidgets('$bad: 그 레이어만 빠지고 fade는 계속 돈다', (tester) async {
        await tester.pumpWidget(
          mount([
            bad,
            {'type': 'fade', 'duration': 100},
          ]),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        expect(find.text('hi'), findsOneWidget);
        expect(marker(), findsNothing);
        final midway = tester.widget<Opacity>(find.byType(Opacity)).opacity;
        expect(midway, inExclusiveRange(0, 1));
        await tester.pumpAndSettle();
        expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
        expect(errors, isEmpty);
      });
    }

    testWidgets('frame이 도중에 던지면 그 뒤로는 계속 꺼진 채 쉬는 자식을 그린다', (tester) async {
      await tester.pumpWidget(
        mount({'type': 'halfway', 'duration': 100, 'repeat': true}),
      );
      await tester.pump(const Duration(milliseconds: 20));
      expect(marker(), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60)); // t > 0.5 → throw
      expect(tester.takeException(), isNull);
      expect(marker(), findsNothing);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 25));
        expect(marker(), findsNothing, reason: 'frame $i');
      }
      expect(find.text('hi'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(errors, isEmpty);
      expect(logs.where((l) => l.contains('animation off')), hasLength(1));
    });

    testWidgets('길이 0인 반복 모션은 그 레이어만 빠진다', (tester) async {
      await tester.pumpWidget(
        mount([
          {'type': 'marker', 'duration': 0, 'repeat': true},
          {'type': 'fade', 'duration': 100},
        ]),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(marker(), findsNothing);
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        inExclusiveRange(0, 1),
      );
      await tester.pumpAndSettle();
      expect(errors, isEmpty);
    });

    testWidgets('인자 평가가 던지면 그 레이어만 노드 수명 동안 빠진다', (tester) async {
      final data = ValueNotifier<Map<String, Object?>>({'s': 0});
      addTearDown(data.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<Map<String, Object?>>(
          valueListenable: data,
          builder: (context, root, _) => mount([
            {'type': 'marker', 'x': r'${boom(s)}'},
            {'type': 'fade', 'duration': 100},
          ], data: root),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('hi'), findsOneWidget);
      expect(marker(), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      data.value = {'s': 1};
      await tester.pumpAndSettle();
      expect(marker(), findsNothing);
      expect(errors, isEmpty);
    });
  });
}

/// Draws a marker box around the child; optionally fails in `plan()` or in
/// `frame()` once progress passes [throwsAfter].
class _MarkerMotion extends Motion {
  const _MarkerMotion({
    this.type = 'marker',
    this.throwsInPlan = false,
    this.throwsAfter,
  });

  static const color = Color(0xFF123456);

  @override
  final String type;
  final bool throwsInPlan;
  final double? throwsAfter;

  @override
  MotionPlan plan(MotionParams params) {
    if (throwsInPlan) throw StateError('plan failure');
    return MotionPlan.from(params, duration: const Duration(milliseconds: 100));
  }

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final limit = throwsAfter;
    if (limit != null && t > limit) throw ArgumentError('frame failure');
    return ColoredBox(color: color, child: child);
  }
}

/// A repeating motion whose frame keeps the child's render protocol, so it
/// may sit on a sliver node.
class _SliverSafeMotion extends Motion {
  const _SliverSafeMotion();

  @override
  String get type => 'sliver_safe';

  @override
  MotionPlan plan(MotionParams params) =>
      const MotionPlan(duration: Duration(milliseconds: 100), repeat: true);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) =>
      child;
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}
