import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `scrollbar` — Builds Flutter's [Scrollbar] around the node's first child.
///
/// ```yaml
/// _type: scrollbar
/// radius: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `radius` (`size` (scaled by EngineMetrics), default `null`) — corner radius of indicator dots.
/// - `thumb_visibility` (`flag`, default `null`) — keeps the scrollbar thumb visible when true.
/// - `track_visibility` (`flag`, default `null`) — keeps the scrollbar track visible when true.
/// - `interactive` (`flag`, default `null`) — allows pointer interaction with the scrollbar.
/// - `thickness` (`size` (scaled by EngineMetrics), default `null`) — width of the scrollbar thumb.
/// - `thumb_color` (`color`, default `null`) — color of the scrollbar thumb.
/// - `track_color` (`color`, default `null`) — color of the scrollbar track.
///
/// Child: `_child`.
final class ScrollbarWidget {
  const ScrollbarWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final radius = PropsResolver.size(context, props['radius']);
    return RawScrollbar(
      thumbVisibility: PropsResolver.flag(props['thumb_visibility']),
      trackVisibility: PropsResolver.flag(props['track_visibility']),
      interactive: PropsResolver.flag(props['interactive']),
      thickness: PropsResolver.size(context, props['thickness']),
      radius: radius == null ? null : Radius.circular(radius),
      thumbColor: PropsResolver.color(props['thumb_color']),
      trackColor: PropsResolver.color(props['track_color']),
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
