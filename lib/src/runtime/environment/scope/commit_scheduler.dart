import 'package:flutter/scheduler.dart';

/// Controls when committed keys reach subscribers.
abstract interface class CommitScheduler {
  void schedule(Set<String> changedKeys, void Function(Set<String> keys) flush);

  void dispose();
}

/// Delivers every commit synchronously without coalescing it.
final class ImmediateCommitScheduler implements CommitScheduler {
  const ImmediateCommitScheduler();

  @override
  void schedule(Set<String> changedKeys, void Function(Set<String>) flush) =>
      flush(changedKeys);

  @override
  void dispose() {}
}

/// Defers and coalesces notifications produced during Flutter's build phase.
///
/// Deferral avoids marking an already-built ancestor dirty. Other phases remain
/// synchronous, while build-phase commits are delivered once after the frame.
final class FlutterCommitScheduler implements CommitScheduler {
  final Set<String> _pending = {};
  void Function(Set<String>)? _flush;
  bool _scheduled = false;
  bool _disposed = false;

  @override
  void schedule(Set<String> changedKeys, void Function(Set<String>) flush) {
    if (_disposed) return;
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      _pending.addAll(changedKeys);
      _flush = flush;
      if (_scheduled) return;
      _scheduled = true;
      binding.addPostFrameCallback((_) {
        _scheduled = false;
        if (_disposed) return;
        final keys = Set<String>.of(_pending);
        _pending.clear();
        final flushNow = _flush;
        _flush = null;
        if (keys.isNotEmpty && flushNow != null) flushNow(keys);
      });
    } else {
      flush(changedKeys);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pending.clear();
    _flush = null;
  }
}
