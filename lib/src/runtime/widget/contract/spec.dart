library;

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'action_sink.dart';
import 'child_builder.dart';

/// Describes how the engine builds a widget and validates its layout protocol.
///
/// [produces] identifies the node's own protocol. A null [childProtocol] opts
/// out of uniform child validation for widgets with mixed child roles.
/// [parentData] declares the parent data the widget's output carries
/// (`Expanded` carries [ParentDataKind.flex], `Positioned`
/// [ParentDataKind.stack]); such an output must stay the direct widget of a
/// parent taking that kind: the engine places it in place and wraps nothing
/// around it. The engine cannot see inside an app widget (a replacement of a
/// built-in included), so a template cannot put `_motion`, `_on` or
/// `_skeleton` on an app widget declared so.
///
/// [childParentData] declares the parent data the widget takes on its
/// children: a child carrying another kind is a compile error. A widget
/// that lays its children in a flex or stack declares [ParentDataKind.flex]
/// or [ParentDataKind.stack]; left at none, it takes no `expanded`,
/// `positioned`, ... child.
sealed class WidgetSpec {
  const WidgetSpec({
    this.produces = LayoutProtocol.box,
    this.childProtocol = LayoutProtocol.box,
    this.parentData = ParentDataKind.none,
    this.childParentData = ParentDataKind.none,
  });

  final LayoutProtocol produces;

  final LayoutProtocol? childProtocol;

  final ParentDataKind parentData;

  final ParentDataKind childParentData;
}

/// Builds a widget from resolved props and positional children.
typedef EagerBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      List<Widget> children,
    );

/// Describes a widget built from an already-built positional child list.
final class EagerSpec extends WidgetSpec {
  const EagerSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.parentData,
    super.childParentData,
  });

  final EagerBuild build;
}

/// Builds a widget from resolved props and named child slots.
typedef SlotBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      Map<String, Widget> slots,
    );

/// Describes a widget built from already-built children addressed by slot name.
final class SlotSpec extends WidgetSpec {
  const SlotSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.parentData,
    super.childParentData,
  });

  final SlotBuild build;
}

/// Builds a widget that can request scoped children on demand.
typedef BuilderBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      int childCount,
      ChildBuilder buildChild,
    );

/// Describes a widget that requests children lazily through [ChildBuilder].
final class BuilderSpec extends WidgetSpec {
  const BuilderSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.parentData,
    super.childParentData,
  });

  final BuilderBuild build;
}

/// Builds a controlled widget from a live value and input callbacks.
typedef BoundBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      Object? value,
      ValueChanged<Object?>? onChanged,
      ValueChanged<Object?>? onSubmit,
    );

/// Describes a controlled widget supplied with live value and event callbacks.
final class BoundSpec extends WidgetSpec {
  const BoundSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.parentData,
    super.childParentData,
  });

  final BoundBuild build;
}

/// Builds a widget with access to an optional action dispatcher.
typedef ActionBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      List<Widget> children,
      ActionSink? dispatch,
    );

/// Describes a widget that can dispatch its own gesture-driven actions.
final class ActionSpec extends WidgetSpec {
  const ActionSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.parentData,
    super.childParentData,
  });

  final ActionBuild build;
}
