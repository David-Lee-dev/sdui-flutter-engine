import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../../util/scroll_inset.dart';

/// `grid_view` — Builds a non-lazy [GridView] from the node's already-built children.
///
/// A vertical grid that reaches the bottom of the screen scrolls under the
/// bottom system inset and adds it to its end spacing (see [ScrollInset]).
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
/// - `inset_end` (`flag`, default `null`) — adds the `MediaQuery` bottom padding the host passes in after the content of a vertical view: by default only when the view reaches the bottom inset of the screen; `true` always, `false` never.
///
/// Child: `_children`.
final class GridViewWidget {
  const GridViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    // Props are read here, not in the deferred builder, so the debug prop
    // audit that runs right after this build sees every read.
    final axis = PropsResolver.axis(props['scroll_direction']) ?? Axis.vertical;
    final crossAxisCount =
        PropsResolver.integer(props['cross_axis_count']) ?? 2;
    final mainAxisSpacing =
        PropsResolver.size(context, props['main_axis_spacing']) ?? 0;
    final crossAxisSpacing =
        PropsResolver.size(context, props['cross_axis_spacing']) ?? 0;
    final childAspectRatio =
        PropsResolver.number(props['child_aspect_ratio']) ?? 1.0;
    final reverse = PropsResolver.flag(props['reverse']) ?? false;
    final primary = PropsResolver.flag(props['primary']);
    final padding = PropsResolver.edge(context, props['padding']);
    final physics = PropsResolver.scrollPhysics(props['physics']);
    final keyboardDismissBehavior = PropsResolver.keyboardDismissBehavior(
      props['keyboard_dismiss_behavior'],
    );
    final shrinkWrap = PropsResolver.flag(props['shrink_wrap']) ?? false;
    final clipBehavior =
        PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge;
    return ScrollInset.build(
      context,
      axis: axis,
      insetEnd: PropsResolver.flag(props['inset_end']),
      builder: (context, extent) => GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        scrollDirection: axis,
        reverse: reverse,
        primary: primary,
        padding: ScrollInset.endPadding(padding, axis, extent),
        physics: physics,
        keyboardDismissBehavior: keyboardDismissBehavior,
        shrinkWrap: shrinkWrap,
        clipBehavior: clipBehavior,
        children: children,
      ),
    );
  }
}
