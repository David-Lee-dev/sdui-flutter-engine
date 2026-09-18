import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `fractionally_sized_box` — Builds Flutter's [FractionallySizedBox] for a `fractionallySizedBox` node.
///
/// ```yaml
/// _type: fractionally_sized_box
/// width_factor: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `width_factor` (`number`, default `null`) — sizes width to this multiple of the child width.
/// - `height_factor` (`number`, default `null`) — sizes height to this multiple of the child height.
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
///
/// Child: `_child`.
final class FractionallySizedBoxWidget {
  const FractionallySizedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return FractionallySizedBox(
      widthFactor: PropsResolver.number(props['width_factor']),
      heightFactor: PropsResolver.number(props['height_factor']),
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      child: children.isEmpty ? null : children.first,
    );
  }
}
