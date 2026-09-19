import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart' as ir;
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/lifecycle_runner.dart';

/// The extraction's point: the hook state machine runs without a widget tree.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ActionHost host;
  late bool mountedFlag;
  late int settled;

  LifecycleRunner runner({List<LifecycleHook> hooks = const []}) =>
      LifecycleRunner(
        host: host,
        isMounted: () => mountedFlag,
        onMountSettled: () => settled++,
      )..hooks = hooks;

  LifecycleHook hook(
    LifecycleTrigger trigger, {
    Duration delay = Duration.zero,
    Duration? every,
  }) => LifecycleHook(
    trigger: trigger,
    action: trigger.name,
    delay: delay,
    every: every,
  );

  setUp(() {
    mountedFlag = true;
    settled = 0;
    final env = ScopeEnvironment(const {'_probe': null});
    host = ActionHost(
      actions: {
        for (final t in LifecycleTrigger.values)
          t.name: ir.Action(
            steps: [
              [
                ir.Command(type: 'set', params: {'_probe': t.name}),
              ],
            ],
            dedupe: false,
          ),
      },
      env: env,
    );
  });

  tearDown(DriverRegistry.reset);

  group('LifecycleRunner', () {
    group('visibilityChanged', () {
      testWidgets('첫 가시화가 mount 훅을 발화한다', (tester) async {
        final r = runner(hooks: [hook(LifecycleTrigger.mount)]);
        r.visibilityChanged(true);
        await tester.pump();
        // set 커맨드는 동기 — env에 반영됐는지로 발화를 검증한다.
        expect(host.env.read('_probe'), 'mount');
        r.dispose();
      });

      testWidgets('가려졌다 돌아오면 remount 훅이 발화한다', (tester) async {
        final r = runner(
          hooks: [hook(LifecycleTrigger.remount)],
        );
        r.visibilityChanged(true);
        r.visibilityChanged(false);
        expect(host.env.read('_probe'), isNull);
        r.visibilityChanged(true);
        expect(host.env.read('_probe'), 'remount');
        r.dispose();
      });
    });

    group('appLifecycleChanged', () {
      testWidgets('백그라운드에서 복귀하면 remount가 발화한다', (tester) async {
        final r = runner(hooks: [hook(LifecycleTrigger.remount)]);
        r.visibilityChanged(true);
        r.appLifecycleChanged(AppLifecycleState.paused);
        r.appLifecycleChanged(AppLifecycleState.resumed);
        expect(host.env.read('_probe'), 'remount');
        r.dispose();
      });
    });

    group('interval', () {
      testWidgets('unmount 후에는 틱이 발화하지 않는다 (유령 타이머 금지)', (tester) async {
        final r = runner(
          hooks: [
            hook(
              LifecycleTrigger.interval,
              every: const Duration(milliseconds: 10),
            ),
          ],
        );
        r.visibilityChanged(true);
        await tester.pump(const Duration(milliseconds: 25));
        expect(host.env.read('_probe'), 'interval');

        mountedFlag = false;
        host.env.commit({'_probe': null});
        await tester.pump(const Duration(milliseconds: 30));
        expect(host.env.read('_probe'), isNull);
        r.dispose();
      });
    });

    group('dispose', () {
      testWidgets('한 번도 가시화되지 않았어도 dispose 훅은 발화한다', (tester) async {
        final r = runner(hooks: [hook(LifecycleTrigger.dispose)]);
        r.dispose();
        expect(host.env.read('_probe'), 'dispose');
      });
    });

    group('reconcile', () {
      testWidgets('훅 교체는 기존 타이머를 끊고 새 표로 재시작한다', (tester) async {
        final r = runner(
          hooks: [
            hook(
              LifecycleTrigger.interval,
              every: const Duration(milliseconds: 10),
            ),
          ],
        );
        r.visibilityChanged(true);
        await tester.pump(const Duration(milliseconds: 15));
        expect(host.env.read('_probe'), 'interval');

        host.env.commit({'_probe': null});
        r.hooks = [hook(LifecycleTrigger.mount)];
        r.reconcile();
        await tester.pump();
        expect(host.env.read('_probe'), 'mount');
        // 옛 interval 타이머는 끊겼다.
        await tester.pump(const Duration(milliseconds: 30));
        expect(host.env.read('_probe'), 'mount');
        r.dispose();
      });
    });

    group('onMountSettled', () {
      testWidgets('skeleton 지연 모드에선 mount flow 정착 후 콜백이 온다', (tester) async {
        final r = runner(hooks: [hook(LifecycleTrigger.mount)])
          ..deferMountForSkeleton = true;
        r.visibilityChanged(true);
        await tester.pump();
        expect(settled, 1);
        r.dispose();
      });
    });
  });
}
