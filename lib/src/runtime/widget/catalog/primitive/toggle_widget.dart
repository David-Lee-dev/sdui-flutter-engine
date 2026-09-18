import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `toggle` — Builds a controlled Flutter [Switch] using the engine's truthiness rules.
///
/// ```yaml
/// _type: toggle
/// enabled: true
/// bind: state_key
/// _on: { change: change_action, submit: submit_action }
/// ```
///
/// Props:
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `semantics_label` (`text`, default `null`) — accessibility label.
/// - `active_color` (`color`, default `null`) — color used for the selected or active state.
/// - `active_track_color` (`color`, default `null`) — track color while the switch is on.
/// - `inactive_thumb_color` (`color`, default `null`) — thumb color while the switch is off.
/// - `inactive_track_color` (`color`, default `null`) — track color while the switch is off.
///
/// Child: none.
final class ToggleWidget {
  const ToggleWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    final semanticsLabel = PropsResolver.text(props['semantics_label']);
    final toggle = Switch(
      value: PropsResolver.truthy(value),
      activeThumbColor: PropsResolver.color(props['active_color']),
      activeTrackColor: PropsResolver.color(props['active_track_color']),
      inactiveThumbColor: PropsResolver.color(props['inactive_thumb_color']),
      inactiveTrackColor: PropsResolver.color(props['inactive_track_color']),
      onChanged: !enabled || onChanged == null ? null : (v) => onChanged(v),
    );
    return semanticsLabel == null
        ? toggle
        : Semantics(label: semanticsLabel, child: toggle);
  }
}
