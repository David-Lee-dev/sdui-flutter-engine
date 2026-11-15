import 'dart:async';

import 'package:flutter/foundation.dart';

/// One serialized native queue. Queued calls check disposal before entry;
/// an operation already in flight completes before owner teardown.
final class NativeLane {
  bool disposed = false;
  Future<void> _tail = Future.value();
  Future<void> get drain => _tail;

  Future<T> run<T>(Future<T> Function() call) {
    final next = _tail.then(
      (_) => disposed ? throw const NativeDisposed() : call(),
    );
    _tail = next.then((_) {}, onError: (_) {});
    return next;
  }

  void observe(Future<void> work) {
    unawaited(
      work.then(
        (_) {},
        onError: (Object error) {
          if (error is! NativeDisposed) {
            debugPrint('[sdui_model_filament] $error');
          }
        },
      ),
    );
  }
}

final class NativeDisposed implements Exception {
  const NativeDisposed();
}
