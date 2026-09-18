import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `grid_view` — Builds a non-lazy [GridView] from the node's already-built children.
///
/// ```yaml
/// _type: grid_view
/// cross_axis_count: 1
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `cross_axis_count` (`integer`, default `2`) — number of tiles across the grid cross axis.
/// - `main_axis_spacing` (`size` (scaled by EngineMetrics), default `0`) — gap between grid tiles on the main axis.
/// - `cross_axis_spacing` (`size` (scaled by EngineMetrics), default `0`) — gap between grid tiles on the cross axis.
/// - `child_aspect_ratio` (`number`, default `1.0`) — width-to-height ratio of each grid tile.
/// - `scroll_direction` (`axis`, default `vertical`) — axis along which content scrolls. Values: horizontal | vertical.
/// - `reverse` (`flag`, default `false`) — reverses scroll/paging direction.
/// - `primary` (`flag`, default `null`) — uses the route primary scroll controller when true.
/// - `padding` (`edge`, default `null`) — inner spacing.
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
/// - `keyboard_dismiss_behavior` (`keyboardDismissBehavior`, default `null`) — chooses whether dragging dismisses the keyboard. Values: manual | on_drag.
/// - `shrink_wrap` (`flag`, default `false`) — sizes the scroll view to its content along the scroll axis.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
final class GridViewWidget {
  const GridViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return GridView.count(
      crossAxisCount: PropsResolver.integer(props['cross_axis_count']) ?? 2,
      mainAxisSpacing:
          PropsResolver.size(context, props['main_axis_spacing']) ?? 0,
      crossAxisSpacing:
          PropsResolver.size(context, props['cross_axis_spacing']) ?? 0,
      childAspectRatio:
          PropsResolver.number(props['child_aspect_ratio']) ?? 1.0,
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
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      children: children,
    );
  }
}
