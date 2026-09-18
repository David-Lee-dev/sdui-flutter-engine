import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `shader_mask` — Paints a gradient over its child, tinting the child's painted
/// pixels with it (`blend_mode: src_in`) — the way to render gradient text or icons.
///
/// ```yaml
/// _type: shader_mask
/// gradient: { type: linear, colors: [ { .token: color.primary }, { .token: color.blue } ] }
/// _child: { _type: text, value: "7%", style: { font_size: 20, font_weight: w700 } }
/// ```
///
/// Props:
/// - `gradient` (`gradient`) — the shader painted over the child; when null the child
///   is returned unchanged. `type`: linear | radial | sweep (+ colors/stops/…).
/// - `blend_mode` (`blendMode`, default `src_in`) — how the gradient composites onto
///   the child; `src_in` fills the child's opaque pixels. Values: src_over | src_atop |
///   src_in | dst_in | modulate | multiply | screen | overlay | darken | lighten |
///   color | hue | saturation | luminosity | difference | exclusion | plus | clear.
///
/// Child: `_child`.
final class ShaderMaskWidget {
  const ShaderMaskWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? const SizedBox.shrink() : children.first;
    final gradient = PropsResolver.gradient(props['gradient']);
    if (gradient == null) return child;
    final blend =
        PropsResolver.blendMode(props['blend_mode']) ?? BlendMode.srcIn;
    return ShaderMask(
      blendMode: blend,
      shaderCallback: gradient.createShader,
      child: child,
    );
  }
}
