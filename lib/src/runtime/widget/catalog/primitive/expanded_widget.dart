import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `expanded` — Builds Flutter's [Expanded], supplying an empty child when required.
///
/// ```yaml
/// _type: expanded
/// flex: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `flex` (`integer`, default `1`) — share of remaining main-axis space assigned to this child.
///
/// Child: `_child`.
final class ExpandedWidget {
  const ExpandedWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Expanded(
      flex: PropsResolver.integer(props['flex']) ?? 1,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
