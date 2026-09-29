import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/src/shell/go_router_navigate.dart';

GoRoute _page(String id) =>
    GoRoute(path: '/$id', builder: (context, state) => Text(id));

GoRouter _router({GoRouterRedirect? redirect}) => GoRouter(
  initialLocation: '/home',
  redirect: redirect,
  routes: [_page('home'), _page('detail'), _page('mission')],
);

/// Tracks a push the way the engine's navigate driver awaits it.
final class _Push {
  _Push(Future<Object?> future) {
    future.then((value) {
      result = value;
      done = true;
    });
  }

  bool done = false;
  Object? result = 'pending';
}

Future<GoRouter> _pump(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  group('goRouterNavigateHandle', () {
    group('push', () {
      testWidgets('pop된 페이지의 결과로 완료된다', (tester) async {
        final router = await _pump(tester, _router());
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);
        expect(push.done, isFalse);

        router.pop('picked');
        await tester.pumpAndSettle();
        expect(push.result, 'picked');
      });

      testWidgets('go가 스택을 교체하면 null로 완료된다', (tester) async {
        final router = await _pump(tester, _router());
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pumpAndSettle();

        router.go('/mission');
        await tester.pumpAndSettle();
        expect(find.text('mission'), findsOneWidget);
        expect(push.done, isTrue);
        expect(push.result, isNull);
      });

      testWidgets('replace로 교체되면 null로 완료된다', (tester) async {
        final router = await _pump(tester, _router());
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pumpAndSettle();

        router.pushReplacement('/mission');
        await tester.pumpAndSettle();
        expect(find.text('mission'), findsOneWidget);
        expect(push.done, isTrue);
        expect(push.result, isNull);
      });

      testWidgets('위에 쌓인 페이지가 빠져도 자기 페이지가 남아 있으면 완료되지 않는다', (tester) async {
        final router = await _pump(tester, _router());
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pumpAndSettle();

        router.push('/mission');
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);
        expect(push.done, isFalse);
      });

      testWidgets('같은 위치를 두 번 push해도 pop된 쪽만 완료된다', (tester) async {
        final router = await _pump(tester, _router());
        final navigate = goRouterNavigateHandle(router);
        final lower = _Push(navigate.push!('/detail'));
        await tester.pumpAndSettle();
        final upper = _Push(navigate.push!('/detail'));
        await tester.pumpAndSettle();

        router.pop('upper');
        await tester.pumpAndSettle();
        expect(upper.result, 'upper');
        expect(lower.done, isFalse);
      });

      testWidgets('탭 셸 위에 push한 페이지를 다른 탭으로 go하면 null로 완료된다', (tester) async {
        StatefulShellBranch branch(String id) =>
            StatefulShellBranch(routes: [_page(id)]);
        final router = await _pump(
          tester,
          GoRouter(
            initialLocation: '/home',
            routes: [
              StatefulShellRoute.indexedStack(
                builder: (context, state, shell) => shell,
                branches: [branch('home'), branch('mission')],
              ),
              _page('detail'),
            ],
          ),
        );
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pumpAndSettle();
        expect(push.done, isFalse);

        router.go('/mission');
        await tester.pumpAndSettle();
        expect(push.done, isTrue);
        expect(push.result, isNull);
      });

      testWidgets('비동기 redirect 중에 다른 이동이 앞지르면 null로 완료된다', (tester) async {
        final router = await _pump(
          tester,
          _router(
            redirect: (context, state) async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return null;
            },
          ),
        );
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        router.go('/mission');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
        expect(find.text('mission'), findsOneWidget);
        expect(push.done, isTrue);
        expect(push.result, isNull);
      });

      testWidgets('비동기 redirect를 거쳐 올라간 페이지는 pop 결과로 완료된다', (tester) async {
        final router = await _pump(
          tester,
          _router(
            redirect: (context, state) async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
              return null;
            },
          ),
        );
        final push = _Push(goRouterNavigateHandle(router).push!('/detail'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);
        expect(push.done, isFalse);

        router.pop('picked');
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
        expect(push.result, 'picked');
      });
    });

    testWidgets('go는 위치를 교체한다', (tester) async {
      final router = await _pump(tester, _router());
      goRouterNavigateHandle(router).go!('/mission');
      await tester.pumpAndSettle();
      expect(find.text('mission'), findsOneWidget);
    });

    group('pop', () {
      testWidgets('결과를 넘겨 맨 위 페이지를 닫는다', (tester) async {
        final router = await _pump(tester, _router());
        final pushed = router.push<Object?>('/detail');
        await tester.pumpAndSettle();

        goRouterNavigateHandle(router).pop!('done');
        await tester.pumpAndSettle();
        expect(await pushed, 'done');
      });

      testWidgets('닫을 페이지가 없으면 아무것도 하지 않는다', (tester) async {
        final router = await _pump(tester, _router());
        goRouterNavigateHandle(router).pop!();
        await tester.pumpAndSettle();
        expect(find.text('home'), findsOneWidget);
      });
    });
  });
}
