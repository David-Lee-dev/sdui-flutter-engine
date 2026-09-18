import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `wrap` — Builds Flutter's [Wrap] from the node's children.
///
/// ```yaml
/// _type: wrap
/// direction: horizontal
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `direction` (`axis`, default `horizontal`) — selects the layout or dismissal axis. Values: horizontal | vertical.
/// - `alignment` (`wrapAlignment`, default `start`) — positions the child or children within the available space. Values: start | end | center | space_between | space_around | space_evenly.
/// - `run_alignment` (`wrapAlignment`, default `start`) — distributes wrap runs along the cross axis. Values: start | end | center | space_between | space_around | space_evenly.
/// - `cross_axis_alignment` (`wrapCrossAlignment`, default `start`) — positions children across the layout cross axis. Values: start | end | center.
/// - `spacing` (`size` (scaled by EngineMetrics), default `0.0`) — gap between adjacent children or indicator dots.
/// - `run_spacing` (`size` (scaled by EngineMetrics), default `0.0`) — gap between adjacent wrap runs.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
/// - `vertical_direction` (`verticalDirection`, default `down`) — orders vertical layout from top-down or bottom-up. Values: up | down.
/// - `clip_behavior` (`clip`, default `none`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
final class WrapWidget {
  const WrapWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Wrap(
      direction: PropsResolver.axis(props['direction']) ?? Axis.horizontal,
      alignment:
          PropsResolver.wrapAlignment(props['alignment']) ??
          WrapAlignment.start,
      runAlignment:
          PropsResolver.wrapAlignment(props['run_alignment']) ??
          WrapAlignment.start,
      crossAxisAlignment:
          PropsResolver.wrapCrossAlignment(props['cross_axis_alignment']) ??
          WrapCrossAlignment.start,
      spacing: PropsResolver.size(context, props['spacing']) ?? 0.0,
      runSpacing: PropsResolver.size(context, props['run_spacing']) ?? 0.0,
      textDirection: PropsResolver.textDirection(props['text_direction']),
      verticalDirection:
          PropsResolver.verticalDirection(props['vertical_direction']) ??
          VerticalDirection.down,
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.none,
      children: children,
    );
  }
}
