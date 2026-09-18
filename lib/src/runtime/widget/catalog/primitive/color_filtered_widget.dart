import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `color_filtered` — Tints its child's painted output with a color blend.
///
/// ```yaml
/// _type: color_filtered
/// color: '#336699'
/// blend_mode: src_over
/// _child: { _type: image, url: https://example.com/image.png }
/// ```
///
/// Props:
/// - `color` (`color`, default `null`) — tint color; null returns the child unchanged.
/// - `blend_mode` (`blendMode`, default `src_over`) — color compositing mode.
///
/// Child: `_child`.
final class ColorFilteredWidget {
  const ColorFilteredWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? const SizedBox.shrink() : children.first;
    final color = PropsResolver.color(props['color']);
    if (color == null) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        PropsResolver.blendMode(props['blend_mode']) ?? BlendMode.srcOver,
      ),
      child: child,
    );
  }
}
