import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart' as ir;
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/exit_back_registry.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/lifecycle_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(DriverRegistry.reset);

  testWidgets(
    'X-R7 mount, render, remount and dispose never run an exit_back hook',
    (tester) async {
      final host = ActionHost(
        actions: {
          'ask': ir.Action(
            steps: [
              [
                ir.Command(type: 'set', params: {'_probe': 'asked'}),
              ],
            ],
            dedupe: false,
          ),
        },
        env: ScopeEnvironment(const {'_probe': null}),
      );
      final runner =
          LifecycleRunner(
              host: host,
              isMounted: () => true,
              onMountSettled: () {},
            )
            ..hooks = const [
              LifecycleHook(trigger: LifecycleTrigger.exitBack, action: 'ask'),
            ];

      runner.visibilityChanged(true);
      await tester.pump();
      runner.visibilityChanged(false);
      runner.visibilityChanged(true);
      runner.appLifecycleChanged(AppLifecycleState.paused);
      runner.appLifecycleChanged(AppLifecycleState.resumed);
      runner.reconcile();
      await tester.pump();
      runner.dispose();

      expect(host.env.read('_probe'), isNull);
    },
  );

  testWidgets('X-R8 a visible scope that gains exit_back in place counts', (
    tester,
  ) async {
    Widget scoped(Map<String, Object?> scope) => Directionality(
      textDirection: TextDirection.ltr,
      child: NodeBuilder.build(
        TemplateCompiler.buildDirectiveTree(
          TemplateParser.buildUiTree({
            '_type': 'text',
            'value': r'n ${n}',
            '_scope': scope,
          }),
        ),
      ),
    );
    await tester.pumpWidget(
      scoped(const {
        '_state': {'n': 0},
      }),
    );
    await tester.pumpWidget(
      scoped(const {
        '_state': {'n': 0},
        '_action': {
          'ask': {'_type': 'set', 'n': r'${n + 1}'},
        },
        '_lifecycle': [
          {'on': 'exit_back', 'action': 'ask'},
        ],
      }),
    );

    final consumed = ExitBackRegistry.fire();
    await tester.pump();

    expect(consumed, isTrue);
    expect(find.text('n 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('X-R9 a candidate removed by an earlier one in the same back is '
      'skipped', () {
    final calls = <String>[];
    void second() => calls.add('second');
    void first() {
      calls.add('first');
      ExitBackRegistry.remove(second);
    }

    ExitBackRegistry.add(first);
    ExitBackRegistry.add(second);
    addTearDown(() {
      ExitBackRegistry.remove(first);
      ExitBackRegistry.remove(second);
    });

    expect(ExitBackRegistry.fire(), isTrue);
    expect(calls, ['first']);
  });
}
