import 'package:flutter/foundation.dart';

import '../../log/engine_log.dart';
import '../_base.dart';
import 'commit_scheduler.dart';
import 'json_value.dart';

/// Stores scope state as atomic snapshots with key-selective notifications.
///
/// The seed fixes the valid key set, preventing misspelled writes from silently
/// extending the scope schema.
final class ScopeStore {
  /// With [pendAll], every declared key starts pending (a stand-in frame).
  ScopeStore(
    Map<String, Object?> initial, {
    CommitScheduler? scheduler,
    bool pendAll = false,
  }) : _snapshot = ScopeSnapshot.fromSeed(initial),
       _scheduler = scheduler ?? const ImmediateCommitScheduler() {
    if (!pendAll) return;
    for (final key in _snapshot.keys) {
      _pend[key] = PendState.pending;
    }
    _pendingKeys += _pend.length;
  }

  static int _pendingKeys = 0;

  /// How many keys pend across every live store; while it is zero nothing
  /// waits on an automatic skeleton and pending checks return at once.
  static int get pendingKeys => _pendingKeys;

  ScopeSnapshot _snapshot;
  final CommitScheduler _scheduler;
  final List<KeySubscription> _subscriptions = [];
  final Map<String, PendState> _pend = {};
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
  /// With [release], written keys stop pending (see [pend]) and notify even
  /// when their value is unchanged.
  void commit(
    Map<String, Object?> changes, {
    bool immediate = false,
    bool release = false,
  }) {
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
    final released = release ? _release(changes.keys) : const <String>{};
    if (applied.isEmpty && released.isEmpty) return;
    if (applied.isNotEmpty) {
      _snapshot = _snapshot.applying(applied);
      EngineLog.state.commit(applied);
    }
    final changed = {...applied.keys, ...released};
    if (immediate) {
      _deliver(changed);
    } else {
      _scheduler.schedule(changed, _deliver);
    }
  }

  PendState pendOf(String key) => _pend[key] ?? PendState.none;

  /// Marks declared [keys] as awaited by an automatic skeleton until their
  /// first released commit or [settle]. A released key never pends again.
  void pend(Set<String> keys) {
    if (_disposed) return;
    final marked = {
      for (final key in keys)
        if (_snapshot.contains(key) && pendOf(key) == PendState.none) key,
    };
    if (marked.isEmpty) return;
    for (final key in marked) {
      _pend[key] = PendState.pending;
    }
    _pendingKeys += marked.length;
    _scheduler.schedule(marked, _deliver);
  }

  /// Releases whichever of [keys] still pend, without writing them.
  void settle(Set<String> keys) {
    if (_disposed) return;
    final released = _release(keys);
    if (released.isNotEmpty) _scheduler.schedule(released, _deliver);
  }

  Set<String> _release(Iterable<String> keys) {
    final released = {
      for (final key in keys)
        if (pendOf(key) == PendState.pending) key,
    };
    for (final key in released) {
      _pend[key] = PendState.settled;
    }
    _pendingKeys -= released.length;
    return released;
  }

  void _deliver(Set<String> changedKeys) {
    if (_disposed) return;
    for (final sub in _subscriptions) {
      sub.deliver(changedKeys);
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _release(_pend.keys.toList());
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
