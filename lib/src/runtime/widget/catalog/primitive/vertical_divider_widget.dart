import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `vertical_divider` — Draws a vertical Material divider.
///
/// ```yaml
/// _type: vertical_divider
/// width: 16
/// thickness: 2
/// indent: 8
/// end_indent: 8
/// color: '#cccccc'
/// ```
///
/// Props:
/// - `width` (`size`, default `null`) — total horizontal extent.
/// - `thickness` (`size`, default `null`) — painted line thickness.
/// - `indent` (`size`, default `null`) — top inset.
/// - `end_indent` (`size`, default `null`) — bottom inset.
/// - `color` (`color`, default `null`) — line color.
///
/// Child: none.
final class VerticalDividerWidget {
  const VerticalDividerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => VerticalDivider(
    width: PropsResolver.size(context, props['width']),
    thickness: PropsResolver.size(context, props['thickness']),
    indent: PropsResolver.size(context, props['indent']),
    endIndent: PropsResolver.size(context, props['end_indent']),
    color: PropsResolver.color(props['color']),
  );
}
