import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `radio` — Builds one controlled radio option from the bound engine value.
///
/// Radio nodes sharing the same `bind` key form a group. Each node's `value`
/// identifies its option and selecting it writes that scalar to the binding.
///
/// ```yaml
/// _type: radio
/// bind: plan
/// value: pro
/// enabled: true
/// active_color: '#336699'
/// _on: { change: select_plan }
/// ```
///
/// Props:
/// - `value` (`scalar`, default `null`) — this option's value.
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `active_color` (`color`, default `null`) — selected radio color.
///
/// Child: none.
final class RadioWidget {
  const RadioWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    return Radio<Object?>(
      value: props['value'],
      // ignore: deprecated_member_use
      groupValue: value,
      activeColor: PropsResolver.color(props['active_color']),
      // ignore: deprecated_member_use
      onChanged: enabled && onChanged != null ? (v) => onChanged(v) : null,
    );
  }
}
