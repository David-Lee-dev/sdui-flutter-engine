import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `list_tile` — Arranges leading, title, subtitle, and trailing named slots.
///
/// ```yaml
/// _type: list_tile
/// dense: true
/// selected: false
/// content_padding: [16, 8]
/// _slots:
///   leading: { _type: icon, name: person }
///   title: { _type: text, value: Account }
///   subtitle: { _type: text, value: Profile settings }
///   trailing: { _type: icon, name: chevron_right }
/// ```
///
/// Props:
/// - `dense` (`flag`, default `null`) — uses a compact vertical layout.
/// - `selected` (`flag`, default `false`) — paints the selected state.
/// - `enabled` (`flag`, default `true`) — paints the enabled state.
/// - `content_padding` (`edge`, default `null`) — interior padding.
/// - `three_line` (`flag`, default `false`) — reserves three text lines.
///
/// Child: `_slots: { leading, title, subtitle, trailing }`.
final class ListTileWidget {
  const ListTileWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) => ListTile(
    leading: slots['leading'],
    title: slots['title'],
    subtitle: slots['subtitle'],
    trailing: slots['trailing'],
    dense: PropsResolver.flag(props['dense']),
    selected: PropsResolver.flag(props['selected']) ?? false,
    enabled: PropsResolver.flag(props['enabled']) ?? true,
    contentPadding: PropsResolver.edge(context, props['content_padding']),
    isThreeLine: PropsResolver.flag(props['three_line']) ?? false,
  );
}
