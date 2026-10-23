import 'package:flutter/cupertino.dart' show CupertinoApp, CupertinoPage;
import 'package:flutter/material.dart' show MaterialApp, MaterialPage;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../ir/model/page_transition.dart';
import '../runtime/engine_presentation.dart';
import 'screen_cache.dart';
import 'sdui_state.dart';
import 'sdui_transition_page.dart';

/// Builds the [Page] for an engine screen route.
///
/// The page decision is made on the first build of a page key and frozen
/// for that page, so pageBuilder rebuilds and background cache refreshes
/// never change an open page. The cache entry captured with it (or its
/// absence) is handed to [child] so content and transition stay paired.
/// [child] is remounted whenever the page key's screen id changes.
Page<void> buildScreenPage(
  BuildContext context,
  GoRouterState state, {
  required String screenId,
  required Widget child,
}) {
  final router = GoRouter.maybeOf(context);
  final frozen = router == null ? null : _decisions[router] ??= _Frozen(router);
  var decision = frozen?.byKey[state.pageKey];
  if (decision == null || decision.screenId != screenId) {
    decision = _decide(context, screenId);
    frozen?.byKey[state.pageKey] = decision;
  }

  // go_router keeps one page key per path pattern for `go`, so a new screen
  // id under the same key remounts the subtree to match the new decision.
  final page = ScreenSnapshot(
    key: ValueKey(screenId),
    screenId: screenId,
    screen: decision.screen,
    child: child,
  );
  final spec = decision.spec;
  if (spec == null) return _hostPage(context, state, page);
  return sduiTransitionPage(key: state.pageKey, child: page, spec: spec);
}

final _decisions = Expando<_Frozen>();

/// One router's frozen decisions. A decision lives while its page key is in
/// the router configuration; reopening after it left decides afresh.
final class _Frozen {
  _Frozen(GoRouter router) {
    final delegate = router.routerDelegate;
    delegate.addListener(() => _release(delegate.currentConfiguration));
  }

  final byKey = <LocalKey, _Decision>{};

  void _release(RouteMatchList configuration) {
    final live = <LocalKey>{};
    void walk(List<RouteMatchBase> matches) {
      for (final match in matches) {
        live.add(match.pageKey);
        if (match is ImperativeRouteMatch) walk(match.matches.matches);
        if (match is ShellRouteMatch) walk(match.matches);
      }
    }

    walk(configuration.matches);
    byKey.removeWhere((key, _) => !live.contains(key));
  }
}

final class _Decision {
  const _Decision({
    required this.screenId,
    required this.screen,
    required this.spec,
  });

  final String screenId;

  /// The cache entry captured for this page; `null` is an explicit miss.
  final CachedScreen? screen;

  /// The engine transition to play; `null` keeps the host app's page.
  final PageTransitionSpec? spec;
}

/// With transitions enabled, a cached screen uses its declared `_transition`
/// and anything else the style's `defaultType`; reduced motion forces `none`
/// when respected. `platform` and disabled transitions keep the host page.
_Decision _decide(BuildContext context, String screenId) {
  final screen = SduiState.cache.peek(screenId);
  final style = EnginePresentation.value.transitions;
  if (!style.enabled) {
    return _Decision(screenId: screenId, screen: screen, spec: null);
  }

  final reduced =
      style.respectReducedMotion &&
      MediaQuery.maybeOf(context)?.disableAnimations == true;
  final spec = reduced
      ? PageTransitionSpec(type: 'none')
      : screen?.transition ?? PageTransitionSpec(type: style.defaultType);
  return _Decision(
    screenId: screenId,
    screen: screen,
    spec: spec.type == 'platform' ? null : spec,
  );
}

/// The page go_router would build for the host app type.
Page<void> _hostPage(BuildContext context, GoRouterState state, Widget child) {
  final name = state.name ?? state.path;
  final arguments = <String, String>{
    ...state.pathParameters,
    ...state.uri.queryParameters,
  };
  if (context.findAncestorWidgetOfExactType<MaterialApp>() != null) {
    return MaterialPage<void>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      restorationId: state.pageKey.value,
      child: child,
    );
  }
  if (context.findAncestorWidgetOfExactType<CupertinoApp>() != null) {
    return CupertinoPage<void>(
      key: state.pageKey,
      name: name,
      arguments: arguments,
      restorationId: state.pageKey.value,
      child: child,
    );
  }
  return NoTransitionPage<void>(
    key: state.pageKey,
    name: name,
    arguments: arguments,
    restorationId: state.pageKey.value,
    child: child,
  );
}
