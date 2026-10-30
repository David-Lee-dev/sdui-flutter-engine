library;

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'action_sink.dart';
import 'child_builder.dart';

/// How a node of a spec draws while it waits on an automatic skeleton
/// (`_skeleton: auto`).
///
/// - [real] builds the widget with leniently resolved props under the bones.
/// - [text] does the same with its `value` replaced by placeholder words,
///   one line per `max_lines` (default one) when the lines come from data.
/// - [circle] draws a `size` square (else the icon theme size, else 24) as a
///   round bone without building it.
/// - [box] draws its declared `width`/`height` without building it — for a
///   spec that would load or report something from its props (media), and
///   always drawn as a leaf.
///
/// A sliver spec ([WidgetSpec.produces]) always draws [real]: a stand-in is
/// a box, which a viewport cannot lay out.
enum SkeletonForm { real, text, circle, box }

/// Describes how the engine builds a widget and validates its layout protocol.
///
/// [produces] identifies the node's own protocol. A null [childProtocol] opts
/// out of uniform child validation for widgets with mixed child roles.
/// [skeleton] is how the node draws while it waits on an automatic skeleton.
sealed class WidgetSpec {
  const WidgetSpec({
    this.produces = LayoutProtocol.box,
    this.childProtocol = LayoutProtocol.box,
    this.skeleton = SkeletonForm.real,
  });

  final LayoutProtocol produces;

  final LayoutProtocol? childProtocol;

  final SkeletonForm skeleton;
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
    super.skeleton,
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
    super.skeleton,
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
    super.skeleton,
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
    super.skeleton,
  });

  final BoundBuild build;
}

/// Builds a widget with access to an optional action dispatcher.
///
/// `dispatch` is null while the node's props wait on an automatic skeleton
/// and becomes non-null on release on the same State without remounting;
/// read `widget.dispatch` when firing, do not cache it in initState.
typedef ActionBuild =
    Widget Function(
      BuildContext context,
      Map<String, Object?> props,
      List<Widget> children,
      ActionSink? dispatch,
    );

/// Describes a widget that can dispatch its own gesture-driven actions.
///
/// See [ActionBuild] for when its `dispatch` is null.
final class ActionSpec extends WidgetSpec {
  const ActionSpec(
    this.build, {
    super.produces,
    super.childProtocol,
    super.skeleton,
  });

  final ActionBuild build;
}
