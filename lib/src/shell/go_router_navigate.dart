import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../runtime/engine_host.dart';
import 'page_liveness.dart';

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
    // The active stack is checked by completer, not by key: `replace` gives
    // its page the displaced page's key, and that must still settle this push.
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
