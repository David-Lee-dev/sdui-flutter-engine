import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `physical_model` — Clips and elevates its child as a physical shape.
///
/// ```yaml
/// _type: physical_model
/// color: '#ffffff'
/// elevation: 4
/// border_radius: 12
/// clip_behavior: anti_alias
/// _child: { _type: text, value: Card }
/// ```
///
/// Props:
/// - `color` (`color`, default `transparent`) — surface color.
/// - `shadow_color` (`color`, default `black`) — elevation shadow color.
/// - `elevation` (`number`, default `0.0`) — z elevation.
/// - `border_radius` (`radius`, default `zero`) — rectangular corner radius.
/// - `shape` (`boxShape`, default `rectangle`) — rectangle or circle.
/// - `clip_behavior` (`clip`, default `none`) — child clipping behavior.
///
/// Child: `_child`.
final class PhysicalModelWidget {
  const PhysicalModelWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => PhysicalModel(
    color: PropsResolver.color(props['color']) ?? Colors.transparent,
    shadowColor: PropsResolver.color(props['shadow_color']) ?? Colors.black,
    elevation: PropsResolver.number(props['elevation']) ?? 0.0,
    borderRadius:
        PropsResolver.radius(context, props['border_radius']) ??
        BorderRadius.zero,
    shape: PropsResolver.boxShape(props['shape']) ?? BoxShape.rectangle,
    clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.none,
    child: children.isEmpty ? null : children.first,
  );
}
