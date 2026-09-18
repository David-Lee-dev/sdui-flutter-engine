import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `tab_bar_view` — Builds a [TabBarView] that shares its nearest default tab controller.
///
/// ```yaml
/// _type: tab_bar_view
/// physics: never
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `physics` (`scrollPhysics`, default `null`) — scroll physics. Values: never | bouncing | clamping | always.
///
/// Child: `_children`.
final class TabBarViewWidget {
  const TabBarViewWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return TabBarView(
      physics: PropsResolver.scrollPhysics(props['physics']),
      children: children,
    );
  }
}
