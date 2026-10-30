import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sdui_engine/testing.dart';
import 'package:sdui_engine/src/runtime/transition/transition_origin.dart';
import 'package:sdui_engine/src/shell/go_router_navigate.dart';
import 'package:sdui_engine/src/shell/sdui_state.dart';

LoadedScreen _screen(String value, {Object? transition}) => (
  template: {'_type': 'text', 'value': value, '_transition': ?transition},
  modals: const {},
);

/// A home screen whose `open` text navigates to [route] through the engine.
LoadedScreen _link(String route) => (
  template: <String, Object?>{
    '_type': 'container',
    '_scope': {
      '_action': {
        'open': {'_type': 'navigate', 'route': route},
      },
    },
    '_child': {
      '_type': 'text',
      'value': 'open',
      '_on': {'tap': 'open'},
    },
  },
  modals: const <String, Object?>{},
);

final class _Loader implements ScreenLoader {
  _Loader([this.screens = const {}]);
  final Map<String, Future<LoadedScreen> Function()> screens;
  final calls = <String>[];

  /// Ids requested while a frame was building widgets.
  final duringBuild = <String>[];
  @override
  Future<LoadedScreen> load(String id) {
    calls.add(id);
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      duringBuild.add(id);
    }
    final screen = screens[id];
    return screen == null ? Future.value(_screen(id)) : screen();
  }
}

final class _Errors extends SduiErrorObserver {
  final errors = <SduiError>[];
  @override
  void onError(SduiError error) => errors.add(error);
}

final class _Sink implements TelemetrySink {
  final views = <String>[];
  @override
  void record(TelemetryEvent event) {
    if (event.event == 'screen_view') views.add(event.screenId!);
  }

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async =>
      _Reservation();
}

final class _Reservation implements TelemetryReservation {
  @override
  void complete({Map<String, Object?> properties = const {}}) {}
}

final class _ImageSource implements ImageSource {
  @override
  ImageResult resolve(ImageRequest request) => const NoImage();
}

final class _VideoSource implements VideoSource {
  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) =>
      throw UnimplementedError();
}

final class _AppStorage implements AppStorage {
  @override
  Object? get(String key) => null;
  @override
  Future<void> set(String key, Object? value) async {}
}

final class _SecureStorage implements SecureStorage {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> delete(String key) async {}
}

final class _NetworkClient implements NetworkClient {
  @override
  Future<NetworkResult> send(NetworkRequest request) async =>
      const NetworkResult();
}

Future<void> _init(
  ScreenLoader loader, {
  List<String> preload = const [],
  bool enabled = true,
  String type = 'platform',
  bool respect = true,
  SduiErrorObserver? errors,
  TelemetrySink? telemetry,
}) => Sdui.initialize(
  screenLoader: loader,
  networkClient: _NetworkClient(),
  imageSource: _ImageSource(),
  videoSource: _VideoSource(),
  appStorage: _AppStorage(),
  secureStorage: _SecureStorage(),
  preloadScreens: preload,
  errorObserver: errors,
  telemetry: telemetry,
  presentation: SduiPresentation(
    transitions: PageTransitionStyle(
      enabled: enabled,
      defaultType: type,
      respectReducedMotion: respect,
    ),
  ),
);

