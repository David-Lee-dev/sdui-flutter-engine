import '_base.dart';

/// Delegates route commands to the navigation capability of the current engine host.
class NavigateDriver extends Driver {
  const NavigateDriver();

  @override
  String get type => 'navigate';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final navigate = ctx.host?.navigate;
    switch (ctx.params['method'] ?? 'push') {
      case 'push':
        return navigate?.push?.call(_route(ctx));
      case 'go':
        navigate?.go?.call(_route(ctx));
        return null;
      case 'pop':
        navigate?.pop?.call(ctx.params['result']);
        return null;
      default:
        throw ArgumentError.value(
          ctx.params['method'],
          'method',
          'unknown navigate method',
        );
    }
  }

  static String _route(DriverContext ctx) {
    final route = ctx.params['route'];
    if (route is! String || route.isEmpty) {
      throw ArgumentError.value(
        route,
        'route',
        'navigate push/go requires a non-empty "route"',
      );
    }
    return route;
  }
}
