import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `overflow_box` — Builds Flutter's [OverflowBox] for an `overflowBox` node.
///
/// ```yaml
/// _type: overflow_box
/// min_width: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `min_width` (`size` (scaled by EngineMetrics), default `null`) — minimum permitted width.
/// - `max_width` (`size` (scaled by EngineMetrics), default `null`) — maximum permitted width.
/// - `min_height` (`size` (scaled by EngineMetrics), default `null`) — minimum permitted height.
/// - `max_height` (`size` (scaled by EngineMetrics), default `null`) — maximum permitted height.
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
///
/// Child: `_child`.
final class OverflowBoxWidget {
  const OverflowBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return OverflowBox(
      minWidth: PropsResolver.size(context, props['min_width']),
      maxWidth: PropsResolver.size(context, props['max_width']),
      minHeight: PropsResolver.size(context, props['min_height']),
      maxHeight: PropsResolver.size(context, props['max_height']),
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      child: children.isEmpty ? null : children.first,
    );
  }
}
