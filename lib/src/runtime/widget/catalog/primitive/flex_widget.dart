import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `flex` — Builds Flutter's [Flex] for a `flex` node.
///
/// ```yaml
/// _type: flex
/// direction: horizontal
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `direction` (`axis`, default `horizontal`) — selects the layout or dismissal axis. Values: horizontal | vertical.
/// - `main_axis_alignment` (`mainAxisAlignment`, default `start`) — distributes children along the layout main axis. Values: start | end | center | space_between | space_around | space_evenly.
/// - `cross_axis_alignment` (`crossAxisAlignment`, default `center`) — positions children across the layout cross axis. Values: start | end | center | stretch | baseline.
/// - `main_axis_size` (`mainAxisSize`, default `max`) — min hugs children, max fills the main axis. Values: min | max.
/// - `vertical_direction` (`verticalDirection`, default `down`) — orders vertical layout from top-down or bottom-up. Values: up | down.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
/// - `text_baseline` (`textBaseline`, default `null`) — baseline used when aligning flex children. Values: alphabetic | ideographic.
/// - `spacing` (`size` (scaled by EngineMetrics), default `0.0`) — gap between adjacent children or indicator dots.
///
/// Child: `_children`.
final class FlexWidget {
  const FlexWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Flex(
      direction: PropsResolver.axis(props['direction']) ?? Axis.horizontal,
      mainAxisAlignment:
          PropsResolver.mainAxisAlignment(props['main_axis_alignment']) ??
          MainAxisAlignment.start,
      crossAxisAlignment:
          PropsResolver.crossAxisAlignment(props['cross_axis_alignment']) ??
          CrossAxisAlignment.center,
      mainAxisSize:
          PropsResolver.mainAxisSize(props['main_axis_size']) ??
          MainAxisSize.max,
      verticalDirection:
          PropsResolver.verticalDirection(props['vertical_direction']) ??
          VerticalDirection.down,
      textDirection: PropsResolver.textDirection(props['text_direction']),
      textBaseline: PropsResolver.textBaseline(props['text_baseline']),
      spacing: PropsResolver.size(context, props['spacing']) ?? 0.0,
      children: children,
    );
  }
}
