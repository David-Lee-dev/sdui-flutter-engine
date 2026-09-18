import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `checkbox` — Builds a controlled Flutter [Checkbox] from the bound engine value.
///
/// The value uses the engine's lenient truthiness rules, while `enabled` and
/// the injected [onChanged] callback jointly determine whether input is accepted.
///
/// ```yaml
/// _type: checkbox
/// enabled: true
/// bind: state_key
/// _on: { change: change_action, submit: submit_action }
/// ```
///
/// Props:
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `semantics_label` (`text`, default `null`) — accessibility label.
/// - `active_color` (`color`, default `null`) — color used for the selected or active state.
/// - `check_color` (`color`, default `null`) — color of the checkbox check mark.
/// - `shape` (`outlinedBorder`, default `null`) — outline shape of the checkbox.
///
/// Child: none.
final class CheckboxWidget {
  const CheckboxWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    final semanticsLabel = PropsResolver.text(props['semantics_label']);
    final checkbox = Checkbox(
      value: PropsResolver.truthy(value),
      activeColor: PropsResolver.color(props['active_color']),
      checkColor: PropsResolver.color(props['check_color']),
      shape: PropsResolver.outlinedBorder(context, props['shape']),
      onChanged: !enabled || onChanged == null
          ? null
          : (v) => onChanged(v ?? false),
    );
    return semanticsLabel == null
        ? checkbox
        : Semantics(label: semanticsLabel, child: checkbox);
  }
}
