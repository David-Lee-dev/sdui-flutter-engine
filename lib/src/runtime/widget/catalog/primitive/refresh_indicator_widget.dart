import 'package:flutter/material.dart';

import '../../contract/action_sink.dart';
import '../../../util/props_resolver.dart';

/// `refresh_indicator` — Builds a [RefreshIndicator] that awaits the configured engine action.
///
/// Awaiting the action keeps Flutter's refresh indicator active until dispatch
/// completes; absent configuration completes immediately.
///
/// ```yaml
/// _type: refresh_indicator
/// on_refresh: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `on_refresh` (`text`, default `null`) — action awaited during refresh.
/// - `color` (`color`, default `null`) — color or tint.
/// - `background_color` (`color`, default `null`) — paints the widget background.
///
/// Child: `_child`.
final class RefreshIndicatorWidget {
  const RefreshIndicatorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final action = PropsResolver.text(props['on_refresh']);
    return RefreshIndicator(
      color: PropsResolver.color(props['color']),
      backgroundColor: PropsResolver.color(props['background_color']),
      onRefresh: () async {
        if (action != null && dispatch != null) {
          await dispatch.handleAwaitable(action);
        }
      },
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}
