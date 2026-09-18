import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sliver_grid` — Builds a non-lazy [SliverGrid] from the node's box children.
///
/// ```yaml
/// _type: sliver_grid
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
///
/// Child: `_children`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverGridWidget {
  const SliverGridWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SliverGrid.count(
      crossAxisCount: PropsResolver.integer(props['cross_axis_count']) ?? 2,
      mainAxisSpacing:
          PropsResolver.size(context, props['main_axis_spacing']) ?? 0,
      crossAxisSpacing:
          PropsResolver.size(context, props['cross_axis_spacing']) ?? 0,
      childAspectRatio:
          PropsResolver.number(props['child_aspect_ratio']) ?? 1.0,
      children: children,
    );
  }
}
