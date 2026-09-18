import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `transform` — Builds Flutter's [Transform] from a resolved matrix and alignment.
///
/// ```yaml
/// _type: transform
/// alignment: top_left
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
///
/// Child: `_child`.
final class TransformWidget {
  const TransformWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Transform(
      transform: PropsResolver.matrix4(props) ?? Matrix4.identity(),
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      child: children.isEmpty ? null : children.first,
    );
  }
}
