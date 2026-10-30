import 'package:flutter/foundation.dart';

/// Defines one lexical layer used to resolve and observe template bindings.
///
/// Lookup methods inspect only this layer; expression evaluation follows [parent].
abstract class Environment {
  const Environment();

  Environment? get parent;

  bool has(String name);

  Object? read(String name);

  Listenable? listen(Set<String> keys);

  static int _pendingKeys = 0;

  /// How many keys pend across every live layer; while it is zero nothing
  /// waits on an automatic skeleton and pending checks return at once.
  static int get pendingKeys => _pendingKeys;

  /// Adjusts [pendingKeys] as a layer's keys start or stop pending.
  static void countPending(int delta) => _pendingKeys += delta;

  /// Whether this layer's [name] still waits on an automatic skeleton.
  PendState pendingOf(String name) => PendState.none;

  /// Whether any of [roots], each resolved at the first layer of the chain
  /// that declares it, still waits on an automatic skeleton.
  PendState pendState(Set<String> roots) {
    for (final root in roots) {
      for (Environment? env = this; env != null; env = env.parent) {
        if (!env.has(root)) continue;
        if (env.pendingOf(root) == PendState.pending) return PendState.pending;
        break;
      }
    }
    return PendState.none;
  }
}

/// How a state key relates to an automatic skeleton: never awaited, awaited
/// until its first write, or released (it never waits again).
enum PendState { none, pending, settled }
