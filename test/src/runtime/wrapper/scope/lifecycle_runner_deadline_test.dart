import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart' as ir;
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/lifecycle_runner.dart';

/// A driver whose every run waits until the test completes its gate.
class _GateDriver extends Driver {
  final gates = <Completer<void>>[];

  @override
  String get type => 'test_gate';

  @override
  Future<Object?> run(DriverContext ctx) {
    final gate = Completer<void>();
    gates.add(gate);
    return gate.future.then((_) => null);
  }
}

void main() {
  tearDown(DriverRegistry.reset);

  testWidgets('watchdog 직전에 mount 실행이 대체돼도 처음 기한에 한 번만 닫는다', (tester) async {
    final driver = _GateDriver();
    DriverRegistry.register(driver);
    var settled = 0;
    final runner =
        LifecycleRunner(
            host: ActionHost(
              env: ScopeEnvironment(const {}),
              actions: const {
                'load': ir.Action(
                  steps: [
                    [ir.Command(type: 'test_gate')],
                  ],
                  dedupe: false,
                ),
              },
            ),
            isMounted: () => true,
            onMountSettled: () => settled++,
          )
          ..deferMountForSkeleton = true
          ..hooks = const [
            LifecycleHook(trigger: LifecycleTrigger.mount, action: 'load'),
          ];
    const almost = Duration(milliseconds: 50);
    runner.visibilityChanged(true);
    await tester.pump(LifecycleRunner.mountWatchdog - almost);
    runner.reconcile();
    await tester.pump();
    expect(driver.gates, hasLength(2));

    driver.gates.first.complete();
    await tester.pump(almost ~/ 2);
    expect(settled, 0);

    await tester.pump(almost);
    expect(settled, 1);

    driver.gates.last.complete();
    await tester.pump(LifecycleRunner.mountWatchdog);
    expect(settled, 1);
    runner.dispose();
  });
}
