import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `clip_oval` — Builds Flutter's [ClipOval] for a `clipOval` node.
///
/// ```yaml
/// _type: clip_oval
/// clip_behavior: none
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `clip_behavior` (`clip`, default `anti_alias`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_child`.
final class ClipOvalWidget {
  const ClipOvalWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return ClipOval(
      clipBehavior:
          PropsResolver.clip(props['clip_behavior']) ?? Clip.antiAlias,
      child: children.isEmpty ? null : children.first,
    );
  }
}
