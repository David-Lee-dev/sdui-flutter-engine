import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/dependency/secure_storage.dart';
import 'package:sdui_engine/src/runtime/driver/secure_storage_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _FakeSecureStorage implements SecureStorage {
  _FakeSecureStorage([Map<String, String>? initial]) : data = {...?initial};

  final Map<String, String> data;

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

DriverContext _ctx(Map<String, Object?> params, {bool cancelled = false}) =>
    DriverContext(
      params: params,
      state: _NoState(),
      isCancelled: () => cancelled,
    );

void main() {
  group('SecureStorageDriver', () {
    late _FakeSecureStorage store;
    late SecureStorageDriver driver;

    setUp(() {
      store = _FakeSecureStorage({'token': 'secret'});
      driver = SecureStorageDriver(store: store);
    });

    test('reads a stored value', () async {
      expect(
        await driver.run(_ctx({'method': 'read', 'key': 'token'})),
        'secret',
      );
    });

    test('writes and returns the input value', () async {
      final result = await driver.run(
        _ctx({'method': 'write', 'key': 'token', 'value': 42}),
      );

      expect(store.data['token'], '42');
      expect(result, 42);
    });

    test('deletes a stored value', () async {
      expect(
        await driver.run(_ctx({'method': 'delete', 'key': 'token'})),
        isNull,
      );
      expect(store.data.containsKey('token'), isFalse);
    });

    test('empty key throws', () async {
      await expectLater(
        driver.run(_ctx({'method': 'read', 'key': ''})),
        throwsArgumentError,
      );
    });

    test('unknown method throws', () async {
      await expectLater(
        driver.run(_ctx({'method': 'frobnicate', 'key': 'token'})),
        throwsArgumentError,
      );
    });
  });
}
