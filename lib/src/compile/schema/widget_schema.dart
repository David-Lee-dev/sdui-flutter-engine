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
    this.parentData = false,
    this.decoratesChild = false,
    this.passesChild = false,
  });

  final WidgetKind kind;
  final LayoutProtocol produces;
  final LayoutProtocol? childProtocol;

  /// Whether the widget's output is parent data, which must stay the direct
  /// widget of its parent.
  final bool parentData;

  /// Whether the engine puts a node's `_motion`, `_on` and repaint boundary
  /// on the child of this parent-data output. Only the engine's own
  /// builders, which return Flutter's parent-data widget itself, do; a
  /// replacement implementation does not.
  final bool decoratesChild;

  /// Whether, with a single child, the widget builds no render object of
  /// its own around that child's parent data and so hands it to its parent.
  /// Only the engine's own `container` does; a replacement implementation
  /// is an ordinary node of its declared kind.
  final bool passesChild;

  /// The parent data this widget's own output is.
  ParentDataOutput get parentDataOutput => !parentData
      ? ParentDataOutput.none
      : decoratesChild
      ? ParentDataOutput.decoratable
      : ParentDataOutput.opaque;
}
