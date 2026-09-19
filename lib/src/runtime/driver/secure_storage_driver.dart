import 'package:sdui_engine/src/contract/secure_storage.dart';

import '_base.dart';

class _UnconfiguredSecureStorage implements SecureStorage {
  const _UnconfiguredSecureStorage();

  @override
  Future<String?> read(String key) => throw StateError(
    'SecureStorage not configured — register SecureStorageDriver(store: …) at app boot.',
  );

  @override
  Future<void> write(String key, String value) => throw StateError(
    'SecureStorage not configured — register SecureStorageDriver(store: …) at app boot.',
  );

  @override
  Future<void> delete(String key) => throw StateError(
    'SecureStorage not configured — register SecureStorageDriver(store: …) at app boot.',
  );
}

/// Reads, writes, or deletes a value in secure storage.
class SecureStorageDriver extends Driver {
  const SecureStorageDriver({
    SecureStorage store = const _UnconfiguredSecureStorage(),
  }) : _store = store;

  final SecureStorage _store;

  @override
  String get type => 'secure_storage';

  @override
  Future<Object?> run(DriverContext ctx) async {
    final key = ctx.params['key'];
    if (key is! String || key.isEmpty) {
      throw ArgumentError.value(
        ctx.params['key'],
        'key',
        'secure_storage requires a non-empty "key"',
      );
    }
    final method = ctx.params['method'] ?? 'read';
    switch (method) {
      case 'read':
        return _store.read(key);
      case 'write':
        final value = ctx.params['value'];
        if (ctx.isCancelled) return value;
        await _store.write(key, value.toString());
        return value;
      case 'delete':
        if (ctx.isCancelled) return null;
        await _store.delete(key);
        return null;
      default:
        throw ArgumentError.value(
          method,
          'method',
          'unknown secure_storage method',
        );
    }
  }
}
