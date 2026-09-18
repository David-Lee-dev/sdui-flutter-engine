import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `single_child_scroll_view` — Builds Flutter's [SingleChildScrollView] for the node's first child.
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
///
/// Child: `_child`.
final class SingleChildScrollViewWidget {
  const SingleChildScrollViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SingleChildScrollView(
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      primary: PropsResolver.flag(props['primary']),
      padding: PropsResolver.edge(context, props['padding']),
      physics: PropsResolver.scrollPhysics(props['physics']),
      keyboardDismissBehavior: PropsResolver.keyboardDismissBehavior(
        props['keyboard_dismiss_behavior'],
      ),
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      child: children.isEmpty ? null : children.first,
    );
  }
}
