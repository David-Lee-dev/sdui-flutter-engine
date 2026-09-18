import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `tab_bar` — Builds a [TabBar] that shares its nearest default tab controller.
///
/// ```yaml
/// _type: tab_bar
/// is_scrollable: true
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - `is_scrollable` (`flag`, default `false`) — lets tabs use intrinsic widths and scroll horizontally.
/// - `indicator_color` (`color`, default `null`) — color of the selected-tab indicator.
/// - `indicator_weight` (`size` (scaled by EngineMetrics), default `2.0`) — thickness of the selected-tab indicator.
/// - `indicator_size` (`tabBarIndicatorSize`, default `tab`) — sizes the indicator to the tab or its label. Values: tab | label.
///   The engine pins `tab` because Material 3's primary TabBar default is the surprising label-width `label`.
/// - `label_color` (`color`, default `null`) — color of selected tab labels.
/// - `label_style` (`textStyle`, default `null`) — text style of selected tab labels.
/// - `unselected_label_color` (`color`, default `null`) — color of unselected tab labels.
/// - `unselected_label_style` (`textStyle`, default `null`) — text style of unselected tab labels.
/// - `tab_alignment` (`tabAlignment`, default `null`) — positions tabs within the tab bar. Values: start | start_offset | fill | center.
/// - `divider_color` (`color`, default `null`) — color of the divider beneath the tab bar.
///
/// Child: `_children`.
final class TabBarWidget {
  const TabBarWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return TabBar(
      isScrollable: PropsResolver.flag(props['is_scrollable']) ?? false,
      indicatorColor: PropsResolver.color(props['indicator_color']),
      indicatorWeight:
          PropsResolver.size(context, props['indicator_weight']) ?? 2.0,
      indicatorSize:
          PropsResolver.tabBarIndicatorSize(props['indicator_size']) ??
          TabBarIndicatorSize.tab,
      labelColor: PropsResolver.color(props['label_color']),
      labelStyle: PropsResolver.textStyle(context, props['label_style']),
      unselectedLabelColor: PropsResolver.color(
        props['unselected_label_color'],
      ),
      unselectedLabelStyle: PropsResolver.textStyle(
        context,
        props['unselected_label_style'],
      ),
      tabAlignment: PropsResolver.tabAlignment(props['tab_alignment']),
      dividerColor: PropsResolver.color(props['divider_color']),
      tabs: children,
    );
  }
}
