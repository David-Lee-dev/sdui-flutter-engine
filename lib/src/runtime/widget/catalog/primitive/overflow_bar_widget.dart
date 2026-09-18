import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `overflow_bar` — Builds Flutter's [OverflowBar] from the node's children.
///
/// ```yaml
/// _type: overflow_bar
/// spacing: 1
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `spacing` (`size` (scaled by EngineMetrics), default `0.0`) — gap between adjacent children or indicator dots.
/// - `overflow_spacing` (`size` (scaled by EngineMetrics), default `0.0`) — gap between children after the bar overflows.
/// - `alignment` (`mainAxisAlignment`, default `null`) — positions the child or children within the available space. Values: start | end | center | space_between | space_around | space_evenly.
/// - `overflow_alignment` (`overflowBarAlignment`, default `start`) — aligns children across the overflow column. Values: start | center | end.
/// - `overflow_direction` (`verticalDirection`, default `down`) — direction in which overflow rows are stacked. Values: up | down.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
///
/// Child: `_children`.
final class OverflowBarWidget {
  const OverflowBarWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return OverflowBar(
      spacing: PropsResolver.size(context, props['spacing']) ?? 0.0,
      overflowSpacing:
          PropsResolver.size(context, props['overflow_spacing']) ?? 0.0,
      alignment: PropsResolver.mainAxisAlignment(props['alignment']),
      overflowAlignment:
          PropsResolver.overflowBarAlignment(props['overflow_alignment']) ??
          OverflowBarAlignment.start,
      overflowDirection:
          PropsResolver.verticalDirection(props['overflow_direction']) ??
          VerticalDirection.down,
      textDirection: PropsResolver.textDirection(props['text_direction']),
      children: children,
    );
  }
}
