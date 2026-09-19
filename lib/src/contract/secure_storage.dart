/// A secure key-value store (e.g. Keychain / encrypted store) the app injects
/// for the `secure_storage` driver. Reads are async because the platform store
/// is (unlike the in-memory app store).
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
