import 'package:sdui_engine/src/ir/model/layout_protocol.dart';

/// The structural kind of a widget, mirroring the WidgetSpec sealed subtypes.
///
/// Lets the validator reason about child shape and binding without the runtime
/// specification.
enum WidgetKind { eager, slot, builder, bound, action }

/// Compile-time widget metadata required by template validation.
class WidgetSchema {
  const WidgetSchema({
    required this.kind,
    this.produces = LayoutProtocol.box,
    this.childProtocol = LayoutProtocol.box,
  });

  final WidgetKind kind;
  final LayoutProtocol produces;
  final LayoutProtocol? childProtocol;
}

/// Stores process-wide widget schemas populated by the runtime widget factory.
final class WidgetSchemaRegistry {
  const WidgetSchemaRegistry._();

  static final Map<String, WidgetSchema> _schemas = {};
  static bool _frozen = false;

  /// Returns whether [type] has a registered schema.
  static bool knows(String type) => _schemas.containsKey(type);

  /// Returns the schema registered for [type], if any.
  static WidgetSchema? schemaFor(String type) => _schemas[type];

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
    _schemas.clear();
  }
}
