import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contract/screen_loader.dart';
import '../compile/page_transition_decoder.dart';
import '../contract/error_observer.dart';
import '../engine.dart';
import '../runtime/engine_errors.dart';
import '../ir/model/page_transition.dart';
import '../runtime/transition/transition_origin.dart';

/// Validate once, then hand the body to EngineRunner without the already-read
/// route declaration. A late timeout result keeps the route's chosen default.
({LoadedScreen screen, PageTransitionSpec? transition}) decodePreloadedScreen(
  LoadedScreen screen,
  String screenId,
) {
  if (!screen.template.containsKey('_transition')) {
    return (screen: screen, transition: null);
  }
  PageTransitionSpec? transition;
  try {
    transition = PageTransitionDecoder.decode(
      screen.template['_transition'],
      catalog: Engine.catalog ?? Engine.snapshotCatalog(),
    );
  } catch (error, stack) {
    EngineErrors.report(
      SduiError(
        scope: SduiErrorScope.templateCompile,
        error: error,
        stack: stack,
        screenId: screenId,
      ),
    );
  }
  return (
    screen: (
      template: Map<String, Object?>.of(screen.template)..remove('_transition'),
      modals: screen.modals,
    ),
    transition: transition,
  );
}

/// A completed load with a value available before the first build.
final class CompletedScreen extends SynchronousFuture<LoadedScreen> {
  CompletedScreen(this.value) : super(value);

  final LoadedScreen value;
}

final class TransitionPreload {
  const TransitionPreload({
    required this.location,
    required this.screen,
    required this.transition,
    this.origin,
    this.tapPoint,
    this.originNavigator,
  });

  final Uri location;

  final Future<LoadedScreen> screen;
  final PageTransitionSpec transition;
  final TransitionOrigin? origin;
  final Offset? tapPoint;
  final NavigatorState? originNavigator;
}

/// Router-owned tokens move into page-key bindings on first build. Bindings
/// survive pageBuilder rebuilds and live only as long as the corresponding page.
final class TransitionPreloads {
  static final _routers = Expando<TransitionPreloads>();
  static var _next = 0;

  static TransitionPreloads? of(GoRouter router) => _routers[router];

  void attach(GoRouter router, GoRoute route) {
    _routers[router] = this;
    _route = route;
    router.routerDelegate.addListener(() {
      final keys = <LocalKey>{};
      final tokens = <Object?>{};
      void collect(RouteMatchList list) {
        tokens.add(list.extra);
        void walk(List<RouteMatchBase> matches) {
          for (final match in matches) {
            keys.add(match.pageKey);
            if (match is ImperativeRouteMatch) collect(match.matches);
            if (match is ShellRouteMatch) walk(match.matches);
          }
        }

        walk(list.matches);
      }

      collect(router.routerDelegate.currentConfiguration);
      _entries.removeWhere((token, preload) {
        if (tokens.contains(token)) return false;
        preload.origin?.dispose();
        return true;
      });
      _pages.removeWhere((page, _) => !keys.contains(page.key));
    });
  }

  late GoRoute _route;
  final _entries = <String, TransitionPreload>{};
  final _pages =
      <
        ({LocalKey key, Uri uri}),
        ({String token, TransitionPreload preload})
      >{};
  VoidCallback? abandon;

  bool owns(GoRouter router, Uri uri) {
    final matches = router.configuration.findMatch(uri).matches;
    return matches.isNotEmpty && identical(matches.last.route, _route);
  }

  String put(TransitionPreload preload) {
    final token = 'sdui-transition-${_next++}';
    _entries[token] = preload;
    return token;
  }

  TransitionPreload? bind(Object? token, LocalKey key, Uri uri) {
    final page = (key: key, uri: uri);
    final bound = _pages[page];
    if (token is! String) return null;
    if (bound != null && bound.token == token) return bound.preload;
    final preload = _entries.remove(token);
    if (preload == null || preload.location != uri) return null;
    _pages[page] = (token: token, preload: preload);
    return preload;
  }

  void remove(String token) {
    _entries.remove(token)?.origin?.dispose();
  }

  void release(LocalKey key, Uri uri, TransitionPreload preload) {
    final page = (key: key, uri: uri);
    if (identical(_pages[page]?.preload, preload)) _pages.remove(page);
  }
}

/// Cleans up go navigations too, which have no push result to await.
final class PreloadedPage extends StatefulWidget {
  const PreloadedPage({
    super.key,
    required this.store,
    required this.pageKey,
    required this.uri,
    required this.preload,
    required this.child,
  });

  final TransitionPreloads store;
  final LocalKey pageKey;
  final Uri uri;
  final TransitionPreload preload;
  final Widget child;

  @override
  State<PreloadedPage> createState() => _PreloadedPageState();
}

final class _PreloadedPageState extends State<PreloadedPage> {
  @override
  void dispose() {
    widget.store.release(widget.pageKey, widget.uri, widget.preload);
    widget.preload.origin?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
