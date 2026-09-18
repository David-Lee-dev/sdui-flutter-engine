/// Enforces immutable JSON value semantics at the state boundary.
final class JsonValue {
  const JsonValue._();

  static bool isScalar(Object? value) =>
      value == null ||
      value is bool ||
      value is String ||
      value is int ||
      (value is double && value.isFinite);

  /// Returns an immutable, deeply copied JSON representation of [input].
  ///
  /// Cycles, invalid keys, non-finite numbers, unsupported objects, and excessive
  /// nesting cause an [ArgumentError]. Shared acyclic input remains valid.
  static Object? normalize(Object? input) =>
      _normalize(input, _identityPath(), 0);

  static Set<Object> _identityPath() => Set<Object>.identity();

  static const _maxDepth = 256;

  static Object? _normalize(Object? input, Set<Object> path, int depth) {
    if (input == null || input is bool || input is String || input is int) {
      return input;
    }
    if (input is double) {
      if (!input.isFinite) {
        throw ArgumentError.value(
          input,
          'input',
          'non-finite number is not JSON',
        );
      }
      return input;
    }
    if (input is Map || input is List) {
      if (depth > _maxDepth) {
        throw ArgumentError.value(
          input,
          'input',
          'JSON nesting too deep (>$_maxDepth)',
        );
      }
      if (!path.add(input)) {
        throw ArgumentError.value(
          input,
          'input',
          'cyclic reference is not JSON',
        );
      }
      final Object result;
      if (input is Map) {
        result = Map<String, Object?>.unmodifiable({
          for (final entry in input.entries)
            _stringKey(entry.key): _normalize(entry.value, path, depth + 1),
        });
      } else {
        result = List<Object?>.unmodifiable([
          for (final element in input as List)
            _normalize(element, path, depth + 1),
        ]);
      }
      path.remove(input);
      return result;
    }
    throw ArgumentError.value(
      input,
      'input',
      'unsupported state value (${input.runtimeType}); JSON only',
    );
  }

  static Map<String, Object?> normalizeObject(Map<String, Object?> input) =>
      Map<String, Object?>.unmodifiable({
        for (final entry in input.entries) entry.key: normalize(entry.value),
      });

  /// Returns whether two JSON-shaped values have equal recursive contents.
  static bool structurallyEqual(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a is Map) {
      if (b is! Map || a.length != b.length) return false;
      for (final entry in a.entries) {
        if (!b.containsKey(entry.key)) return false;
        if (!structurallyEqual(entry.value, b[entry.key])) return false;
      }
      return true;
    }
    if (a is List) {
      if (b is! List || a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!structurallyEqual(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }

  static String _stringKey(Object? key) {
    if (key is String) return key;
    throw ArgumentError.value(key, 'key', 'state map keys must be String');
  }
}
