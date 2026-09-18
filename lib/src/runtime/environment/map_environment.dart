import 'package:flutter/foundation.dart';

import '_base.dart';

/// Adds a non-reactive binding frame to an [Environment] chain.
///
/// Callers must not mutate [vars], because local keys deliberately have no notifier.
class MapEnvironment extends Environment {
  const MapEnvironment(this.vars, {this.parent});

  final Map<String, Object?> vars;

  @override
  final Environment? parent;

  static const MapEnvironment empty = MapEnvironment({});

  @override
  bool has(String name) => vars.containsKey(name);

  @override
  Object? read(String name) => vars[name];

  @override
  Listenable? listen(Set<String> keys) {
    final rest = keys.difference(vars.keys.toSet());
    return rest.isEmpty ? null : parent?.listen(rest);
  }
}
