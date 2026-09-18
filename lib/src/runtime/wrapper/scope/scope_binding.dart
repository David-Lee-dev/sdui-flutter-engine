import 'package:flutter/widgets.dart';

import '../../environment/_base.dart';
import '../../environment/scope/scope_environment.dart';
import 'scope.dart';

/// Reads, observes, and writes a state key through the nearest declaring scope.
final class ScopeBinding {
  const ScopeBinding._();

  static Object? read(BuildContext context, String key) {
    Environment? env = Scope.envOf(context);
    while (env != null) {
      if (env.has(key)) return env.read(key);
      env = env.parent;
    }
    return null;
  }

  static Listenable? listenable(BuildContext context, String key) =>
      Scope.envOf(context)?.listen({key});

  static void write(BuildContext context, String key, Object? value) {
    Environment? env = Scope.envOf(context);
    while (env != null) {
      if (env is ScopeEnvironment && env.has(key)) {
        env.set(key, value);
        return;
      }
      env = env.parent;
    }
    throw StateError('bind: no scope declares state key "$key".');
  }
}
