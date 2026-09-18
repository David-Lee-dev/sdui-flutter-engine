import 'package:flutter/cupertino.dart';

import '../../../util/props_resolver.dart';

/// `cupertino_switch` — Builds a controlled iOS-style [CupertinoSwitch] using the
/// engine's truthiness rules.
///
/// The Material counterpart is `toggle`; this is the iOS visual variant. Haptics
/// are driven via `_on`, not baked in. `CupertinoSwitch` has no native size knob,
/// so `scale` fits it into a proportional box (footprint scales with it).
///
/// ```yaml
/// _type: cupertino_switch
/// enabled: true
/// scale: 0.7
/// bind: state_key
/// _on: { change: change_action }
/// ```
///
/// Props:
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `scale` (`number`, default `1.0`) — uniform size factor; scales both the
///   switch and the layout footprint (1.0 = the native iOS size).
/// - `semantics_label` (`text`, default `null`) — accessibility label.
/// - `active_track_color` (`color`, default `null`) — track color while on.
/// - `inactive_track_color` (`color`, default `null`) — track color while off.
/// - `thumb_color` (`color`, default `null`) — thumb color.
/// - `inactive_thumb_color` (`color`, default `null`) — thumb color while off.
///
/// Child: none.
final class CupertinoSwitchWidget {
  const CupertinoSwitchWidget._();

  /// The native iOS switch's logical size, used as the `scale: 1.0` baseline.
  static const double _naturalWidth = 51;
  static const double _naturalHeight = 31;

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    final semanticsLabel = PropsResolver.text(props['semantics_label']);
    final scale = PropsResolver.number(props['scale']) ?? 1.0;
    Widget switchWidget = CupertinoSwitch(
      value: PropsResolver.truthy(value),
      activeTrackColor: PropsResolver.color(props['active_track_color']),
      inactiveTrackColor: PropsResolver.color(props['inactive_track_color']),
      thumbColor: PropsResolver.color(props['thumb_color']),
      inactiveThumbColor: PropsResolver.color(props['inactive_thumb_color']),
      onChanged: !enabled || onChanged == null ? null : (v) => onChanged(v),
    );
    if (scale > 0 && scale != 1.0) {
      // FittedBox scales the fixed-size switch to the box and reports the smaller
      // footprint, so layout follows the visual — unlike a bare Transform.scale.
      switchWidget = SizedBox(
        width: _naturalWidth * scale,
        height: _naturalHeight * scale,
        child: FittedBox(child: switchWidget),
      );
    }
    return semanticsLabel == null
        ? switchWidget
        : Semantics(label: semanticsLabel, child: switchWidget);
  }
}
