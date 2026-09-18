import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `positioned` — Builds Flutter's [Positioned], supplying an empty child when required.
///
/// ```yaml
/// _type: positioned
/// left: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `left` (`offset`, default `null`) — offset from the parent left edge.
/// - `top` (`offset`, default `null`) — offset from the parent top edge.
/// - `right` (`offset`, default `null`) — offset from the parent right edge.
/// - `bottom` (`offset`, default `null`) — offset from the parent bottom edge.
/// - `width` (`size` (scaled by EngineMetrics), default `null`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
///
/// Child: `_child`.
final class PositionedWidget {
  const PositionedWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Positioned(
      left: PropsResolver.offset(context, props['left']),
      top: PropsResolver.offset(context, props['top']),
      right: PropsResolver.offset(context, props['right']),
      bottom: PropsResolver.offset(context, props['bottom']),
      width: PropsResolver.size(context, props['width']),
      height: PropsResolver.size(context, props['height']),
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
