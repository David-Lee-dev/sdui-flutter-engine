import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `backdrop_filter` — Blurs content painted behind its child.
///
/// ```yaml
/// _type: backdrop_filter
/// blur: 8
/// sigma_x: 12
/// blend_mode: src_over
/// _child: { _type: text, value: Frosted }
/// ```
///
/// Props:
/// - `blur` (`number`, default `0.0`) — blur sigma used for both axes.
/// - `sigma_x` (`number`, default `blur`) — horizontal blur sigma override.
/// - `sigma_y` (`number`, default `blur`) — vertical blur sigma override.
/// - `blend_mode` (`blendMode`, default `src_over`) — compositing mode.
///
/// Child: `_child`.
final class BackdropFilterWidget {
  const BackdropFilterWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final blur = PropsResolver.number(props['blur']) ?? 0.0;
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: PropsResolver.number(props['sigma_x']) ?? blur,
        sigmaY: PropsResolver.number(props['sigma_y']) ?? blur,
      ),
      blendMode:
          PropsResolver.blendMode(props['blend_mode']) ?? BlendMode.srcOver,
      child: children.isEmpty ? null : children.first,
    );
  }
}
