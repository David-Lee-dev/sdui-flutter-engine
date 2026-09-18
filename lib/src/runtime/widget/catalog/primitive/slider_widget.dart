import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `slider` — Builds a controlled Flutter [Slider] from the bound engine value.
///
/// Numeric bounds are normalized before construction, and the bound value is
/// clamped so malformed remote data cannot violate Flutter's slider assertions.
///
/// ```yaml
/// _type: slider
/// enabled: true
/// bind: state_key
/// _on: { change: change_action, submit: submit_action }
/// ```
///
/// Props:
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `semantics_label` (`text`, default `null`) — accessibility label.
/// - `min` (`number`, default `0.0`) — lower bound of the slider value.
/// - `max` (`number`, default `1.0`) — upper bound of the slider value.
/// - `divisions` (`integer`, default `null`) — splits the slider range into discrete intervals.
/// - `active_color` (`color`, default `null`) — color used for the selected or active state.
/// - `inactive_color` (`color`, default `null`) — color used for the inactive slider track.
/// - `thumb_color` (`color`, default `null`) — color of the scrollbar thumb.
/// - `label` (`text`, default `null`) — text displayed for the current slider value.
///
/// Child: none.
final class SliderWidget {
  const SliderWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    final semanticsLabel = PropsResolver.text(props['semantics_label']);
    final rawMin = PropsResolver.number(props['min']) ?? 0.0;
    final rawMax = PropsResolver.number(props['max']) ?? 1.0;
    final lo = rawMin <= rawMax ? rawMin : rawMax;
    final hi = rawMin <= rawMax ? rawMax : rawMin;
    final current = (PropsResolver.number(value) ?? lo).clamp(lo, hi);
    final slider = Slider(
      value: current.toDouble(),
      min: lo,
      max: hi,
      divisions: PropsResolver.integer(props['divisions']),
      activeColor: PropsResolver.color(props['active_color']),
      inactiveColor: PropsResolver.color(props['inactive_color']),
      thumbColor: PropsResolver.color(props['thumb_color']),
      label: PropsResolver.text(props['label']),
      onChanged: !enabled || onChanged == null ? null : (v) => onChanged(v),
    );
    return semanticsLabel == null
        ? slider
        : Semantics(label: semanticsLabel, child: slider);
  }
}
