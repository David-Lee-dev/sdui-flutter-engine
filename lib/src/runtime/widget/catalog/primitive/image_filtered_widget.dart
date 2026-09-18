import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `image_filtered` — Applies a blur filter to its child's painted output.
///
/// ```yaml
/// _type: image_filtered
/// blur: 4
/// sigma_y: 8
/// enabled: true
/// _child: { _type: image, url: https://example.com/image.png }
/// ```
///
/// Props:
/// - `blur` (`number`, default `0.0`) — blur sigma used for both axes.
/// - `sigma_x` (`number`, default `blur`) — horizontal blur sigma override.
/// - `sigma_y` (`number`, default `blur`) — vertical blur sigma override.
/// - `enabled` (`flag`, default `true`) — whether the filter is applied.
///
/// Child: `_child`.
final class ImageFilteredWidget {
  const ImageFilteredWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final blur = PropsResolver.number(props['blur']) ?? 0.0;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: PropsResolver.number(props['sigma_x']) ?? blur,
        sigmaY: PropsResolver.number(props['sigma_y']) ?? blur,
      ),
      enabled: PropsResolver.flag(props['enabled']) ?? true,
      child: children.isEmpty ? null : children.first,
    );
  }
}
