import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/sdui_engine.dart';

final class _Loader implements ScreenLoader {
  @override
  Future<LoadedScreen> load(String screenId) async => (
    template: switch (screenId) {
      'hook' => _hookScreen(),
      'slow' => _hookScreen(slow: true),
      _ => <String, Object?>{'_type': 'text', 'value': screenId},
    },
    modals: const <String, Object?>{},
  );
}

/// A screen whose root scope counts its `exit_back` hook runs in `n`; the
/// slow one keeps its hook action running for a second after counting.
Map<String, Object?> _hookScreen({bool slow = false}) => {
  '_requires': ['lifecycle_exit_back_v1', if (slow) 'wait_v1'],
  '_type': 'text',
  'value': r'hook ${n}',
  '_scope': {
    '_state': {'n': 0},
    '_action': {
      'ask': [
        {'_type': 'set', 'n': r'${n + 1}'},
        if (slow) {'_type': 'wait', 'duration': 1000},
      ],
    },
    '_lifecycle': [
      {'on': 'exit_back', 'action': 'ask'},
    ],
  },
};

final _loader = _Loader();

Widget _page(String screenId) => SduiScreenPage(
  key: ValueKey(screenId),
  screenId: screenId,
  loader: _loader,
);

GoRoute _screen(String path, String screenId) =>
    GoRoute(path: path, builder: (context, state) => _page(screenId));

/// Counts the system exits of one test.
final class _Exit {
  int systemPops = 0;
}

Future<_Exit> _pump(
  WidgetTester tester, {
  required List<RouteBase> routes,
  String initialLocation = '/',
  void Function(GoRouter router)? onRouter,
}) async {
  final exit = _Exit();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemNavigator.pop') exit.systemPops++;
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  final router = Sdui.router(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  onRouter?.call(router);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return exit;
}

Future<void> _back(WidgetTester tester) async {
  // ignore: invalid_use_of_protected_member
  await tester.binding.handlePopRoute();
  await tester.pump();
  await tester.pump();
}

void main() {
  group('exit_back lifecycle', () {
    test('X-A1 the public API has no app exit-back callback', () {
      expect(
        File('lib/sdui_engine.dart').readAsStringSync(),
        isNot(contains('SduiExitBackHandler')),
      );
      expect(
        File('lib/src/shell/sdui.dart').readAsStringSync(),
        isNot(contains('onExitBack')),
      );
    });

    testWidgets('X-R1 an unhandled back runs the visible hook once and stays', (
      tester,
    ) async {
      final exit = await _pump(tester, routes: [_screen('/', 'hook')]);

      await _back(tester);

      expect(find.text('hook 1'), findsOneWidget);
      expect(exit.systemPops, 0);
    });

    testWidgets('X-R2 without a visible hook back exits', (tester) async {
      final exit = await _pump(tester, routes: [_screen('/', 'plain')]);

      await _back(tester);

      expect(exit.systemPops, 1);
    });

    testWidgets('X-R3 a pushed route pops without the hook', (tester) async {
      late GoRouter router;
      final exit = await _pump(
        tester,
        routes: [_screen('/', 'hook'), _screen('/detail', 'detail')],
        onRouter: (value) => router = value,
      );
      router.push('/detail');
      await tester.pumpAndSettle();

      await _back(tester);
      await tester.pumpAndSettle();

      expect(find.text('detail'), findsNothing);
      expect(find.text('hook 0'), findsOneWidget);
      expect(exit.systemPops, 0);
    });

    testWidgets('X-R3 PopScope(canPop: false) blocks without the hook', (
      tester,
    ) async {
      var blocked = 0;
      final exit = await _pump(
        tester,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) blocked++;
              },
              child: _page('hook'),
            ),
          ),
        ],
      );

      await _back(tester);

      expect(blocked, 1);
      expect(find.text('hook 0'), findsOneWidget);
      expect(exit.systemPops, 0);
    });

    testWidgets('X-R3 an onExit veto keeps the route without the hook', (
      tester,
    ) async {
      var consulted = 0;
      final exit = await _pump(
        tester,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => _page('hook'),
            onExit: (context, state) {
              consulted++;
              return false;
            },
          ),
        ],
      );

      await _back(tester);

      expect(consulted, 1);
      expect(find.text('hook 0'), findsOneWidget);
      expect(exit.systemPops, 0);
    });

    testWidgets('X-R4 a hook on an inactive shell branch does not fire', (
      tester,
    ) async {
      late GoRouter router;
      final exit = await _pump(
        tester,
        initialLocation: '/b',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, shell) => shell,
            branches: [
              StatefulShellBranch(routes: [_screen('/a', 'plain')]),
              StatefulShellBranch(routes: [_screen('/b', 'hook')]),
            ],
          ),
        ],
        onRouter: (value) => router = value,
      );
      router.go('/a');
      await tester.pumpAndSettle();

      await _back(tester);

      expect(exit.systemPops, 1);
      expect(find.text('hook 0', skipOffstage: false), findsOneWidget);
    });

    testWidgets(
      'X-R5 a back while the hook action runs is deduplicated and consumed',
      (tester) async {
        final exit = await _pump(tester, routes: [_screen('/', 'slow')]);

        await _back(tester);
        await _back(tester);

        expect(find.text('hook 1'), findsOneWidget);
        expect(exit.systemPops, 0);
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('X-R6 a disposed hook screen no longer counts', (tester) async {
      late GoRouter router;
      final exit = await _pump(
        tester,
        routes: [_screen('/', 'hook'), _screen('/a', 'plain')],
        onRouter: (value) => router = value,
      );
      router.go('/a');
      await tester.pumpAndSettle();
      expect(find.text('hook 0', skipOffstage: false), findsNothing);

      await _back(tester);

      expect(exit.systemPops, 1);
    });

    testWidgets('X-R6 a hook screen removed from a current route no longer '
        'counts', (tester) async {
      final shown = ValueNotifier(true);
      addTearDown(shown.dispose);
      final exit = await _pump(
        tester,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ValueListenableBuilder(
              valueListenable: shown,
              builder: (_, show, _) =>
                  show ? _page('hook') : const Text('gone'),
            ),
          ),
        ],
      );
      expect(find.text('hook 0'), findsOneWidget);
      shown.value = false;
      await tester.pumpAndSettle();

      await _back(tester);

      expect(exit.systemPops, 1);
    });
  });
}
