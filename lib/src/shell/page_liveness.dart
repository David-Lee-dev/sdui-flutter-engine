import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Page keys still held by the router: those in [configuration], including
/// pushes and shells nested in it, plus those retained by inactive branches.
Set<LocalKey> livePageKeys(RouteMatchList configuration) {
  final live = <LocalKey>{};
  void walk(List<RouteMatchBase> matches) {
    for (final match in matches) {
      live.add(match.pageKey);
      if (match is ImperativeRouteMatch) walk(match.matches.matches);
      if (match is ShellRouteMatch) walk(match.matches);
    }
  }

  walk(configuration.matches);
  live.addAll(retainedPageKeys(configuration.matches));
  return live;
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
