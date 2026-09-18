import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sizedbox` — Builds Flutter's [SizedBox] for a `sizedbox` node.
///
/// ```yaml
/// _type: sizedbox
/// width: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `width` (`size` (scaled by EngineMetrics), default `null`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
///
/// Child: `_child`.
final class SizedBoxWidget {
  const SizedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SizedBox(
      width: PropsResolver.size(context, props['width']),
      height: PropsResolver.size(context, props['height']),
      child: children.isEmpty ? null : children.first,
    );
  }
}
