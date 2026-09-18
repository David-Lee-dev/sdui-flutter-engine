import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `center` — Builds Flutter's [Center] for a `center` node.
///
/// ```yaml
/// _type: center
/// width_factor: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `width_factor` (`number`, default `null`) — sizes width to this multiple of the child width.
/// - `height_factor` (`number`, default `null`) — sizes height to this multiple of the child height.
///
/// Child: `_child`.
final class CenterWidget {
  const CenterWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Center(
      widthFactor: PropsResolver.number(props['width_factor']),
      heightFactor: PropsResolver.number(props['height_factor']),
      child: children.isEmpty ? null : children.first,
    );
  }
}
