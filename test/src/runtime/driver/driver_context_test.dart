import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/scope/scope_environment.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';

void main() {
  // commit이 CommitScheduler를 경유하므로 바인딩을 세운다.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverContext', () {
    group('state', () {
      test('좁은 StateWriter로 노출되고 commit이 뒤 env에 써진다', () {
        final env = ScopeEnvironment({'count': 0});
        final ctx = DriverContext(
          params: const {},
          state: env,
          isCancelled: () => false,
        );

        expect(ctx.state, isA<StateWriter>());
        ctx.state.commit({'count': 5});

        expect(env.read('count'), 5); // 좁힌 계약으로도 쓰기는 뚫린다
      });
    });

    group('is_cancelled', () {
      test('스냅샷이 아니라 라이브 뷰 — 소스가 바뀌면 따라 바뀐다', () {
        var cancelled = false;
        final ctx = DriverContext(
          params: const {},
          state: ScopeEnvironment(const {}),
          isCancelled: () => cancelled,
        );

        expect(ctx.isCancelled, isFalse);
        cancelled = true;
        expect(ctx.isCancelled, isTrue); // 생성 시점 값을 굳히지 않고 매번 재평가
      });
    });
  });
}
