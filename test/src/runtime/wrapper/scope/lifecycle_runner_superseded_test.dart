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

  testWidgets('대체된 mount 실행이 끝나도 최신 실행 전에는 load 를 닫지 않는다', (tester) async {
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
    runner.visibilityChanged(true);
    await tester.pump();
    runner.reconcile();
    await tester.pump();
    expect(driver.gates, hasLength(2));

    driver.gates.first.complete();
    await tester.pump();

    expect(settled, 0);
    driver.gates.last.complete();
    await tester.pump();
    expect(settled, 1);
    runner.dispose();
  });
}
