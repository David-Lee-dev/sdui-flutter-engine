import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `positioned_fill` — Builds [Positioned.fill] for a `positionedFill` node.
///
/// ```yaml
/// _type: positioned_fill
/// left: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `left` (`offset`, default `0.0`) — offset from the parent left edge.
/// - `top` (`offset`, default `0.0`) — offset from the parent top edge.
/// - `right` (`offset`, default `0.0`) — offset from the parent right edge.
/// - `bottom` (`offset`, default `0.0`) — offset from the parent bottom edge.
///
/// Child: `_child`.
final class PositionedFillWidget {
  const PositionedFillWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Positioned.fill(
      left: PropsResolver.offset(context, props['left']) ?? 0.0,
      top: PropsResolver.offset(context, props['top']) ?? 0.0,
      right: PropsResolver.offset(context, props['right']) ?? 0.0,
      bottom: PropsResolver.offset(context, props['bottom']) ?? 0.0,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
