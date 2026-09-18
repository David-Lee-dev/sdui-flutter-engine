import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `stack` — Builds Flutter's [Stack] from the node's children.
///
/// ```yaml
/// _type: stack
/// alignment: top_left
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `alignment` (`alignment`, default `AlignmentDirectional.topStart`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `text_direction` (`textDirection`, default `null`) — resolves start/end ordering and alignment. Values: ltr | rtl.
/// - `fit` (`stackFit`, default `loose`) — content fitting mode. Values: loose | expand | passthrough.
/// - `clip_behavior` (`clip`, default `hard_edge`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_children`.
final class StackWidget {
  const StackWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Stack(
      alignment:
          PropsResolver.alignment(props['alignment']) ??
          AlignmentDirectional.topStart,
      textDirection: PropsResolver.textDirection(props['text_direction']),
      fit: PropsResolver.stackFit(props['fit']) ?? StackFit.loose,
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.hardEdge,
      children: children,
    );
  }
}
