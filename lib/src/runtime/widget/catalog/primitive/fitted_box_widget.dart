import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `fitted_box` — Builds Flutter's [FittedBox] for a `fittedBox` node.
///
/// ```yaml
/// _type: fitted_box
/// fit: fill
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `fit` (`boxFit`, default `contain`) — content fitting mode. Values: fill | contain | cover | fit_width | fit_height | none | scale_down.
/// - `alignment` (`alignment`, default `center`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `clip_behavior` (`clip`, default `none`) — edge clipping behavior. Values: none | hard_edge | anti_alias | anti_alias_with_save_layer.
///
/// Child: `_child`.
final class FittedBoxWidget {
  const FittedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return FittedBox(
      fit: PropsResolver.boxFit(props['fit']) ?? BoxFit.contain,
      alignment:
          PropsResolver.alignment(props['alignment']) ?? Alignment.center,
      clipBehavior: PropsResolver.clip(props['clip_behavior']) ?? Clip.none,
      child: children.isEmpty ? null : children.first,
    );
  }
}
