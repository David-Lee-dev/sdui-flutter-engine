import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `tab` — Assigns named `icon` and `child` slots to a Flutter [Tab].
///
/// ```yaml
/// _type: tab
/// text: example
/// _slots: { icon: { _type: text, value: icon }, label: { _type: text, value: label } }
/// ```
///
/// Props:
/// - `text` (`text`, default `null`) — fallback label shown when no label slot is supplied.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
///
/// Child: `_slots: { icon, label }`.
final class TabWidget {
  const TabWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) {
    return Tab(
      icon: slots['icon'],
      text: slots['label'] == null ? PropsResolver.text(props['text']) : null,
      height: PropsResolver.size(context, props['height']),
      child: slots['label'],
    );
  }
}
