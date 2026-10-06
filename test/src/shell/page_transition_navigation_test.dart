import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/testing.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/shell/go_router_navigate.dart';
import 'package:sdui_engine/src/shell/transition_preload.dart';
import 'package:sdui_engine/src/shell/sdui_state.dart';

LoadedScreen _screen(String id, {Object? transition}) => (
  template: {'_type': 'text', 'value': id, '_transition': ?transition},
  modals: const {},
);

final class _Loader implements ScreenLoader {
  _Loader({this.detail, this.home});
  final Future<LoadedScreen> Function()? detail;
  final Future<LoadedScreen> Function()? home;
  final calls = <String>[];
  @override
  Future<LoadedScreen> load(String id) {
    calls.add(id);
    if (id == 'home' && home != null) return home!();
    return id == 'detail' && detail != null
        ? detail!()
        : Future.value(_screen(id));
  }
}

final class _Sink implements TelemetrySink {
  final events = <TelemetryEvent>[];
  Iterable<TelemetryEvent> get views =>
      events.where((e) => e.event == 'screen_view');
  @override
  void record(TelemetryEvent event) => events.add(event);
  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async =>
      _Reservation();
}

final class _Reservation implements TelemetryReservation {
  @override
  void complete({Map<String, Object?> properties = const {}}) {}
}

final class _Errors extends SduiErrorObserver {
  final errors = <SduiError>[];
  @override
  void onError(SduiError error) => errors.add(error);
}

final class _Push {
  _Push(Future<Object?> future) {
    future.then((value) {
      done = true;
      result = value;
    });
  }
  bool done = false;
  Object? result;
}

void _style({bool enabled = true, String type = 'fade', bool reduced = true}) {
  EnginePresentation.value = SduiPresentation(
    transitions: PageTransitionStyle(
      enabled: enabled,
      defaultType: type,
      respectReducedMotion: reduced,
      preloadTimeout: const Duration(milliseconds: 100),
    ),
  );
}

Future<GoRouter> _pump(
  WidgetTester tester,
  _Loader loader, {
  bool cupertino = false,
  bool reduced = false,
  List<RouteBase> routes = const [],
  SduiLoadingBuilder? loadingBuilder,
}) async {
  final router = Sdui.router(
    loader: loader,
    routes: routes,
    loadingBuilder: loadingBuilder,
  );
  addTearDown(router.dispose);
  Widget builder(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: child!,
  );
  await tester.pumpWidget(
    cupertino
        ? CupertinoApp.router(routerConfig: router, builder: builder)
        : MaterialApp.router(routerConfig: router, builder: builder),
  );
  await tester.pumpAndSettle();
  return router;
}

Page<Object?> _page(WidgetTester tester) =>
    tester.widget<Navigator>(find.byType(Navigator).first).pages.last;
PageRoute<dynamic> _route(WidgetTester tester) =>
    ModalRoute.of(tester.element(find.text('detail')))! as PageRoute<dynamic>;
