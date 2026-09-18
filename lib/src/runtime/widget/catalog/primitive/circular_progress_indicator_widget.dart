import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `circular_progress_indicator` — Shows determinate or indeterminate circular progress.
///
/// ```yaml
/// _type: circular_progress_indicator
/// value: 0.6
/// color: '#336699'
/// background_color: '#eeeeee'
/// stroke_width: 4
/// ```
///
/// Props:
/// - `value` (`number`, default `null`) — progress value; null is indeterminate.
/// - `color` (`color`, default `null`) — indicator color.
/// - `background_color` (`color`, default `null`) — track color.
/// - `stroke_width` (`number`, default `4.0`) — ring stroke width.
///
/// Child: none.
final class CircularProgressIndicatorWidget {
  const CircularProgressIndicatorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) => CircularProgressIndicator(
    value: PropsResolver.number(props['value']),
    color: PropsResolver.color(props['color']),
    backgroundColor: PropsResolver.color(props['background_color']),
    strokeWidth: PropsResolver.number(props['stroke_width']) ?? 4.0,
  );
}
