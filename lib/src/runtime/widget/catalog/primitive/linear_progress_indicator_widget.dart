import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `linear_progress_indicator` — Shows determinate or indeterminate linear progress.
///
/// ```yaml
/// _type: linear_progress_indicator
/// value: 0.6
/// color: '#336699'
/// background_color: '#eeeeee'
/// min_height: 4
/// ```
///
/// Props:
/// - `value` (`number`, default `null`) — progress value; null is indeterminate.
/// - `color` (`color`, default `null`) — indicator color.
/// - `background_color` (`color`, default `null`) — track color.
/// - `min_height` (`size`, default `null`) — minimum track height.
///
/// Child: none.
final class LinearProgressIndicatorWidget {
  const LinearProgressIndicatorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => LinearProgressIndicator(
    value: PropsResolver.number(props['value']),
    color: PropsResolver.color(props['color']),
    backgroundColor: PropsResolver.color(props['background_color']),
    minHeight: PropsResolver.size(context, props['min_height']),
  );
}
