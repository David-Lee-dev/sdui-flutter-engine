import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `limited_box` — Builds Flutter's [LimitedBox] for a `limitedBox` node.
///
/// ```yaml
/// _type: limited_box
/// max_width: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `max_width` (`size` (scaled by EngineMetrics), default `double.infinity`) — maximum permitted width.
/// - `max_height` (`size` (scaled by EngineMetrics), default `double.infinity`) — maximum permitted height.
///
/// Child: `_child`.
final class LimitedBoxWidget {
  const LimitedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return LimitedBox(
      maxWidth:
          PropsResolver.size(context, props['max_width']) ?? double.infinity,
      maxHeight:
          PropsResolver.size(context, props['max_height']) ?? double.infinity,
      child: children.isEmpty ? null : children.first,
    );
  }
}
