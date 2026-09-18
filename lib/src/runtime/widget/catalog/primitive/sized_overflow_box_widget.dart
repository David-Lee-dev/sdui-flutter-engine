import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sized_overflow_box` — Builds [SizedOverflowBox] from separate width and height props.
///
/// ```yaml
/// _type: sized_overflow_box
/// width: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `width` (`size` (scaled by EngineMetrics), default `0`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `0`) — sets the box height.
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
///
/// Child: `_child`.
final class SizedOverflowBoxWidget {
  const SizedOverflowBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SizedOverflowBox(
      size: Size(
        PropsResolver.size(context, props['width']) ?? 0,
        PropsResolver.size(context, props['height']) ?? 0,
      ),
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      child: children.isEmpty ? null : children.first,
    );
  }
}
