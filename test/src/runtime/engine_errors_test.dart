import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart' as ir;
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_guard.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/action_host.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

final class _CollectingObserver extends SduiErrorObserver {
  final List<SduiError> errors = [];
  @override
  void onError(SduiError error) => errors.add(error);
}

final class _ThrowingDriver extends Driver {
  const _ThrowingDriver();
  @override
  String get type => 'boom';
  @override
  Future<Object?> run(DriverContext ctx) async => throw StateError('bug');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _CollectingObserver observer;

  setUp(() {
    observer = _CollectingObserver();
    EngineErrors.observer = observer;
    // Structured reporting is the observable under test — silence the debug
    // log line it also emits.
    EngineLog.configure(output: (_) {});
  });

  tearDown(() {
    EngineErrors.reset();
    EnginePresentation.reset();
    DriverRegistry.reset();
    EngineLog.configure(output: (line) => debugPrint(line));
  });

  group('EngineErrors', () {
    group('report', () {
      test('설치된 옵저버가 구조화된 에러를 받는다', () {
        EngineErrors.report(
          const SduiError(
            scope: SduiErrorScope.screenLoad,
            error: 'down',
            screenId: 'home',
          ),
        );

        final received = observer.errors.single;
        expect(received.scope, SduiErrorScope.screenLoad);
        expect(received.screenId, 'home');
      });

      test('옵저버가 던져도 엔진 흐름을 죽이지 못한다', () {
        EngineErrors.observer = _ThrowingObserver();
        expect(
          () => EngineErrors.report(
            const SduiError(scope: SduiErrorScope.action, error: 'x'),
          ),
          returnsNormally,
        );
      });
    });

    group('convergence', () {
      test('액션 커맨드의 예상 밖 예외가 action 스코프로 도착한다', () async {
        DriverRegistry.register(const _ThrowingDriver());
        final host = ActionHost(
          actions: {
            'go': ir.Action(
              steps: [
                [ir.Command(type: 'boom')],
              ],
              dedupe: false,
            ),
          },
          env: ScopeEnvironment(const {}),
        );

        await host.handleAwaitable('go');

        expect(observer.errors.single.scope, SduiErrorScope.action);
        expect(observer.errors.single.error, isA<StateError>());
      });

      testWidgets('노드 격리가 nodeBuild 스코프와 경로를 보고한다', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: NodeGuard.run(
              'root.children[2]',
              () => throw const FormatException('bad prop'),
            ),
          ),
        );

        final received = observer.errors.single;
        expect(received.scope, SduiErrorScope.nodeBuild);
        expect(received.nodePath, 'root.children[2]');
      });
    });
  });

  group('EnginePresentation.nodeErrorBuilder', () {
    testWidgets('주입한 빌더가 강등 노드 표면을 대체한다', (tester) async {
      EnginePresentation.value = SduiPresentation(
        nodeErrorBuilder: (context, path, error) =>
            Text('oops:$path', textDirection: TextDirection.ltr),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NodeGuard.run('a.b', () => throw StateError('x')),
        ),
      );

      expect(find.text('oops:a.b'), findsOneWidget);
    });
  });
}

final class _ThrowingObserver extends SduiErrorObserver {
  @override
  void onError(SduiError error) => throw StateError('observer bug');
}
