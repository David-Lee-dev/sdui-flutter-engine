import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `skeleton` — One loading-placeholder bone (a rounded box) for a `_skeleton`
/// outline.
///
/// A bone declares only its *shape*; the shimmer sweep is applied automatically
/// by the enclosing `SkeletonScope`, so authors never wire an animation per node.
/// The fill is opaque on purpose — the ancestor shimmer paints over it with a
/// `srcATOP` mask, recoloring every bone in unison while transparent gaps (the
/// surrounding layout) stay clear. That yields the modern "bones on background"
/// look from a plain outline.
///
/// ```yaml
/// _type: skeleton
/// width: 120
/// height: 16
/// shape: pill
/// ```
///
/// Props:
/// - `width` (`size`, default `null`) — bone width; null lets the parent size it
///   (e.g. inside `expanded`). Ignored for `circle` (diameter = `height`).
/// - `height` (`size`, default `16`) — bone height (and circle diameter).
/// - `radius` (`size`, default `8`) — corner radius for the `rect` shape.
/// - `shape` (`text`, default `rect`) — `rect` | `circle` | `pill`.
/// - `color` (`color`, default base grey) — fill; irrelevant under the shimmer
///   mask, kept for standalone/degraded use.
///
/// Child: none.
final class SkeletonWidget {
  const SkeletonWidget._();

  /// Opaque base so the ancestor shimmer's `srcATOP` mask has pixels to recolor.
  static const Color _base = Color(0xFF2C2C2C); // surface30

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final height = PropsResolver.size(context, props['height']) ?? 16;
    final shape = PropsResolver.text(props['shape']) ?? 'rect';
    final color = PropsResolver.color(props['color']) ?? _base;
    final width = PropsResolver.size(context, props['width']);

    final (double? boxWidth, BorderRadius radius) = switch (shape) {
      'circle' => (height, BorderRadius.circular(height / 2)),
      'pill' => (width, BorderRadius.circular(height / 2)),
      _ => (
        width,
        BorderRadius.circular(
          PropsResolver.size(context, props['radius']) ?? 8,
        ),
      ),
    };

    return Container(
      width: boxWidth,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
  }
}