Future<GoRouter> _pump(
  WidgetTester tester, {
  List<RouteBase> routes = const [],
  bool reduced = false,
}) async {
  final router = Sdui.router(
    routes: routes,
    loadingBuilder: (_) => const Text('loading'),
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Page<Object?> _page(WidgetTester tester) =>
    tester.widget<Navigator>(find.byType(Navigator).first).pages.last;

PageRoute<dynamic> _route(WidgetTester tester, String text) =>
    ModalRoute.of(tester.element(find.text(text)))! as PageRoute<dynamic>;

FadeTransition? _fade(WidgetTester tester, String text) {
  final fades = find.ancestor(
    of: find.text(text),
    matching: find.byType(FadeTransition),
  );
  return fades.evaluate().isEmpty
      ? null
      : tester.widget<FadeTransition>(fades.first);
}

/// A home screen with a tappable `transition_source`.
LoadedScreen _source() => (
  template: <String, Object?>{
    '_type': 'center',
    '_child': {
      '_type': 'transition_source',
      'radius': 18,
      '_child': {
        '_type': 'container',
        'width': 120,
        'height': 80,
        '_child': {'_type': 'text', 'value': 'tap source'},
      },
    },
  },
  modals: const <String, Object?>{},
);

/// The origin scope of the destination route.
TransitionOriginScope _originScope(WidgetTester tester) =>
    tester.widget<TransitionOriginScope>(
      find.ancestor(
        of: find.text('detail', skipOffstage: false),
        matching: find.byType(TransitionOriginScope, skipOffstage: false),
      ),
    );

/// An app route that serves engine screens through [Sdui.page].
GoRoute _appRoute() => GoRoute(
  path: '/app/:screenId',
  pageBuilder: (context, state) => Sdui.page(
    context,
    state,
    screenId: state.pathParameters['screenId']!,
    child: SduiScreenPage(
      screenId: state.pathParameters['screenId']!,
      loader: Sdui.screenLoader,
      loadingBuilder: (_) => const Text('loading'),
    ),
  ),
);

void main() {
  tearDown(resetEngineForTest);

  test(
    'C24: initialize completes only after every warm load settles',
    () async {
      final ok = Completer<LoadedScreen>();
      final failing = Completer<LoadedScreen>();
      final loader = _Loader({
        'detail': () => ok.future,
        'broken': () => failing.future,
      });
      var done = false;
      final init = _init(
        loader,
        preload: ['detail', 'broken'],
        errors: _Errors(),
      ).then((_) => done = true);
      await Future<void>.delayed(Duration.zero);
      expect(done, isFalse);
      ok.complete(_screen('detail'));
      await Future<void>.delayed(Duration.zero);
      expect(done, isFalse);
      failing.completeError(StateError('offline'));
      await init;
      expect(done, isTrue);
    },
  );

  test('C24: configuration errors still throw synchronously', () {
    unawaited(_init(_Loader()));
    expect(() => _init(_Loader()), throwsStateError);
  });

  testWidgets(
    'C1: initialize warms the cache and the page renders it at once',
    (tester) async {
      final loader = _Loader();
      await _init(loader, preload: ['detail']);
      expect(loader.calls, ['detail']);
      var loading = 0;
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (_, _) => SduiScreenPage(
              screenId: 'detail',
              loader: loader,
              loadingBuilder: (_) {
                loading++;
                return const Text('loading');
              },
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      expect(find.text('detail'), findsOneWidget);
      expect(loading, 0);
      expect(loader.duringBuild, isEmpty);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('C2: a failed warm load is reported once and stays uncached', (
    tester,
  ) async {
    final errors = _Errors();
    var fail = true;
    final loader = _Loader({
      'broken': () => fail
          ? Future<LoadedScreen>.error(StateError('offline'))
          : Future.value(_screen('broken')),
    });
    await _init(loader, preload: ['broken'], errors: errors);
    expect(errors.errors.map((e) => (e.scope, e.screenId)), [
      (SduiErrorScope.screenLoad, 'broken'),
    ]);
    fail = false;
    final router = await _pump(tester);
    router.go('/screens/broken');
    await tester.pump();
    expect(find.text('loading'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('broken'), findsOneWidget);
    expect(errors.errors.length, 1);
  });

  testWidgets('C2: a synchronous loader throw is reported the same way', (
    tester,
  ) async {
    final errors = _Errors();
    final loader = _Loader({'broken': () => throw StateError('sync')});
    await _init(loader, preload: ['broken'], errors: errors);
    expect(errors.errors.single.scope, SduiErrorScope.screenLoad);
  });

  testWidgets('C3: a pushed cached screen shows content on its first frame', (
    tester,
  ) async {
    final loader = _Loader({'home': () async => _link('/screens/detail')});
    await _init(loader, preload: ['detail']);
    final router = await _pump(tester);
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();
    expect(router.canPop(), isTrue);
    expect(find.text('detail', skipOffstage: false), findsOneWidget);
    expect(find.text('loading', skipOffstage: false), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('C4: an uncached screen loads asynchronously as before', (
    tester,
  ) async {
    final pending = Completer<LoadedScreen>();
    final loader = _Loader({'detail': () => pending.future});
    await _init(loader);
    final router = await _pump(tester);
    router.push('/screens/detail');
    await tester.pump();
    expect(find.text('loading', skipOffstage: false), findsOneWidget);
    expect(loader.calls, ['home', 'detail']);
    pending.complete(_screen('detail'));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
    expect(find.text('loading'), findsNothing);
  });

  testWidgets('C5: a hit refreshes once in the background for the next open', (
    tester,
  ) async {
    var version = 1;
    final loader = _Loader({'detail': () async => _screen('detail-v$version')});
    await _init(loader, preload: ['detail']);
    final router = await _pump(tester);
    version = 2;
    router.push('/screens/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail-v1'), findsOneWidget);
    expect(loader.calls.where((id) => id == 'detail').length, 2);
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.text('detail-v1'), findsOneWidget);
    expect(loader.calls.where((id) => id == 'detail').length, 2);
    router.pop();
    await tester.pumpAndSettle();
    version = 3;
    router.push('/screens/detail');
    await tester.pump();
    expect(find.text('detail-v2', skipOffstage: false), findsOneWidget);
    expect(find.text('loading', skipOffstage: false), findsNothing);
    await tester.pumpAndSettle();
  });

  for (final app in [false, true]) {
    testWidgets('C6: a cached _transition drives the engine page app=$app', (
      tester,
    ) async {
      final loader = _Loader({
        'detail': () async =>
            _screen('detail', transition: {'type': 'fade', 'duration': 400}),
      });
      await _init(loader, preload: ['detail']);
      final router = await _pump(tester, routes: [_appRoute()]);
      router.push(app ? '/app/detail' : '/screens/detail');
      await tester.pumpAndSettle();
      expect(_page(tester), isNot(isA<MaterialPage<void>>()));
      expect(
        _route(tester, 'detail').transitionDuration,
        const Duration(milliseconds: 400),
      );
      expect(_fade(tester, 'detail')!.opacity.value, 1);
    });
  }

  for (final type in ['fade', 'platform']) {
    testWidgets('C7: an uncached screen uses defaultType=$type', (
      tester,
    ) async {
      final loader = _Loader({
        'detail': () async =>
            _screen('detail', transition: {'type': 'slide'}),
      });
      await _init(loader, type: type);
      final router = await _pump(tester);
      router.push('/screens/detail');
      expect(loader.calls, ['home']);
      await tester.pumpAndSettle();
      if (type == 'platform') {
        expect(_page(tester), isA<MaterialPage<void>>());
      } else {
        expect(
          _route(tester, 'detail').transitionDuration,
          const Duration(milliseconds: 150),
        );
        expect(_fade(tester, 'detail')!.opacity.value, 1);
      }
    });
  }

  testWidgets(
    'C8: disabled transitions keep the host page for cached screens',
    (tester) async {
      final loader = _Loader({
        'detail': () async => _screen('detail', transition: {'type': 'fade'}),
      });
      await _init(loader, preload: ['detail'], enabled: false, type: 'fade');
      final router = await _pump(tester);
      router.push('/screens/detail?tab=a');
      await tester.pumpAndSettle();
      final page = _page(tester);
      expect(page, isA<MaterialPage<void>>());
      expect(page.name, '/screens/:id');
      expect(page.arguments, {'id': 'detail', 'tab': 'a'});
      expect(page.restorationId, (page.key! as ValueKey<String>).value);
      expect(find.text('detail'), findsOneWidget);
    },
  );

  for (final respect in [true, false]) {
    testWidgets('C9: reduced motion on a cached fade respect=$respect', (
      tester,
    ) async {
      final loader = _Loader({
        'detail': () async => _screen('detail', transition: {'type': 'fade'}),
      });
      await _init(loader, preload: ['detail'], respect: respect);
      final router = await _pump(tester, reduced: true);
      router.push('/screens/detail');
      await tester.pumpAndSettle();
      expect(
        _route(tester, 'detail').transitionDuration,
        respect ? Duration.zero : const Duration(milliseconds: 150),
      );
    });
  }

  testWidgets('C10: an invalid declaration is reported once per load', (
    tester,
  ) async {
    final errors = _Errors();
    final loader = _Loader({
      'detail': () async => _screen('detail', transition: {'type': 'missing'}),
    });
    await _init(loader, preload: ['detail'], type: 'fade', errors: errors);
    expect(errors.errors.map((e) => e.scope), [SduiErrorScope.templateCompile]);
    final router = await _pump(tester);
    router.push('/screens/detail');
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
    expect(
      _route(tester, 'detail').transitionDuration,
      const Duration(milliseconds: 150),
    );
    expect(_fade(tester, 'detail')!.opacity.value, 1);
    router.refresh();
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    router.push('/screens/detail');
    await tester.pumpAndSettle();
    // Opening never decodes again; each load (warm, background refresh)
    // reports its declaration exactly once.
    expect(
      errors.errors.every((e) => e.scope == SduiErrorScope.templateCompile),
      isTrue,
    );
    expect(
      errors.errors.length,
      loader.calls.where((id) => id == 'detail').length,
    );
  });

  testWidgets('C11: a pageBuilder rebuild keeps the page and its content', (
    tester,
  ) async {
    final loader = _Loader({
      'detail': () async =>
          _screen('detail', transition: {'type': 'fade', 'duration': 300}),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester);
    router.push('/screens/detail');
    await tester.pumpAndSettle();
    final page = _page(tester);
    final calls = loader.calls.length;
    router.refresh();
    await tester.pumpAndSettle();
    expect(_page(tester).runtimeType, page.runtimeType);
    expect(
      _route(tester, 'detail').transitionDuration,
      const Duration(milliseconds: 300),
    );
    expect(_fade(tester, 'detail')!.opacity.value, 1);
    expect(loader.calls.length, calls);
  });

  testWidgets('C12: an open page keeps its decision after a cache refresh', (
    tester,
  ) async {
    var version = 1;
    final loader = _Loader({
      'detail': () async => version == 1
          ? _screen('detail', transition: {'type': 'fade', 'duration': 300})
          : _screen(
              'detail',
              transition: {'type': 'slide', 'duration': 500},
            ),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester);
    version = 2;
    router.push('/screens/detail');
    await tester.pumpAndSettle();
    expect(loader.calls.where((id) => id == 'detail').length, 2);
    router.refresh();
    await tester.pumpAndSettle();
    expect(
      _route(tester, 'detail').transitionDuration,
      const Duration(milliseconds: 300),
    );
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(_fade(tester, 'detail')!.opacity.value, inExclusiveRange(0, 1));
    expect(
      find.ancestor(
        of: find.text('detail'),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsNothing);
  });

  testWidgets('C13: a decision is released once its page leaves', (
    tester,
  ) async {
    var version = 1;
    final loader = _Loader({
      'detail': () async => version == 1
          ? _screen('detail', transition: {'type': 'fade', 'duration': 300})
          : _screen('detail', transition: {'type': 'fade', 'duration': 500}),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester, routes: [_appRoute()]);
    version = 2;
    router.go('/screens/detail');
    await tester.pumpAndSettle();
    expect(
      _route(tester, 'detail').transitionDuration,
      const Duration(milliseconds: 300),
    );
    // Leave through another route so the generic route's page key returns
    // with the same screen id.
    router.go('/app/mission');
    await tester.pumpAndSettle();
    router.go('/screens/detail');
    await tester.pumpAndSettle();
    expect(
      _route(tester, 'detail').transitionDuration,
      const Duration(milliseconds: 500),
    );
    router.push('/screens/mission');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);
  });

  testWidgets('C14: pop reverses the cached spec with its curve', (
    tester,
  ) async {
    final loader = _Loader({
      'detail': () async => _screen(
        'detail',
        transition: {
          'type': 'fade',
          'curve': 'ease_in',
          'duration': 400,
          'reverse_duration': 450,
        },
      ),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester);
    router.push('/screens/detail');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final route = _route(tester, 'detail');
    expect(route.transitionDuration, const Duration(milliseconds: 400));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 450));
    var progress = route.animation!.value;
    expect(progress, inExclusiveRange(0, 1));
    expect(
      _fade(tester, 'detail')!.opacity.value,
      closeTo(Curves.easeIn.transform(progress), 0.001),
    );
    await tester.pumpAndSettle();
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    progress = route.animation!.value;
    expect(progress, inExclusiveRange(0, 1));
    final first = _fade(tester, 'detail')!.opacity.value;
    expect(first, closeTo(Curves.easeIn.transform(progress), 0.001));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_fade(tester, 'detail')!.opacity.value, lessThan(first));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsNothing);
  });

  testWidgets(
    'C15: an iOS edge swipe scrubs the cached effect',
    (tester) async {
      final loader = _Loader({
        'detail': () async => _screen('detail', transition: {'type': 'fade'}),
      });
      await _init(loader, preload: ['detail'], type: 'none');
      final router = await _pump(tester);
      router.push('/screens/detail');
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      final drag = await tester.startGesture(const Offset(5, 200));
      await drag.moveBy(const Offset(30, 0));
      await tester.pump();
      await drag.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(navigator.userGestureInProgress, isTrue);
      expect(_fade(tester, 'detail')!.opacity.value, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 500));
      await drag.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      expect(_fade(tester, 'detail')!.opacity.value, 1);
      final commit = await tester.startGesture(const Offset(5, 200));
      await commit.moveBy(const Offset(30, 0));
      await tester.pump();
      await commit.moveBy(const Offset(550, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await commit.up();
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsNothing);
      expect(router.canPop(), isFalse);
      expect(navigator.userGestureInProgress, isFalse);
    },
    variant: TargetPlatformVariant({TargetPlatform.iOS}),
  );

  testWidgets('C16: a cached pair effect animates the page below', (
    tester,
  ) async {
    final loader = _Loader({
      'home': () async => _screen('home', transition: {'type': 'fade_through'}),
      'detail': () async =>
          _screen('detail', transition: {'type': 'fade_through'}),
    });
    await _init(loader, preload: ['home', 'detail'], type: 'none');
    final router = await _pump(tester);
    double below() => tester
        .widgetList<FadeTransition>(
          find.ancestor(
            of: find.text('home', skipOffstage: false),
            matching: find.byType(FadeTransition, skipOffstage: false),
          ),
        )
        .map((fade) => fade.opacity.value)
        .reduce((a, b) => a * b);
    expect(below(), 1);
    router.push('/screens/detail');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(below(), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(below(), 1);
  });

  testWidgets('C20: shared_element flies between cached router pages', (
    tester,
  ) async {
    LoadedScreen shared(String id) => (
      template: {
        '_type': 'align',
        'alignment': id == 'home' ? 'top_left' : 'bottom_right',
        '_transition': {'type': 'fade'},
        '_child': {
          '_type': 'shared_element',
          'tag': 'x',
          '_child': {
            '_type': 'container',
            'width': id == 'home' ? 100 : 250,
            'height': id == 'home' ? 100 : 250,
            'color': '#FF0000',
            '_child': {'_type': 'text', 'value': id},
          },
        },
      },
      modals: const {},
    );
    final loader = _Loader({
      'home': () async => shared('home'),
      'detail': () async => shared('detail'),
    });
    await _init(loader, preload: ['home', 'detail'], type: 'none');
    final router = await _pump(tester);
    router.push('/screens/detail');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.byType(RawImage), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(tester.getSize(find.text('detail')).width, greaterThan(0));
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(RawImage), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(RawImage), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('C17: container_transform grows from the tapped source', (
    tester,
  ) async {
    final loader = _Loader({
      'home': () async => _source(),
      'detail': () async =>
          _screen('detail', transition: {'type': 'container_transform'}),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester);
    await tester.tap(find.text('tap source'));
    router.push('/screens/detail');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final captured = _originScope(tester).source;
    expect(captured, isNotNull);
    final source = captured!;
    expect(source.radius, 18);
    expect(source.rect.size, const Size(120, 80));
    expect(source.hidden.value, isTrue);
    expect(find.byType(RawImage), findsOneWidget);
    await tester.pumpAndSettle();
    expect(source.hidden.value, isFalse);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(source.hidden.value, isTrue);
    await tester.pumpAndSettle();
    expect(source.hidden.value, isFalse);
    expect(find.text('tap source'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('C18: tap_zoom anchors at the tapped point', (tester) async {
    final loader = _Loader({
      'home': () async => _source(),
      'detail': () async => _screen('detail', transition: {'type': 'tap_zoom'}),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final router = await _pump(tester);
    final point = tester.getCenter(find.text('tap source'));
    await tester.tap(find.text('tap source'));
    router.push('/screens/detail');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final scope = _originScope(tester);
    expect(scope.point, point);
    expect(scope.source, isNull);
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final type in ['container_transform', 'tap_zoom']) {
    for (final how in ['programmatic', 'stale', 'other_navigator']) {
      testWidgets('C19: $type falls back without a fresh origin how=$how', (
        tester,
      ) async {
        final loader = _Loader({
          'home': () async => _source(),
          'detail': () async => _screen('detail', transition: {'type': type}),
        });
        await _init(loader, preload: ['detail'], type: 'none');
        final router = await _pump(
          tester,
          routes: [
            ShellRoute(builder: (_, _, child) => child, routes: [_appRoute()]),
          ],
        );
        if (how != 'programmatic') {
          await tester.tap(find.text('tap source'));
        }
        if (how == 'stale') {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 1050)),
          );
        }
        router.push(
          how == 'other_navigator' ? '/app/detail' : '/screens/detail',
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        final scope = _originScope(tester);
        expect(scope.source, isNull);
        expect(scope.point, isNull);
        expect(find.byType(RawImage), findsNothing);
        // A fresh Navigator shows its first page without a transition.
        if (type == 'container_transform' && how != 'other_navigator') {
          expect(
            _fade(tester, 'detail')!.opacity.value,
            inExclusiveRange(0, 1),
          );
        }
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('tap source'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final enabled in [true, false]) {
    for (final method in ['pop', 'go', 'replace']) {
      testWidgets('C21: engine push settles on $method enabled=$enabled', (
        tester,
      ) async {
        await _init(_Loader(), preload: ['detail'], enabled: enabled);
        final router = await _pump(tester);
        Object? result = 'pending';
        var done = false;
        goRouterNavigateHandle(router).push!('/screens/detail').then((value) {
          done = true;
          result = value;
        });
        await tester.pumpAndSettle();
        final match =
            router.routerDelegate.currentConfiguration.matches.last
                as ImperativeRouteMatch;
        expect(match.matches.extra, isNull);
        expect(done, isFalse);
        switch (method) {
          case 'pop':
            router.pop('picked');
          case 'go':
            router.go('/screens/mission');
          case 'replace':
            router.pushReplacement('/screens/mission');
        }
        await tester.pumpAndSettle();
        expect(done, isTrue);
        expect(result, method == 'pop' ? 'picked' : isNull);
      });
    }
  }

  testWidgets('C21: the same location pushed twice settles only the top', (
    tester,
  ) async {
    await _init(_Loader(), preload: ['detail']);
    final router = await _pump(tester);
    final handle = goRouterNavigateHandle(router);
    final results = <String, Object?>{};
    handle.push!('/screens/detail').then((v) => results['lower'] = v);
    await tester.pumpAndSettle();
    handle.push!('/screens/detail').then((v) => results['upper'] = v);
    await tester.pumpAndSettle();
    router.pop('upper');
    await tester.pumpAndSettle();
    expect(results, {'upper': 'upper'});
    router.pop('lower');
    await tester.pumpAndSettle();
    expect(results, {'upper': 'upper', 'lower': 'lower'});
  });

  testWidgets('C25: content and decision come from one cache snapshot', (
    tester,
  ) async {
    var version = 1;
    final loader = _Loader({
      'detail': () async => version == 1
          ? _screen('detail-v1', transition: {'type': 'fade', 'duration': 300})
          : _screen(
              'detail-v2',
              transition: {'type': 'slide', 'duration': 500},
            ),
    });
    await _init(loader, preload: ['detail'], type: 'none');
    final mounted = ValueNotifier(false);
    addTearDown(mounted.dispose);
    final router = await _pump(
      tester,
      routes: [
        GoRoute(
          path: '/deferred/:screenId',
          pageBuilder: (context, state) => Sdui.page(
            context,
            state,
            screenId: state.pathParameters['screenId']!,
            child: ValueListenableBuilder(
              valueListenable: mounted,
              builder: (_, value, _) => value
                  ? SduiScreenPage(
                      screenId: state.pathParameters['screenId']!,
                      loader: loader,
                    )
                  : const Text('waiting'),
            ),
          ),
        ),
      ],
    );
    router.push('/deferred/detail');
    await tester.pumpAndSettle();
    version = 2;
    await SduiState.cache.refresh('detail', loader);
    mounted.value = true;
    await tester.pumpAndSettle();
    expect(find.text('detail-v1'), findsOneWidget);
    expect(
      _route(tester, 'detail-v1').transitionDuration,
      const Duration(milliseconds: 300),
    );
    mounted.value = false;
    await tester.pumpAndSettle();
    mounted.value = true;
    await tester.pumpAndSettle();
    expect(find.text('detail-v1'), findsOneWidget);
    expect(find.text('detail-v2'), findsNothing);
  });

  test(
    'C5: a failed refresh keeps the cached entry and is reported once',
    () async {
      final errors = _Errors();
      var fail = false;
      final loader = _Loader({
        'detail': () => fail
            ? Future<LoadedScreen>.error(StateError('offline'))
            : Future.value(_screen('detail-v1')),
      });
      await _init(loader, preload: ['detail'], errors: errors);
      final before = SduiState.cache.peek('detail');
      fail = true;
      await SduiState.cache.refresh('detail', loader);
      expect(identical(SduiState.cache.peek('detail'), before), isTrue);
      expect(
        SduiState.cache.peek('detail')!.screen.template['value'],
        'detail-v1',
      );
      expect(errors.errors.map((e) => (e.scope, e.screenId)), [
        (SduiErrorScope.screenLoad, 'detail'),
      ]);
    },
  );

  test('C5: concurrent refreshes of one id share a single load', () async {
    var version = 1;
    Completer<LoadedScreen>? pending;
    final loader = _Loader({
      'detail': () {
        if (version == 1) return Future.value(_screen('detail-v1'));
        return (pending = Completer<LoadedScreen>()).future;
      },
    });
    await _init(loader, preload: ['detail']);
    version = 2;
    var done = 0;
    final first = SduiState.cache.refresh('detail', loader).then((_) => done++);
    final second = SduiState.cache
        .refresh('detail', loader)
        .then((_) => done++);
    expect(loader.calls, ['detail', 'detail']);
    expect(done, 0);
    pending!.complete(_screen('detail-v2'));
    await Future.wait([first, second]);
    expect(done, 2);
    expect(loader.calls, ['detail', 'detail']);
    expect(
      SduiState.cache.peek('detail')!.screen.template['value'],
      'detail-v2',
    );
  });

  for (final cached in [false, true]) {
    testWidgets(
      'C26: go between screens of one app route remounts the page cached=$cached',
      (tester) async {
        final sink = _Sink();
        final loader = _Loader();
        await _init(
          loader,
          preload: cached ? ['detail', 'mission'] : [],
          type: 'fade',
          telemetry: sink,
        );
        // The documented app route: one page key per path pattern for `go`,
        // and an unkeyed SduiScreenPage.
        final router = await _pump(
          tester,
          routes: [
            GoRoute(
              path: '/:screenId',
              pageBuilder: (context, state) => Sdui.page(
                context,
                state,
                screenId: state.pathParameters['screenId']!,
                child: SduiScreenPage(
                  screenId: state.pathParameters['screenId']!,
                  loader: Sdui.screenLoader,
                ),
              ),
            ),
          ],
        );
        router.go('/detail');
        await tester.pumpAndSettle();
        expect(find.text('detail'), findsOneWidget);
        router.go('/mission');
        await tester.pumpAndSettle();
        expect(find.text('mission'), findsOneWidget);
        expect(find.text('detail'), findsNothing);
        expect(sink.views, ['home', 'detail', 'mission']);
      },
    );
  }

  testWidgets(
    'C22: engine push lands immediately without waiting on the load',
    (tester) async {
      final never = Completer<LoadedScreen>();
      final loader = _Loader({
        'home': () async => _link('/screens/detail'),
        'detail': () => never.future,
      });
      await _init(loader, type: 'fade');
      final router = await _pump(tester);
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      expect(router.canPop(), isTrue);
      expect(find.text('loading'), findsOneWidget);
    },
  );
}
