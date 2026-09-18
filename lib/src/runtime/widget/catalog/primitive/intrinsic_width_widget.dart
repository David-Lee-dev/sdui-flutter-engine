import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `intrinsic_width` — Builds Flutter's [IntrinsicWidth] for an `intrinsicWidth` node.
///
/// ```yaml
/// _type: intrinsic_width
/// step_width: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `step_width` (`size` (scaled by EngineMetrics), default `null`) — rounds intrinsic width up to a multiple of this value.
/// - `step_height` (`size` (scaled by EngineMetrics), default `null`) — rounds intrinsic height up to a multiple of this value.
///
/// Child: `_child`.
final class IntrinsicWidthWidget {
  const IntrinsicWidthWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return IntrinsicWidth(
      stepWidth: PropsResolver.size(context, props['step_width']),
      stepHeight: PropsResolver.size(context, props['step_height']),
      child: children.isEmpty ? null : children.first,
    );
  }
}
