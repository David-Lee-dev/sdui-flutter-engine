library;

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'action_sink.dart';
import 'child_builder.dart';

/// Describes how the engine builds a widget and validates its layout protocol.
///
/// [produces] identifies the node's own protocol. A null [childProtocol] opts
/// out of uniform child validation for widgets with mixed child roles.
sealed class WidgetSpec {
  const WidgetSpec({
    this.produces = LayoutProtocol.box,
    this.childProtocol = LayoutProtocol.box,
  });

  final LayoutProtocol produces;

  final LayoutProtocol? childProtocol;
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
  const EagerSpec(this.build, {super.produces, super.childProtocol});

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
  const SlotSpec(this.build, {super.produces, super.childProtocol});

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
  const BuilderSpec(this.build, {super.produces, super.childProtocol});

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
  const BoundSpec(this.build, {super.produces, super.childProtocol});

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
  const ActionSpec(this.build, {super.produces, super.childProtocol});

  final ActionBuild build;
}
