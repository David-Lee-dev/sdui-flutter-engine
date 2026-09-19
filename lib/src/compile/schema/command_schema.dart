import 'builtin_language.dart';

/// Stores process-wide command types.
///
/// Pre-seeded with [BuiltinLanguage.commands] — compilation needs no runtime
/// to validate built-in commands. The runtime driver registry re-registers
/// builtins (idempotent by parity) and adds app service command types.
final class CommandSchemaRegistry {
  const CommandSchemaRegistry._();

  static final Set<String> _types = {...BuiltinLanguage.commands};
  static bool _frozen = false;

  /// Returns whether [type] is registered.
  static bool knows(String type) => _types.contains(type);

  /// An immutable snapshot of every registered command type.
  static Set<String> all() => Set.unmodifiable(_types);

  /// Registers [type].
  static void register(String type) {
    if (_frozen) {
      throw StateError(
        'CommandSchemaRegistry is frozen — register before freeze().',
      );
    }
    _types.add(type);
  }

  /// Registers each command type in iteration order.
  static void registerAll(Iterable<String> types) {
    for (final type in types) {
      register(type);
    }
  }

  /// Prevents subsequent command type registration.
  static void freeze() => _frozen = true;

  /// Clears every command type and unfreezes the registry.
  static void reset() {
    _frozen = false;
    _types
      ..clear()
      ..addAll(BuiltinLanguage.commands);
  }
}
