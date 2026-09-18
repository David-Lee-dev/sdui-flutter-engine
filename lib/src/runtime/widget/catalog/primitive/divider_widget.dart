import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `divider` — Draws a horizontal Material divider.
///
/// ```yaml
/// _type: divider
/// height: 16
/// thickness: 2
/// indent: 8
/// end_indent: 8
/// color: '#cccccc'
/// ```
///
/// Props:
/// - `height` (`size`, default `null`) — total vertical extent.
/// - `thickness` (`size`, default `null`) — painted line thickness.
/// - `indent` (`size`, default `null`) — leading inset.
/// - `end_indent` (`size`, default `null`) — trailing inset.
/// - `color` (`color`, default `null`) — line color.
///
/// Child: none.
final class DividerWidget {
  const DividerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => Divider(
    height: PropsResolver.size(context, props['height']),
    thickness: PropsResolver.size(context, props['thickness']),
    indent: PropsResolver.size(context, props['indent']),
    endIndent: PropsResolver.size(context, props['end_indent']),
    color: PropsResolver.color(props['color']),
  );
}
