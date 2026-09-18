import 'package:flutter/foundation.dart';

import '../../log/engine_log.dart';
import 'commit_scheduler.dart';
import 'json_value.dart';

/// Stores scope state as atomic snapshots with key-selective notifications.
///
/// The seed fixes the valid key set, preventing misspelled writes from silently
/// extending the scope schema.
final class ScopeStore {
  ScopeStore(Map<String, Object?> initial, {CommitScheduler? scheduler})
    : _snapshot = ScopeSnapshot.fromSeed(initial),
      _scheduler = scheduler ?? const ImmediateCommitScheduler();

  ScopeSnapshot _snapshot;
  final CommitScheduler _scheduler;
  final List<KeySubscription> _subscriptions = [];
  bool _disposed = false;

  ScopeSnapshot get snapshot => _snapshot;

  bool contains(String key) => _snapshot.contains(key);
  Object? read(String key) => _snapshot.read(key);

  KeySubscription subscribe(Set<String> keys) {
    final sub = KeySubscription(keys);
    _subscriptions.add(sub);
    return sub;
  }

  /// Applies [changes] atomically and notifies each affected subscription once.
  ///
  /// Validation precedes publication, so a [StateError] or [ArgumentError] leaves
  /// the previous snapshot intact. Equal values and post-disposal commits are ignored.
  void commit(Map<String, Object?> changes, {bool immediate = false}) {
    if (_disposed || changes.isEmpty) return;
    final applied = <String, Object?>{};
    for (final entry in changes.entries) {
      final key = entry.key;
      if (!_snapshot.contains(key)) {
        EngineLog.state.undeclared(key);
        throw StateError('Undeclared state key "$key".');
      }
      final next = JsonValue.isScalar(entry.value)
          ? entry.value
          : JsonValue.normalize(entry.value);
      if (!JsonValue.structurallyEqual(_snapshot.read(key), next)) {
        applied[key] = next;
      }
    }
    if (applied.isEmpty) return;
    _snapshot = _snapshot.applying(applied);
    EngineLog.state.commit(applied);
    final changed = applied.keys.toSet();
    if (immediate) {
      _deliver(changed);
    } else {
      _scheduler.schedule(changed, _deliver);
    }
  }

  void _deliver(Set<String> changedKeys) {
    if (_disposed) return;
    for (final sub in _subscriptions) {
      sub.deliver(changedKeys);
    }
  }

  void dispose() {
    _disposed = true;
    _scheduler.dispose();
    for (final sub in _subscriptions) {
      sub.dispose();
    }
    _subscriptions.clear();
  }
}

/// Notifies listeners when a commit intersects its dependency keys.
final class KeySubscription extends ChangeNotifier {
  KeySubscription(this.keys);

  final Set<String> keys;

  void deliver(Set<String> changedKeys) {
    if (keys.any(changedKeys.contains)) notifyListeners();
  }
}

/// Holds one immutable, normalized view of a scope's state.
final class ScopeSnapshot {
  const ScopeSnapshot._(this._values);

  final Map<String, Object?> _values;

  factory ScopeSnapshot.fromSeed(Map<String, Object?> seed) =>
      ScopeSnapshot._(JsonValue.normalizeObject(seed));

  Iterable<String> get keys => _values.keys;

  bool contains(String key) => _values.containsKey(key);

  Object? read(String key) => _values[key];

  ScopeSnapshot applying(Map<String, Object?> normalizedChanges) {
    if (normalizedChanges.isEmpty) return this;
    return ScopeSnapshot._(
      Map<String, Object?>.unmodifiable({..._values, ...normalizedChanges}),
    );
  }
}