FadeTransition _fade(WidgetTester tester) => tester.widget<FadeTransition>(
  find
      .ancestor(of: find.text('detail'), matching: find.byType(FadeTransition))
      .first,
);
Future<void> _open(WidgetTester tester, GoRouter router, _Loader loader) async {
  goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  setUp(_style);
  tearDown(resetEngineForTest);

  testWidgets('disabled_style_legacy_path', (tester) async {
    _style(enabled: false);
    final pending = Completer<LoadedScreen>();
    final sink = _Sink();
    Telemetry.install(sink);
    final loader = _Loader(detail: () => pending.future);
    final router = await _pump(tester, loader);
    goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
    expect(loader.calls, ['home']);
    expect(sink.views.map((e) => e.screenId), ['home']);
    await tester.pump();
    expect(loader.calls, ['home', 'detail']);
    expect(_page(tester), isA<MaterialPage<void>>());
    expect(sink.views.map((e) => e.screenId), ['home']);
    pending.complete(_screen('detail'));
    await tester.pumpAndSettle();
    expect(sink.views.map((e) => e.screenId), ['home', 'detail']);
  });

  for (final cupertino in [false, true]) {
    for (final token in [false, true]) {
      testWidgets(
        'platform_page_matches_go_router_default ${cupertino ? 'Cupertino' : 'Material'} token=$token',
        (tester) async {
          _style(type: 'platform');
          final loader = _Loader();
          final router = await _pump(tester, loader, cupertino: cupertino);
          if (token) {
            await _open(tester, router, loader);
          }
          final page = _page(tester);
          expect(
            page.runtimeType.toString(),
            cupertino ? 'CupertinoPage<void>' : 'MaterialPage<void>',
          );
          expect(page.name, '/screens/:id');
          expect(page.arguments, {'id': token ? 'detail' : 'home'});
          expect(page.restorationId, (page.key as ValueKey<String>).value);
        },
      );
    }
  }

  testWidgets(
    'platform_page_matches_go_router_default WidgetsApp unknown token',
    (tester) async {
      final loader = _Loader();
      final router = Sdui.router(loader: loader);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        WidgetsApp.router(color: Colors.white, routerConfig: router),
      );
      await tester.pumpAndSettle();
      router.push('/screens/detail', extra: 'unknown');
      await tester.pumpAndSettle();
      expect(_page(tester), isA<NoTransitionPage<void>>());
    },
  );

  testWidgets('transition_applied_from_destination_root', (tester) async {
    _style(type: 'none');
    final loader = _Loader(
      detail: () async => _screen(
        'detail',
        transition: {
          'type': 'fade',
          'duration': 600,
          'reverse_duration': 450,
          'curve': 'linear',
        },
      ),
    );
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    expect(
      _route(tester).transitionDuration,
      const Duration(milliseconds: 600),
    );
    expect(
      _route(tester).reverseTransitionDuration,
      const Duration(milliseconds: 450),
    );
    expect(_fade(tester).opacity.value, 1);
    expect(_route(tester).opaque, isTrue);
  });

  testWidgets('default_used_when_no_transition', (tester) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    expect(_fade(tester).opacity.value, 1);
    expect(
      _route(tester).transitionDuration,
      const Duration(milliseconds: 200),
    );
  });

  testWidgets('preload_once_no_double_load_and_screen_view_once_per_visit', (
    tester,
  ) async {
    final sink = _Sink();
    Telemetry.install(sink);
    final loader = _Loader();
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    expect(loader.calls.where((id) => id == 'detail').length, 1);
    expect(sink.views.where((e) => e.screenId == 'detail').length, 1);
    router.pop();
    await tester.pumpAndSettle();
    await _open(tester, router, loader);
    expect(sink.views.where((e) => e.screenId == 'detail').length, 2);
    expect(sink.views.map((e) => e.screenViewId).toSet().length, 3);
  });

  testWidgets('preloaded_page_renders_engine_on_first_frame', (tester) async {
    var loading = 0;
    final sink = _Sink();
    Telemetry.install(sink);
    final loader = _Loader();
    final router = await _pump(
      tester,
      loader,
      loadingBuilder: (_) {
        loading++;
        return const Text('loading');
      },
    );
    loading = 0;
    goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
    await tester.idle();
    expect(sink.views.where((e) => e.screenId == 'detail'), isEmpty);
    await tester.pump();
    expect(sink.views.where((e) => e.screenId == 'detail').length, 1);
    expect(find.text('detail', skipOffstage: false), findsOneWidget);
    expect(loading, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('preload_timeout_pushes_with_default_and_same_future', (
    tester,
  ) async {
    final pending = Completer<LoadedScreen>();
    final loader = _Loader(detail: () => pending.future);
    final router = await _pump(tester, loader);
    goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
    await tester.pump(const Duration(milliseconds: 99));
    expect(router.canPop(), isFalse);
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(router.canPop(), isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(loader.calls.where((id) => id == 'detail').length, 1);
    pending.complete(_screen('detail', transition: {'type': 'none'}));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
    expect(_fade(tester).opacity.value, 1);
    expect(loader.calls.where((id) => id == 'detail').length, 1);
  });

  testWidgets('preload_overtaken_settles_null_and_never_pushes_late', (
    tester,
  ) async {
    final pending = Completer<LoadedScreen>();
    final loader = _Loader(detail: () => pending.future);
    final router = await _pump(tester, loader);
    final push = _Push(
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
    );
    router.go('/screens/mission');
    await tester.pump();
    expect(push.done, isTrue);
    expect(push.result, isNull);
    pending.complete(_screen('detail'));
    await tester.pumpAndSettle();
    expect(find.text('mission'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
    expect(router.canPop(), isFalse);
  });

  testWidgets('second_preload_overtakes_first_without_late_push', (
    tester,
  ) async {
    final pending = Completer<LoadedScreen>();
    final loader = _Loader(detail: () => pending.future);
    final router = await _pump(tester, loader);
    final handle = goRouterNavigateHandle(router, loader: loader);
    final push = _Push(handle.push!('/screens/detail'));
    handle.push!('/screens/mission');
    await tester.pumpAndSettle();
    expect(push.done, isTrue);
    pending.complete(_screen('detail'));
    await tester.pumpAndSettle();
    expect(find.text('mission'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
  });

  for (final afterTimeout in [false, true]) {
    testWidgets('preload_error_shows_error_ui_once timeout=$afterTimeout', (
      tester,
    ) async {
      final errors = _Errors();
      EngineErrors.observer = errors;
      final pending = Completer<LoadedScreen>();
      var fail = true;
      final loader = _Loader(
        detail: () => fail ? pending.future : Future.value(_screen('detail')),
      );
      final router = await _pump(tester, loader);
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
      if (afterTimeout) {
        await tester.pump(const Duration(milliseconds: 110));
      }
      pending.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed to load'), findsOneWidget);
      expect(errors.errors.length, 1);
      expect(errors.errors.single.scope, SduiErrorScope.screenLoad);
      expect(tester.takeException(), isNull);
      fail = false;
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(loader.calls.where((id) => id == 'detail').length, 2);
    });
  }

  testWidgets('abandoned_preload_late_error_is_handled', (tester) async {
    final pending = Completer<LoadedScreen>();
    final loader = _Loader(detail: () => pending.future);
    final router = await _pump(tester, loader);
    final push = _Push(
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
    );
    router.go('/screens/mission');
    await tester.pumpAndSettle();
    pending.completeError(StateError('late'));
    await tester.pumpAndSettle();
    expect(push.done, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid_transition_reported_once_and_uses_default', (
    tester,
  ) async {
    final errors = _Errors();
    EngineErrors.observer = errors;
    final loader = _Loader(
      detail: () async => _screen('detail', transition: {'type': 'missing'}),
    );
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    expect(find.text('detail'), findsOneWidget);
    expect(errors.errors.length, 1);
    expect(errors.errors.single.scope, SduiErrorScope.templateCompile);
    expect(_fade(tester).opacity.value, 1);
  });

  testWidgets(
    'late_timeout_invalid_transition_reports_once_and_keeps_default',
    (tester) async {
      final pending = Completer<LoadedScreen>();
      final errors = _Errors();
      EngineErrors.observer = errors;
      final loader = _Loader(detail: () => pending.future);
      final router = await _pump(tester, loader);
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
      await tester.pump(const Duration(milliseconds: 110));
      await tester.pump();
      pending.complete(_screen('detail', transition: {'type': 'missing'}));
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(errors.errors.length, 1);
      expect(errors.errors.single.scope, SduiErrorScope.templateCompile);
      expect(_fade(tester).opacity.value, 1);
      expect(loader.calls.where((id) => id == 'detail').length, 1);
    },
  );

  testWidgets('page_builder_rebuild_preserves_preload_and_transition', (
    tester,
  ) async {
    _style(type: 'none');
    final loader = _Loader(
      detail: () async => _screen('detail', transition: {'type': 'fade'}),
    );
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    final page = _page(tester);
    router.refresh();
    await tester.pumpAndSettle();
    expect(_page(tester).runtimeType, page.runtimeType);
    expect(_fade(tester).opacity.value, 1);
    expect(loader.calls.where((id) => id == 'detail').length, 1);
  });

  testWidgets('pop_plays_reverse', (tester) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    await _open(tester, router, loader);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final first = _fade(tester).opacity.value;
    expect(first, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 50));
    expect(_fade(tester).opacity.value, lessThan(first));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsNothing);
  });

  testWidgets(
    'ios_edge_swipe_scrubs_reverse_and_cancel_restores',
    (tester) async {
      final loader = _Loader();
      final router = await _pump(tester, loader);
      await _open(tester, router, loader);
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      final drag = await tester.startGesture(const Offset(5, 200));
      await drag.moveBy(const Offset(30, 0));
      await tester.pump();
      await drag.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(navigator.userGestureInProgress, isTrue);
      expect(_fade(tester).opacity.value, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 500));
      await drag.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(_fade(tester).opacity.value, 1);
      expect(navigator.userGestureInProgress, isFalse);
      final commit = await tester.startGesture(const Offset(5, 200));
      await commit.moveBy(const Offset(30, 0));
      await tester.pump();
      await commit.moveBy(const Offset(550, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await commit.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsNothing);
      expect(navigator.userGestureInProgress, isFalse);
    },
    variant: TargetPlatformVariant({TargetPlatform.iOS}),
  );

  for (final respect in [true, false]) {
    testWidgets('reduced_motion_forces_none respect=$respect', (tester) async {
      _style(reduced: respect);
      final loader = _Loader();
      final router = await _pump(tester, loader, reduced: true);
      await _open(tester, router, loader);
      expect(
        _route(tester).transitionDuration,
        respect ? Duration.zero : const Duration(milliseconds: 200),
      );
    });
  }

  testWidgets('store_cleared_on_consume_and_settle', (tester) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    final push = _Push(
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
    );
    await tester.pumpAndSettle();
    final token =
        (router.routerDelegate.currentConfiguration.matches.last
                as ImperativeRouteMatch)
            .matches
            .extra;
    expect(token, isA<String>());
    final store = TransitionPreloads.of(router)!;
    final key = _page(tester).key!;
    expect(
      store.bind(token, const ValueKey('other'), Uri.parse('/screens/detail')),
      isNull,
    );
    expect(store.bind(token, key, Uri.parse('/screens/detail')), isNotNull);
    router.pop('picked');
    await tester.pumpAndSettle();
    expect(push.result, 'picked');
    expect(store.bind(token, key, Uri.parse('/screens/detail')), isNull);
  });

  testWidgets('go_preloads_once_and_removes_binding_on_departure', (
    tester,
  ) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    goRouterNavigateHandle(router, loader: loader).go!('/screens/detail');
    await tester.pumpAndSettle();
    final token = router.routerDelegate.currentConfiguration.extra;
    final store = TransitionPreloads.of(router)!;
    final key = _page(tester).key!;
    expect(store.bind(token, key, Uri.parse('/screens/detail')), isNotNull);
    expect(router.canPop(), isFalse);
    expect(_fade(tester).opacity.value, 1);
    router.go('/screens/mission');
    await tester.pumpAndSettle();
    expect(store.bind(token, key, Uri.parse('/screens/detail')), isNull);
    expect(loader.calls.where((id) => id == 'detail').length, 1);
  });

  testWidgets('app_route_does_not_preload', (tester) async {
    final loader = _Loader();
    final router = await _pump(
      tester,
      loader,
      routes: [
        GoRoute(
          path: '/screens/detail',
          builder: (_, _) => const Text('custom'),
        ),
      ],
    );
    await _open(tester, router, loader);
    expect(find.text('custom'), findsOneWidget);
    expect(loader.calls, ['home']);
  });

  for (final method in ['pop', 'go', 'replace']) {
    testWidgets('push_with_token_still_settles_$method', (tester) async {
      final loader = _Loader();
      final router = await _pump(tester, loader);
      final push = _Push(
        goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
      );
      await tester.pumpAndSettle();
      expect(push.done, isFalse);
      switch (method) {
        case 'pop':
          router.pop('picked');
        case 'go':
          router.go('/screens/mission');
        case 'replace':
          router.pushReplacement('/screens/mission');
      }
      await tester.pumpAndSettle();
      expect(push.done, isTrue);
      expect(push.result, method == 'pop' ? 'picked' : isNull);
    });
  }

  testWidgets('push_with_token_same_location_only_top_settles', (tester) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    final handle = goRouterNavigateHandle(router, loader: loader);
    final lower = _Push(handle.push!('/screens/detail'));
    await tester.pumpAndSettle();
    final upper = _Push(handle.push!('/screens/detail'));
    await tester.pumpAndSettle();
    router.pop('upper');
    await tester.pumpAndSettle();
    expect(upper.result, 'upper');
    expect(lower.done, isFalse);
    router.push('/screens/mission');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(lower.done, isFalse);
    router.pop('lower');
    await tester.pumpAndSettle();
    expect(lower.result, 'lower');
  });

  testWidgets('facade_loader_override_is_used_by_engine_navigation', (
    tester,
  ) async {
    final defaultLoader = _Loader();
    SduiState.screenLoader = defaultLoader;
    final loader = _Loader(
      home: () async => (
        template: <String, Object?>{
          '_type': 'container',
          '_scope': {
            '_action': {
              'open': {'_type': 'navigate', 'route': '/screens/detail'},
            },
          },
          '_child': {
            '_type': 'text',
            'value': 'open detail',
            '_on': {'tap': 'open'},
          },
        },
        modals: const <String, Object?>{},
      ),
    );
    final router = await _pump(tester, loader);
    await tester.tap(find.text('open detail'));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
    expect(loader.calls, ['home', 'detail']);
    expect(defaultLoader.calls, isEmpty);
    expect(_fade(tester).opacity.value, 1);
    router.pop();
    await tester.pumpAndSettle();
  });

  testWidgets('spec_curve_drives_push_and_reverse', (tester) async {
    final loader = _Loader(
      detail: () async => _screen(
        'detail',
        transition: {
          'type': 'fade',
          'curve': 'ease_in',
          'duration': 400,
          'reverse_duration': 400,
        },
      ),
    );
    final router = await _pump(tester, loader);
    goRouterNavigateHandle(router, loader: loader).push!('/screens/detail');
    await tester.idle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    var progress = _route(tester).animation!.value;
    expect(progress, inExclusiveRange(0, 1));
    expect(
      _fade(tester).opacity.value,
      closeTo(Curves.easeIn.transform(progress), 0.001),
    );
    await tester.pumpAndSettle();
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    progress = _route(tester).animation!.value;
    expect(progress, inExclusiveRange(0, 1));
    expect(
      _fade(tester).opacity.value,
      closeTo(Curves.easeIn.transform(progress), 0.001),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('router_constructed_before_enabled_style_uses_transition', (
    tester,
  ) async {
    _style(enabled: false);
    final loader = _Loader();
    final router = Sdui.router(loader: loader);
    addTearDown(router.dispose);
    _style();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await _open(tester, router, loader);
    expect(_fade(tester).opacity.value, 1);
  });

  testWidgets('go_same_location_adopts_new_preload_and_visit', (tester) async {
    var count = 0;
    final sink = _Sink();
    Telemetry.install(sink);
    final loader = _Loader(detail: () async => _screen('detail-${++count}'));
    final router = await _pump(tester, loader);
    final handle = goRouterNavigateHandle(router, loader: loader);
    handle.go!('/screens/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail-1'), findsOneWidget);
    handle.go!('/screens/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail-2'), findsOneWidget);
    expect(sink.views.where((e) => e.screenId == 'detail').length, 2);
    final token = router.routerDelegate.currentConfiguration.extra;
    expect(
      TransitionPreloads.of(
        router,
      )!.bind(token, _page(tester).key!, Uri.parse('/screens/detail')),
      isNotNull,
    );
  });

  testWidgets('unknown_extra_on_same_location_returns_legacy_page', (
    tester,
  ) async {
    final loader = _Loader();
    final router = await _pump(tester, loader);
    goRouterNavigateHandle(router, loader: loader).go!('/screens/detail');
    await tester.pumpAndSettle();
    router.go('/screens/detail', extra: 'unknown');
    await tester.pumpAndSettle();
    expect(_page(tester), isA<MaterialPage<void>>());
  });

  for (final overtaken in [false, true]) {
    testWidgets('push_with_token_async_redirect overtaken=$overtaken', (
      tester,
    ) async {
      final loader = _Loader();
      final facade = Sdui.router(loader: loader);
      final original = facade.configuration.routes.last as GoRoute;
      final route = GoRoute(
        path: original.path,
        pageBuilder: original.pageBuilder,
        redirect: (_, _) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return null;
        },
      );
      final store = TransitionPreloads.of(facade)!;
      final router = GoRouter(
        initialLocation: '/screens/home',
        routes: [route],
      );
      store.attach(router, route);
      facade.dispose();
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      final push = _Push(
        goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
      );
      await tester.idle();
      if (overtaken) router.go('/screens/mission');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      if (overtaken) {
        expect(push.done, isTrue);
        expect(push.result, isNull);
        expect(find.text('mission'), findsOneWidget);
        expect(find.text('detail'), findsNothing);
      } else {
        expect(_fade(tester).opacity.value, 1);
        expect(push.done, isFalse);
        router.pop('picked');
        await tester.pumpAndSettle();
        expect(push.result, 'picked');
      }
      expect(loader.calls.where((id) => id == 'detail').length, 1);
    });
  }

  testWidgets('push_with_token_from_tab_shell_settles_when_go_switches_tab', (
    tester,
  ) async {
    StatefulShellBranch branch(String id) => StatefulShellBranch(
      routes: [GoRoute(path: '/$id', builder: (_, _) => Text(id))],
    );
    final loader = _Loader();
    final router = Sdui.router(
      loader: loader,
      initialLocation: '/tab-home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => shell,
          branches: [branch('tab-home'), branch('tab-mission')],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final push = _Push(
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
    );
    await tester.pumpAndSettle();
    expect(_fade(tester).opacity.value, 1);
    expect(push.done, isFalse);
    router.go('/tab-mission');
    await tester.pumpAndSettle();
    expect(push.done, isTrue);
    expect(push.result, isNull);
    expect(find.text('tab-mission'), findsOneWidget);
  });

  testWidgets('redirected_destination_does_not_adopt_original_preload', (
    tester,
  ) async {
    final loader = _Loader();
    final facade = Sdui.router(loader: loader);
    final original = facade.configuration.routes.last as GoRoute;
    final route = GoRoute(
      path: original.path,
      pageBuilder: original.pageBuilder,
      redirect: (_, state) =>
          state.pathParameters['id'] == 'detail' ? '/screens/mission' : null,
    );
    final store = TransitionPreloads.of(facade)!;
    final router = GoRouter(initialLocation: '/screens/home', routes: [route]);
    store.attach(router, route);
    facade.dispose();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await _open(tester, router, loader);
    expect(find.text('mission'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
    expect(_page(tester), isA<MaterialPage<void>>());
  });

  testWidgets('preload_invalid_reporting_navigation_never_pushes_late', (
    tester,
  ) async {
    final loader = _Loader(
      detail: () async => _screen('detail', transition: {'type': 'missing'}),
    );
    final router = await _pump(tester, loader);
    EngineErrors.observer = _NavigatingErrorObserver(
      () => router.go('/screens/mission'),
    );
    final push = _Push(
      goRouterNavigateHandle(router, loader: loader).push!('/screens/detail'),
    );
    await tester.pumpAndSettle();
    expect(push.done, isTrue);
    expect(push.result, isNull);
    expect(find.text('mission'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}

final class _NavigatingErrorObserver extends SduiErrorObserver {
  _NavigatingErrorObserver(this.navigate);
  final VoidCallback navigate;
  @override
  void onError(SduiError error) => navigate();
}
