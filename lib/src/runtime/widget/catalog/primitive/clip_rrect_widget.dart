import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../util/adaptive_radius_box.dart';

/// `clip_rrect` — Builds Flutter's [ClipRRect] for a `clipRRect` node.
///
/// ```yaml
/// _type: clip_rrect
/// border_radius: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `border_radius` (`radius`, default `BorderRadius.zero`) — rounds the clipping corners.
/// - `clip_behavior` (`clip`, default `anti_alias`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_child`.
final class ClipRRectWidget {
  const ClipRRectWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? null : children.first;
    final clipBehavior =
        PropsResolver.clip(props['clip_behavior']) ?? Clip.antiAlias;
    if (PropsResolver.isAutoRadius(props['border_radius'])) {
      return AdaptiveRadiusBox(
        builder: (radius) => ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: clipBehavior,
          child: child,
        ),
      );
    }
    return ClipRRect(
      borderRadius:
          PropsResolver.radius(context, props['border_radius']) ??
          BorderRadius.zero,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
