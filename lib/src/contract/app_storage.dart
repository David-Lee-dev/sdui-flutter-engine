/// Defines the storage operations required by the engine.
abstract class AppStorage {
  Object? get(String key);
  Future<void> set(String key, Object? value);
}
