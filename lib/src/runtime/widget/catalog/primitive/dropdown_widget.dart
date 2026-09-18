import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `dropdown` — Builds a controlled dropdown from scalar value/label options.
///
/// ```yaml
/// _type: dropdown
/// bind: country
/// options: [{ value: kr, label: Korea }, { value: us, label: USA }]
/// hint: Choose a country
/// is_expanded: true
/// _on: { change: select_country }
/// ```
///
/// Props:
/// - `options` (`list<{value, label}>`, default `[]`) — available scalar options.
/// - `enabled` (`flag`, default `true`) — whether interaction is enabled.
/// - `hint` (`text`, default `null`) — placeholder shown without a selection.
/// - `is_expanded` (`flag`, default `false`) — expands to available width.
///
/// Child: none.
final class DropdownWidget {
  const DropdownWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Object? value,
    ValueChanged<Object?>? onChanged,
    ValueChanged<Object?>? onSubmit,
  ) {
    final options = props['options'];
    final items = <DropdownMenuItem<Object?>>[
      if (options is List)
        for (final option in options)
          if (option is Map)
            DropdownMenuItem<Object?>(
              value: option['value'],
              child: Text(PropsResolver.text(option['label']) ?? ''),
            ),
    ];
    final enabled = PropsResolver.flag(props['enabled']) ?? true;
    final hint = PropsResolver.text(props['hint']);
    return DropdownButton<Object?>(
      value: value,
      items: items,
      onChanged: enabled && onChanged != null ? (v) => onChanged(v) : null,
      hint: hint == null ? null : Text(hint),
      isExpanded: PropsResolver.flag(props['is_expanded']) ?? false,
    );
  }
}
