import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `sliver_app_bar` — Assigns named engine slots to a Flutter [SliverAppBar].
///
/// The `bottom` slot is wrapped in [PreferredSize] when necessary, and `snap`
/// is disabled unless `floating` is enabled to satisfy Flutter's invariant.
///
/// ```yaml
/// _type: sliver_app_bar
/// floating: true
/// _slots: { actions: { _type: text, value: actions }, bottom: { _type: text, value: bottom }, flexible_space: { _type: text, value: flexible_space }, leading: { _type: text, value: leading }, title: { _type: text, value: title } }
/// ```
///
/// Props:
/// - `floating` (`flag`, default `false`) — reveals the header as soon as scrolling reverses.
/// - `pinned` (`flag`, default `false`) — keeps the header visible at its minimum extent.
/// - `snap` (`flag`, default `false`) — snaps a floating app bar fully open or closed.
/// - `expanded_height` (`size` (scaled by EngineMetrics), default `null`) — height of the app bar when fully expanded.
/// - `elevation` (`size` (scaled by EngineMetrics), default `null`) — shadow depth beneath the app bar.
/// - `background_color` (`color`, default `null`) — paints the widget background.
/// - `foreground_color` (`color`, default `null`) — sets the default color for app-bar content.
/// - `center_title` (`flag`, default `null`) — centers the title across the full bar width.
/// - `automatically_imply_leading` (`flag`, default `false`) — inserts a route-aware leading widget when none is supplied.
/// - `bottom_height` (`size` (scaled by EngineMetrics), default `48.0`) — preferred height assigned to the bottom slot.
///
/// Child: `_slots: { actions, bottom, flexible_space, leading, title }`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverAppBarWidget {
  const SliverAppBarWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) {
    final floating = PropsResolver.flag(props['floating']) ?? false;
    return SliverAppBar(
      pinned: PropsResolver.flag(props['pinned']) ?? false,
      floating: floating,
      snap: (PropsResolver.flag(props['snap']) ?? false) && floating,
      expandedHeight: PropsResolver.size(context, props['expanded_height']),
      elevation: PropsResolver.size(context, props['elevation']),
      backgroundColor: PropsResolver.color(props['background_color']),
      foregroundColor: PropsResolver.color(props['foreground_color']),
      centerTitle: PropsResolver.flag(props['center_title']),
      automaticallyImplyLeading:
          PropsResolver.flag(props['automatically_imply_leading']) ?? false,
      title: slots['title'],
      leading: slots['leading'],
      flexibleSpace: slots['flexible_space'],
      actions: slots['actions'] == null ? null : [slots['actions']!],
      bottom: _bottom(context, props, slots['bottom']),
    );
  }

  static PreferredSizeWidget? _bottom(
    BuildContext context,
    Map<String, Object?> props,
    Widget? slot,
  ) {
    if (slot == null) return null;
    if (slot is PreferredSizeWidget) return slot;
    final height = PropsResolver.size(context, props['bottom_height']) ?? 48.0;
    return PreferredSize(preferredSize: Size.fromHeight(height), child: slot);
  }
}
