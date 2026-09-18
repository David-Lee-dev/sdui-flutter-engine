import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `badge` — Places a label or dot badge over a child widget.
///
/// ```yaml
/// _type: badge
/// label: '3'
/// background_color: '#cc0000'
/// text_color: '#ffffff'
/// alignment: top_end
/// _child: { _type: icon, name: notifications }
/// ```
///
/// Props:
/// - `label` (`text`, default `null`) — label text; null creates a dot badge.
/// - `background_color` (`color`, default `null`) — badge fill color.
/// - `text_color` (`color`, default `null`) — label text color.
/// - `alignment` (`alignmentDirectional`, default `null`) — badge alignment.
/// - `is_label_visible` (`flag`, default `true`) — whether the badge is visible.
///
/// Child: `_child` (the badged widget).
final class BadgeWidget {
  const BadgeWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final label = PropsResolver.text(props['label']);
    final textColor = PropsResolver.color(props['text_color']);
    return Badge(
      label: label == null
          ? null
          : Text(
              label,
              style: textColor == null ? null : TextStyle(color: textColor),
            ),
      backgroundColor: PropsResolver.color(props['background_color']),
      textColor: textColor,
      alignment: PropsResolver.alignmentDirectional(props['alignment']),
      isLabelVisible: PropsResolver.flag(props['is_label_visible']) ?? true,
      child: children.isEmpty ? null : children.first,
    );
  }
}
