import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `flexible` — Builds Flutter's [Flexible], supplying an empty child when required.
///
/// ```yaml
/// _type: flexible
/// flex: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `flex` (`integer`, default `1`) — share of remaining main-axis space assigned to this child.
/// - `fit` (`flexFit`, default `loose`) — content fitting mode. Values: tight | loose.
///
/// Child: `_child`.
final class FlexibleWidget {
  const FlexibleWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return Flexible(
      flex: PropsResolver.integer(props['flex']) ?? 1,
      fit: PropsResolver.flexFit(props['fit']) ?? FlexFit.loose,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
