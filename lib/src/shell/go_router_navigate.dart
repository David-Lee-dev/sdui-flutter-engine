import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../runtime/engine_host.dart';

/// Adapts [router] to the engine's [NavigateHandle] contract.
///
/// go_router completes a push only when that page is popped. A `go` or
/// `replace` that drops the page, or a later navigation that overtakes a push
/// still being parsed, leaves it pending forever — and the action that pushed
/// would stay in flight, deduplicating every later tap. `push` here settles in
/// each of those cases: with the pop result, otherwise with `null`.
///
/// `pop` is guarded so the root screen ignores an unpoppable back.
NavigateHandle goRouterNavigateHandle(GoRouter router) => NavigateHandle(
  push: (location) => _pushUntilGone(router, location),
  go: router.go,
  pop: ([result]) {
    if (router.canPop()) router.pop(result);
  },
);

Future<Object?> _pushUntilGone(GoRouter router, String location) {
  final pushed = router.push<Object?>(location);
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
  LocalKey? landedKey;

  void settleDropped() {
    // A pop completes go_router's completer before the page leaves the stack;
    // its result is then already on the way through `pushed`.
    if (!completer.isCompleted && !settled.isCompleted) settled.complete(null);
  }

  void onStackChanged() {
    final matches = delegate.currentConfiguration.matches;
    final match = _findPush(matches, completer);
    if (match != null) {
      landedKey = match.pageKey;
    } else if (landedKey != null &&
        !retainedPageKeys(matches).contains(landedKey)) {
      settleDropped();
    }
  }

  void onNavigation() {
    // The Router drops a parse still in flight when a newer navigation
    // arrives, so a push that has not landed by then never will.
    if (landedKey == null && !identical(provider.value.state, state)) {
      settleDropped();
    }
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

/// The match of the page pushed with [completer]. A push into a shell lands
/// inside that [ShellRouteMatch], so shells are searched too.
ImperativeRouteMatch? _findPush(
  List<RouteMatchBase> matches,
  Completer<Object?> completer,
) {
  for (final match in matches) {
    if (match is ImperativeRouteMatch &&
        identical(match.completer, completer)) {
      return match;
    }
    if (match is ShellRouteMatch) {
      final found = _findPush(match.matches, completer);
      if (found != null) return found;
    }
  }
  return null;
}

/// Page keys held by the navigators of inactive stateful branches (and of
/// shells nested in them), which keep their pages outside the active
/// configuration. Active branches are excluded: they are the configuration.
///
/// Pages are matched by `match.pageKey`, so a page whose app `pageBuilder`
/// sets its own key is never seen as retained.
Set<LocalKey> retainedPageKeys(List<RouteMatchBase> matches) {
  final keys = <LocalKey>{};
  void addPages(GlobalKey<NavigatorState> navigatorKey) {
    final pages = navigatorKey.currentState?.widget.pages ?? const <Page>[];
    for (final page in pages) {
      if (page.key case final key?) keys.add(key);
    }
  }

  void addNested(List<RouteBase> routes) {
    for (final route in routes) {
      if (route is ShellRoute) addPages(route.navigatorKey);
      if (route is StatefulShellRoute) {
        for (final branch in route.branches) {
          addPages(branch.navigatorKey);
        }
      }
      addNested(route.routes);
    }
  }

  for (final match in matches) {
    if (match is! ShellRouteMatch) continue;
    final route = match.route;
    if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        if (branch.navigatorKey == match.navigatorKey) continue;
        addPages(branch.navigatorKey);
        addNested(branch.routes);
      }
    }
    keys.addAll(retainedPageKeys(match.matches));
  }
  return keys;
}
