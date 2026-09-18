import 'package:flutter/foundation.dart';

import '../_base.dart';
import '../state_writer.dart';
import 'commit_scheduler.dart';
import 'scope_store.dart';

/// Adapts a reactive [ScopeStore] into an [Environment] chain node.
///
/// Local subscriptions survive reparenting, while combined subscriptions are
/// invalidated so they cannot retain the previous outer scope.
class ScopeEnvironment implements Environment, StateWriter {
  ScopeEnvironment(Map<String, Object?> initial, {CommitScheduler? scheduler})
    : _store = ScopeStore(initial, scheduler: scheduler);

  final ScopeStore _store;

  Environment? _parent;

  final Map<String, Listenable?> _listenCache = {};

  final Map<String, KeySubscription> _localSubs = {};

  @override
  Environment? get parent => _parent;

  set parent(Environment? value) {
    if (identical(_parent, value)) return;
    _parent = value;
    _listenCache.clear();
  }

  Iterable<String> get declaredKeys => _store.snapshot.keys;

  @override
  bool has(String name) => _store.contains(name);

  @override
  Object? read(String name) => _store.read(name);

  @override
  Listenable? listen(Set<String> keys) {
    if (keys.isEmpty) return null;
    return _listenCache.putIfAbsent(
      _cacheKey(keys),
      () => _resolveListen(keys),
    );
  }

  static String _cacheKey(Set<String> keys) =>
      (keys.toList()..sort()).map((k) => '${k.length}:$k').join();

  Listenable? _resolveListen(Set<String> keys) {
    final mine = keys.where(_store.contains).toSet();
    final rest = keys.difference(mine);
    final restListenable = rest.isEmpty ? null : parent?.listen(rest);
    if (mine.isEmpty) return restListenable;
    final localSub = _localSubs.putIfAbsent(
      _cacheKey(mine),
      () => _store.subscribe(mine),
    );
    return restListenable == null
        ? localSub
        : Listenable.merge([localSub, restListenable]);
  }

  void set(String key, Object? value) => _store.commit({key: value});

  @override
  void commit(Map<String, Object?> changes) => _store.commit(changes);

  void syncState(Map<String, Object?> next) =>
      _store.commit(next, immediate: true);

  void dispose() => _store.dispose();
}
