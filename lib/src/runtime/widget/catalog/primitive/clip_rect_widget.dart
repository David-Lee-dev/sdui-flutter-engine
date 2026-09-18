import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `clip_rect` — Builds Flutter's [ClipRect] for a `clipRect` node.
///
/// ```yaml
/// _type: clip_rect
/// clip_behavior: none
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_child`.
final class ClipRectWidget {
  const ClipRectWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return ClipRect(
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      child: children.isEmpty ? null : children.first,
    );
  }
}
