import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `unconstrained_box` — Removes parent constraints from selected child axes.
///
/// ```yaml
/// _type: unconstrained_box
/// alignment: center
/// constrained_axis: vertical
/// clip_behavior: none
/// _child: { _type: sizedbox, width: 240 }
/// ```
///
/// Props:
/// - `alignment` (`alignment`, default `center`) — child alignment.
/// - `constrained_axis` (`axis`, default `null`) — axis whose constraints remain.
/// - `clip_behavior` (`clip`, default `none`) — overflow clipping behavior.
///
/// Child: `_child`.
final class UnconstrainedBoxWidget {
  const UnconstrainedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => UnconstrainedBox(
    alignment: PropsResolver.alignment(props['alignment']) ?? Alignment.center,
    constrainedAxis: PropsResolver.axis(props['constrained_axis']),
    clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.none,
    child: children.isEmpty ? null : children.first,
  );
}
