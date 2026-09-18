import 'expression.dart';

/// Traverses values that may contain precompiled expressions.
///
/// Nested values contribute all of their precompiled reactive roots.
final class CompiledValue {
  const CompiledValue._();

  static Set<String> rootsOf(Map<String, Object?> values) {
    final roots = <String>{};
    void walk(Object? value) {
      if (value is Expression) {
        roots.addAll(value.roots);
      } else if (value is Interpolation) {
        roots.addAll(value.roots);
      } else if (value is Map) {
        value.values.forEach(walk);
      } else if (value is List) {
        value.forEach(walk);
      }
    }

    values.values.forEach(walk);
    return roots;
  }
}
