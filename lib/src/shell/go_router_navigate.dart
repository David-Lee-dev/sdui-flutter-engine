import 'dart:async';

import 'package:go_router/go_router.dart';

import '../runtime/engine_host.dart';
import '../contract/screen_loader.dart';
import '../runtime/engine_presentation.dart';
import '../ir/model/page_transition.dart';
import 'transition_preload.dart';

/// Adapts [router] to the engine's [NavigateHandle] contract.
///
/// go_router completes a push only when that page is popped. A `go` or
/// `replace` that drops the page, or a later navigation that overtakes a push
/// still being parsed, leaves it pending forever — and the action that pushed
/// would stay in flight, deduplicating every later tap. `push` here settles in
/// each of those cases: with the pop result, otherwise with `null`.
///
/// `pop` is guarded so the root screen ignores an unpoppable back.
NavigateHandle goRouterNavigateHandle(
  GoRouter router, {
  ScreenLoader? loader,
}) => NavigateHandle(
  push: (location) => EnginePresentation.value.transitions.enabled
      ? _navigateWithPreload(router, location, loader)
      : _pushUntilGone(router, location),
  go: (location) {
    if (!EnginePresentation.value.transitions.enabled) {
      router.go(location);
      return;
    }
    unawaited(
      _navigateWithPreload(router, location, loader, replaceStack: true),
    );
  },
  pop: ([result]) {
    if (router.canPop()) router.pop(result);
  },
);

Future<Object?> _navigateWithPreload(
  GoRouter router,
  String location,
  ScreenLoader? loader, {
  bool replaceStack = false,
}) async {
  final style = EnginePresentation.value.transitions;
  final uri = Uri.tryParse(location);
  final store = TransitionPreloads.of(router);
  if (!style.enabled ||
      loader == null ||
      uri == null ||
      store == null ||
      !store.owns(router, uri)) {
    if (replaceStack) {
      router.go(location);
      return null;
    }
    return _pushUntilGone(router, location);
  }

  store.abandon?.call();
  final abandoned = Completer<void>();
  void abandon() {
    if (!abandoned.isCompleted) abandoned.complete();
  }

  store.abandon = abandon;
  final provider = router.routeInformationProvider;
  final delegate = router.routerDelegate;
  final navigation = provider.value;
  final configuration = delegate.currentConfiguration;
  provider.addListener(abandon);
  delegate.addListener(abandon);
  late final Future<LoadedScreen> future;
  try {
    future = loader.load(uri.pathSegments.last);
  } catch (error, stack) {
    future = Future<LoadedScreen>.error(error, stack);
  }
  LoadedScreen? loaded;
  // Handle errors immediately, including errors arriving after a timeout or
  // abandonment. The page reports the failure when it adopts this same future.
  final completed = future.then<void>(
    (value) => loaded = value,
    onError: (Object error, StackTrace stack) {},
  );
  final timeout = Completer<void>();
  final timer = Timer(style.preloadTimeout, timeout.complete);
  try {
    await Future.any([completed, timeout.future, abandoned.future]);
  } finally {
    timer.cancel();
    provider.removeListener(abandon);
    delegate.removeListener(abandon);
    if (identical(store.abandon, abandon)) store.abandon = null;
  }
  if (abandoned.isCompleted) return null;

  PageTransitionSpec? spec;
  Future<LoadedScreen> screen = future;
  final value = loaded;
  if (value != null) {
    final decoded = decodePreloadedScreen(value, uri.pathSegments.last);
    spec = decoded.transition;
    screen = CompletedScreen(decoded.screen);
  }
  if (!identical(provider.value, navigation) ||
      !identical(delegate.currentConfiguration, configuration)) {
    return null;
  }
  final token = store.put(
    TransitionPreload(
      location: uri,
      screen: screen,
      transition: spec ?? PageTransitionSpec(type: style.defaultType),
    ),
  );
  if (replaceStack) {
    router.go(location, extra: token);
    return null;
  }
  try {
    return await _pushUntilGone(router, location, extra: token);
  } finally {
    store.remove(token);
  }
}

Future<Object?> _pushUntilGone(
  GoRouter router,
  String location, {
  Object? extra,
}) {
  final pushed = router.push<Object?>(location, extra: extra);
  // `push` hands the provider a state carrying this push's completer
  // synchronously, and the pushed page's match carries that same completer —
  // which tells this page apart from another push of the same location.
  final provider = router.routeInformationProvider;
  final state = provider.value.state;
  final completer = state is RouteInformationState<Object?>
      ? state.completer
      : null;
  assert(
    completer != null,
    'go_router no longer exposes the push completer; '
    'a push dropped without a pop would never settle.',
  );
  if (completer == null) return pushed;

  final delegate = router.routerDelegate;
  final settled = Completer<Object?>();
  var landed = false;

  void settleDropped() {
    // A pop completes go_router's completer before the page leaves the stack;
    // its result is then already on the way through `pushed`.
    if (!completer.isCompleted && !settled.isCompleted) settled.complete(null);
  }

  void onStackChanged() {
    if (_holdsPush(delegate.currentConfiguration.matches, completer)) {
      landed = true;
    } else if (landed) {
      settleDropped();
    }
  }

  void onNavigation() {
    // The Router drops a parse still in flight when a newer navigation
    // arrives, so a push that has not landed by then never will.
    if (!landed && !identical(provider.value.state, state)) settleDropped();
  }

  delegate.addListener(onStackChanged);
  provider.addListener(onNavigation);
  // Without an async redirect the push lands before `push` returns, with no
  // later notification.
  onStackChanged();
  pushed.then(
    (value) {
      if (!settled.isCompleted) settled.complete(value);
    },
    onError: (Object error, StackTrace stack) {
      if (!settled.isCompleted) settled.completeError(error, stack);
    },
  );
  return settled.future.whenComplete(() {
    delegate.removeListener(onStackChanged);
    provider.removeListener(onNavigation);
  });
}

/// Whether [matches] holds the page pushed with [completer]. A push into a
/// shell lands inside that [ShellRouteMatch], so shells are searched too.
bool _holdsPush(List<RouteMatchBase> matches, Completer<Object?> completer) =>
    matches.any(
      (match) => switch (match) {
        ImperativeRouteMatch() => identical(match.completer, completer),
        ShellRouteMatch() => _holdsPush(match.matches, completer),
        _ => false,
      },
    );
