import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../util/adaptive_radius_box.dart';

/// `decorated_box` — Builds Flutter's [DecoratedBox] for a `decoratedBox` node.
///
/// ```yaml
/// _type: decorated_box
/// decoration: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `decoration` (`boxDecoration`, default `empty decoration`) — paints the box or field decoration.
/// - `position` (`decorationPosition`, default `background`) — paints the decoration behind or in front of the child. Values: background | foreground.
///
/// Child: `_child`.
final class DecoratedBoxWidget {
  const DecoratedBoxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final decorationRaw = props['decoration'];
    final isAuto =
        decorationRaw is Map &&
        PropsResolver.isAutoRadius(decorationRaw['border_radius']);

    Widget buildDecoratedBox(BorderRadius? borderRadius) => DecoratedBox(
      decoration:
          PropsResolver.boxDecoration(
            context,
            decorationRaw,
            borderRadius: borderRadius,
          ) ??
          const BoxDecoration(),
      position:
          PropsResolver.decorationPosition(props['position']) ??
          DecorationPosition.background,
      child: children.isEmpty ? null : children.first,
    );

    if (!isAuto) return buildDecoratedBox(null);
    return AdaptiveRadiusBox(
      builder: (radius) => buildDecoratedBox(BorderRadius.circular(radius)),
    );
  }
}
