import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `rotated_box` — Builds Flutter's [RotatedBox] for a `rotatedBox` node.
///
/// ```yaml
/// _type: rotated_box
/// quarter_turns: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `quarter_turns` (`integer`, default `0`) — rotates the child by this many clockwise quarter turns.
///
/// Child: `_child`.
final class RotatedBoxWidget {
  const RotatedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return RotatedBox(
      quarterTurns: PropsResolver.integer(props['quarter_turns']) ?? 0,
      child: children.isEmpty ? null : children.first,
    );
  }
}
