import 'builtin_language.dart';
import 'widget_schema.dart';

/// Stores process-wide widget schemas.
///
/// Pre-seeded with [BuiltinLanguage.widgets] — compilation needs no runtime
/// to validate the built-in language. The runtime widget factory re-registers
/// builtins (idempotent by parity) and adds app-custom widget schemas.
final class WidgetSchemaRegistry {
  const WidgetSchemaRegistry._();

  static final Map<String, WidgetSchema> _schemas = {
    ...BuiltinLanguage.widgets,
  };
  static bool _frozen = false;

  /// Returns whether [type] has a registered schema.
  static bool knows(String type) => _schemas.containsKey(type);

  /// Returns the schema registered for [type], if any.
  static WidgetSchema? schemaFor(String type) => _schemas[type];

  /// An immutable snapshot of every registered schema.
  static Map<String, WidgetSchema> all() => Map.unmodifiable(_schemas);

  /// Associates [type] with [schema], replacing an existing entry.
  static void register(String type, WidgetSchema schema) {
    if (_frozen) {
      throw StateError(
        'WidgetSchemaRegistry is frozen — register before freeze().',
      );
    }
    _schemas[type] = schema;
  }

  /// Registers every entry in [schemas] in iteration order.
  static void registerAll(Map<String, WidgetSchema> schemas) {
    for (final entry in schemas.entries) {
      register(entry.key, entry.value);
    }
  }

  /// Prevents subsequent schema registration.
  static void freeze() => _frozen = true;

  /// Clears every schema and unfreezes the registry.
  static void reset() {
    _frozen = false;
    _schemas
      ..clear()
      ..addAll(BuiltinLanguage.widgets);
  }
}
