import 'package:flutter/foundation.dart';

import '../_base.dart';
import '../state_writer.dart';
import 'commit_scheduler.dart';
import 'scope_store.dart';

/// Adapts a reactive [ScopeStore] into an [Environment] chain node.
///
/// Local subscriptions survive reparenting, while combined subscriptions are
/// invalidated so they cannot retain the previous outer scope.
class ScopeEnvironment extends Environment implements StateWriter {
  /// A [placeholder] layer is a stand-in frame (a skeleton loop row) whose
  /// every key starts pending.
  ScopeEnvironment(
    Map<String, Object?> initial, {
    CommitScheduler? scheduler,
    bool placeholder = false,
  }) : _store = ScopeStore(initial, scheduler: scheduler, pendAll: placeholder);

  /// [ScopeStore.pendingKeys]: how many keys pend across every live layer.
  static int get pendingKeys => ScopeStore.pendingKeys;

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

  @override
  PendState pendingOf(String name) => _store.pendOf(name);

  /// A write releases its keys from an automatic skeleton (see [pend]).
  void set(String key, Object? value) =>
      _store.commit({key: value}, release: true);

  @override
  void commit(Map<String, Object?> changes) =>
      _store.commit(changes, release: true);

  /// Reseeds from the template; it is not the awaited write, so pending keys
  /// stay pending.
  void syncState(Map<String, Object?> next) =>
      _store.commit(next, immediate: true);

  /// Marks [keys] as awaited until their first write or [settle].
  void pend(Set<String> keys) => _store.pend(keys);

  void settle(Set<String> keys) => _store.settle(keys);

  void dispose() => _store.dispose();
}
