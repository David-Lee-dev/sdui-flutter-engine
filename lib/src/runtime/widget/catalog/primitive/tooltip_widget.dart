import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `tooltip` — Shows a text label after hovering or long-pressing its child.
///
/// ```yaml
/// _type: tooltip
/// message: Save
/// wait_duration: 300
/// show_duration: 1500
/// prefer_below: false
/// _child: { _type: icon, name: save }
/// ```
///
/// Props:
/// - `message` (`text`, default `''`) — tooltip label.
/// - `wait_duration` (`duration` in milliseconds, default `null`) — delay before showing.
/// - `show_duration` (`duration` in milliseconds, default `null`) — visible duration.
/// - `prefer_below` (`flag`, default `null`) — prefers placement below the child.
///
/// Child: `_child`.
final class TooltipWidget {
  const TooltipWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => Tooltip(
    message: PropsResolver.text(props['message']) ?? '',
    waitDuration: PropsResolver.duration(props['wait_duration']),
    showDuration: PropsResolver.duration(props['show_duration']),
    preferBelow: PropsResolver.flag(props['prefer_below']),
    child: children.isEmpty ? null : children.first,
  );
}
