import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../util/adaptive_radius_box.dart';

/// `container` — Builds Flutter's [Container] from resolved box props.
///
/// A valid decoration suppresses the separate color argument because Flutter
/// rejects supplying both.
///
/// ```yaml
/// _type: container
/// decoration: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `decoration` (`boxDecoration`, default `null`) — paints the box or field decoration.
/// - `width` (`size` (scaled by EngineMetrics), default `null`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
/// - `padding` (`edge`, default `null`) — inner spacing.
/// - `margin` (`edge`, default `null`) — outer spacing.
/// - `alignment` (`alignment`, default `null`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `constraints` (`constraints`, default `null`) — minimum and maximum dimensions imposed on the child.
/// - `color` (`color`, default `null`) — color or tint.
/// - `foreground_decoration` (`boxDecoration`, default `null`) — paints a decoration in front of the child.
/// - `transform` (`matrix4`, default `null`) — matrix applied before painting the container.
/// - `transform_alignment` (`alignment`, default `null`) — origin alignment for the container transform. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `clip_behavior` (`clip`, default `none`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_child`.
final class ContainerWidget {
  const ContainerWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final decorationRaw = props['decoration'];
    final isAuto =
        decorationRaw is Map &&
        PropsResolver.isAutoRadius(decorationRaw['border_radius']);

    // Radius-independent — resolve now so the prop audit sees these reads even
    // on the deferred auto-radius path, and avoid re-resolving on radius changes.
    final width = PropsResolver.size(context, props['width']);
    final height = PropsResolver.size(context, props['height']);
    final padding = PropsResolver.edge(context, props['padding']);
    final margin = PropsResolver.edge(context, props['margin']);
    final alignment = PropsResolver.alignment(props['alignment']);
    final constraints = PropsResolver.constraints(
      context,
      props['constraints'],
    );
    final colorArg = PropsResolver.color(props['color']);
    final foregroundDecoration = PropsResolver.boxDecoration(
      context,
      props['foreground_decoration'],
    );
    final transform = PropsResolver.matrix4(props['transform']);
    final transformAlignment = PropsResolver.alignment(
      props['transform_alignment'],
    );
    final clipBehavior =
        PropsResolver.clip(props['clip_behavior']) ?? Clip.none;
    final child = children.isEmpty ? null : children.first;

    Widget buildContainer(BorderRadius? borderRadius) {
      final decoration = PropsResolver.boxDecoration(
        context,
        decorationRaw,
        borderRadius: borderRadius,
      );
      return Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        alignment: alignment,
        constraints: constraints,
        color: decoration == null ? colorArg : null,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    if (!isAuto) return buildContainer(null);
    return AdaptiveRadiusBox(
      builder: (radius) => buildContainer(BorderRadius.circular(radius)),
    );
  }
}
