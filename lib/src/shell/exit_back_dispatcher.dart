import 'package:flutter/foundation.dart' show ValueListenable, VoidCallback;
import 'package:flutter/widgets.dart'
    show BackButtonDispatcher, RootBackButtonDispatcher;
import 'package:go_router/go_router.dart';

import '../runtime/exit_back_registry.dart';

/// A [GoRouter] whose root back dispatcher hands an unhandled system back to
/// the visible `exit_back` hooks before Flutter closes the app.
final class ExitBackRouter extends GoRouter {
  ExitBackRouter({
    required String initialLocation,
    required List<RouteBase> routes,
  }) : super.routingConfig(
         routingConfig: _ConstantRoutingConfig(RoutingConfig(routes: routes)),
         initialLocation: initialLocation,
       );

  final BackButtonDispatcher _dispatcher = _ExitBackDispatcher();

  @override
  BackButtonDispatcher get backButtonDispatcher => _dispatcher;
}

/// Runs the normal root flow (child dispatchers, then the router delegate)
/// and fires the `exit_back` hooks only when that flow leaves the back
/// unhandled. With no visible hook the back stays unhandled and Flutter
/// closes the app.
final class _ExitBackDispatcher extends RootBackButtonDispatcher {
  @override
  Future<bool> didPopRoute() async {
    if (await super.didPopRoute()) return true;
    return ExitBackRegistry.fire();
  }
}

/// A routing config that never changes, as go_router builds for its default
/// constructor.
final class _ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const _ConstantRoutingConfig(this.value);

  @override
  final RoutingConfig value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}
