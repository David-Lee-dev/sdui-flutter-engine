import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../../util/scroll_inset.dart';

/// `single_child_scroll_view` — Builds Flutter's [SingleChildScrollView] for the node's first child.
///
/// A vertical view that reaches the bottom of the screen scrolls under the
/// bottom system inset and adds it to its end spacing (see [ScrollInset]).
///
/// ```yaml
/// _type: single_child_scroll_view
/// scroll_direction: horizontal
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `primary` (`flag`, default `null`) — uses the route primary scroll controller when true.
/// - `padding` (`edge`, default `null`) — inner spacing.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `keyboard_dismiss_behavior` (`keyboardDismissBehavior`, default `null`) — chooses whether dragging dismisses the keyboard. Values: manual | on_drag.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
/// - `inset_end` (`flag`, default `null`) — adds the bottom system inset after the content of a vertical view: by default only when the view reaches the bottom inset of the screen; `true` always, `false` never.
///
/// Child: `_child`.
final class SingleChildScrollViewWidget {
  const SingleChildScrollViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    // Props are read here, not in the deferred builder, so the debug prop
    // audit that runs right after this build sees every read.
    final axis = PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical;
    final reverse = PropsResolver.flag(props['reverse']) ?? false;
    final primary = PropsResolver.flag(props['primary']);
    final padding = PropsResolver.edge(context, props['padding']);
    final physics = PropsResolver.scrollPhysics(props['physics']);
    final keyboardDismissBehavior = PropsResolver.keyboardDismissBehavior(
      props['keyboard_dismiss_behavior'],
    );
    final clipBehavior =
        PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge;
    return ScrollInset.build(
      context,
      axis: axis,
      insetEnd: PropsResolver.flag(props['inset_end']),
      builder: (context, extent) => SingleChildScrollView(
        scrollDirection: axis,
        reverse: reverse,
        primary: primary,
        padding: ScrollInset.endPadding(padding, axis, extent),
        physics: physics,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        child: children.isEmpty ? null : children.first,
      ),
    );
  }
}
