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
