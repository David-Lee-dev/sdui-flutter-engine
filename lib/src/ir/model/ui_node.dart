/// Represents an immutable UI node parsed from a server template.
///
/// Structural keys are consumed by the parser. Remaining bare keys become
/// [props], while underscore-prefixed keys become [reserved] for the compiler
/// to interpret. This lexical split keeps the parser independent of widget and
/// marker catalogs.
final class UiNode {
  const UiNode({
    required this.type,
    this.props = const {},
    this.reserved = const {},
    this.children = const [],
    this.slots = const {},
    this.key,
    this.path = '',
  });

  /// The catalog type used to select the widget builder.
  final String type;

  /// Contains the bare-key widget properties local to this node.
  final Map<String, Object?> props;

  /// Contains non-structural, underscore-prefixed keys for the compiler.
  final Map<String, Object?> reserved;

  /// Contains positional children and is mutually exclusive with [slots].
  final List<UiNode> children;

  /// Contains named children for widgets whose child positions have distinct roles.
  ///
  /// Slots are mutually exclusive with [children].
  final Map<String, UiNode> slots;

  /// The stable reconciliation key supplied by the template, if any.
  final String? key;

  /// The node's tree path for diagnostics.
  final String path;
}
