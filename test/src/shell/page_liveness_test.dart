import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/src/shell/page_liveness.dart';

GoRoute _page(String id) =>
    GoRoute(path: '/$id', builder: (context, state) => Text(id));

/// The first pushed match in the active configuration, shells included.
ImperativeRouteMatch? _pushed(List<RouteMatchBase> matches) {
  for (final match in matches) {
    if (match is ImperativeRouteMatch) return match;
    if (match is ShellRouteMatch) {
      if (_pushed(match.matches) case final found?) return found;
    }
  }
  return null;
}

void main() {
  group('livePageKeys', () {
    testWidgets('push한 페이지는 스택에 있는 동안만 살아 있다', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [_page('home'), _page('detail')],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push<void>('/detail');
      await tester.pumpAndSettle();
      final configuration = router.routerDelegate.currentConfiguration;
      final key = _pushed(configuration.matches)!.pageKey;
      expect(livePageKeys(configuration), contains(key));

      router.pop();
      await tester.pumpAndSettle();
      expect(
        livePageKeys(router.routerDelegate.currentConfiguration),
        isNot(contains(key)),
      );
    });

    testWidgets('비활성 브랜치에 남은 페이지도 살아 있다', (tester) async {
      late StatefulNavigationShell shell;
      final router = GoRouter(
        initialLocation: '/a',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, value) => shell = value,
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/a',
                    builder: (_, _) => const Text('a'),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (_, _) => const Text('detail'),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(routes: [_page('b')]),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push<void>('/a/detail');
      await tester.pumpAndSettle();
      final key = _pushed(
        router.routerDelegate.currentConfiguration.matches,
      )!.pageKey;

      shell.goBranch(1);
      await tester.pumpAndSettle();
      final configuration = router.routerDelegate.currentConfiguration;
      expect(_pushed(configuration.matches), isNull);
      expect(livePageKeys(configuration), contains(key));
    });
  });
}
