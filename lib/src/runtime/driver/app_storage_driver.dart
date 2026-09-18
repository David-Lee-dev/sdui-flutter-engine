import 'package:sdui_engine/src/dependency/app_storage.dart';

import '_base.dart';

class _UnconfiguredAppStorage implements AppStorage {
  const _UnconfiguredAppStorage();

  @override
  Object? get(String key) => throw StateError(
    'AppStorage not configured — register AppStorageDriver(store: …) at app boot.',
  );

  @override
  Future<void> set(String key, Object? value) => throw StateError(
    'AppStorage not configured — register AppStorageDriver(store: …) at app boot.',
  );
}

/// Reads or writes a value in application storage.
///
/// `stamp`/`due` add a throttling primitive on top of plain get/set: a
/// template can record "I last showed this" and later ask "has enough
/// calendar time passed to show it again" without doing date arithmetic
/// itself.
class AppStorageDriver extends Driver {
  const AppStorageDriver({
    AppStorage store = const _UnconfiguredAppStorage(),
    DateTime Function() now = DateTime.now,
  }) : _store = store,
       _now = now;

  final AppStorage _store;

  /// Injectable clock — overridden in tests, defaults to the real wall clock.
  final DateTime Function() _now;

  @override
  String get type => 'app_storage';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final key = ctx.params['key'];
    if (key is! String || key.isEmpty) {
      throw ArgumentError.value(
        ctx.params['key'],
        'key',
        'app_storage requires a non-empty "key"',
      );
    }
    final method = ctx.params['method'] ?? 'set';
    switch (method) {
      case 'get':
        return _store.get(key);
      case 'set':
        final value = ctx.params['value'];
        if (ctx.isCancelled) return value;
        await _store.set(key, value);
        return value;
      case 'stamp':
        final stamp = _now().millisecondsSinceEpoch;
        if (ctx.isCancelled) return stamp;
        await _store.set(key, stamp);
        return stamp;
      case 'due':
        return _due(ctx, key);
      default:
        throw ArgumentError.value(
          method,
          'method',
          'unknown app_storage method',
        );
    }
  }

  /// Reports whether at least [days] calendar days have passed since `key`
  /// was last `stamp`ed.
  ///
  /// Compares local calendar dates rather than elapsed duration: a stamp at
  /// 23:50 must be due again at 00:10 the next day, matching the v2
  /// "daily/weekly popup" semantics templates already rely on. Fails open
  /// (returns true) when the key was never stamped or holds something other
  /// than an int — a corrupt or missing value should let the popup show
  /// again rather than silently suppress it forever. A stamp that lands in
  /// the future (device clock moved backwards) is treated the same way, so
  /// a clock rollback can't lock the user out permanently.
  bool _due(DriverContext ctx, String key) {
    final daysParam = ctx.params['days'] ?? 1;
    if (daysParam is! int || daysParam < 0) {
      throw ArgumentError.value(
        daysParam,
        'days',
        'app_storage due requires a non-negative int "days"',
      );
    }

    final stored = _store.get(key);
    if (stored is! int) return true;

    final stamped = DateTime.fromMillisecondsSinceEpoch(stored);
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final stampedDay = DateTime(stamped.year, stamped.month, stamped.day);
    if (stampedDay.isAfter(today)) return true;

    return today.difference(stampedDay).inDays >= daysParam;
  }
}
