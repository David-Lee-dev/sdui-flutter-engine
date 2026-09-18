import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `align` — Builds Flutter's [Align] for an `align` node.
///
/// ```yaml
/// _type: align
/// alignment: top_left
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `width_factor` (`number`, default `null`) — sizes width to this multiple of the child width.
/// - `height_factor` (`number`, default `null`) — sizes height to this multiple of the child height.
///
/// Child: `_child`.
final class AlignWidget {
  const AlignWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Align(
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      widthFactor: PropsResolver.number(props['width_factor']),
      heightFactor: PropsResolver.number(props['height_factor']),
      child: children.isEmpty ? null : children.first,
    );
  }
}
