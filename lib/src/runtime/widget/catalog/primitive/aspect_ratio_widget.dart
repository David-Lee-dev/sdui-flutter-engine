import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `aspect_ratio` — Builds Flutter's [AspectRatio] for an `aspectRatio` node.
///
/// ```yaml
/// _type: aspect_ratio
/// aspect_ratio: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `aspect_ratio` (`number`, default `1.0`) — width-to-height ratio of the rendered box.
///
/// Child: `_child`.
final class AspectRatioWidget {
  const AspectRatioWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return AspectRatio(
      aspectRatio: PropsResolver.number(props['aspect_ratio']) ?? 1.0,
      child: children.isEmpty ? null : children.first,
    );
  }
}
