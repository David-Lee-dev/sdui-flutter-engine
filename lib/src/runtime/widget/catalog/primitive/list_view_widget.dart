import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `list_view` — Builds a non-lazy [ListView] from the node's already-built children.
///
/// ```yaml
/// _type: list_view
/// scroll_direction: horizontal
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `primary` (`flag`, default `null`) — uses the route primary scroll controller when true.
/// - `padding` (`edge`, default `null`) — inner spacing.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `keyboard_dismiss_behavior` (`keyboardDismissBehavior`, default `null`) — chooses whether dragging dismisses the keyboard. Values: manual | on_drag.
/// - `shrink_wrap` (`flag`, default `false`) — sizes the scroll view to its content along the scroll axis.
/// - `item_extent` (`size` (scaled by EngineMetrics), default `null`) — forces every list item to the same main-axis extent.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
final class ListViewWidget {
  const ListViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return ListView(
      scrollDirection:
          PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical,
      reverse: PropsResolver.flag(props['reverse']) ?? false,
      primary: PropsResolver.flag(props['primary']),
      padding: PropsResolver.edge(context, props['padding']),
      physics: PropsResolver.scrollPhysics(props['physics']),
      keyboardDismissBehavior: PropsResolver.keyboardDismissBehavior(
        props['keyboard_dismiss_behavior'],
      ),
      shrinkWrap: PropsResolver.flag(props['shrink_wrap']) ?? false,
      itemExtent: PropsResolver.size(context, props['item_extent']),
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      children: children,
    );
  }
}
