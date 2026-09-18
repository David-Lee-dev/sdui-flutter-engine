import 'package:flutter/material.dart';

import '../../../util/props_resolver.dart';

/// `app_bar` — Arranges `leading` / `title` / `actions` for a fixed app bar's content.
///
/// Hosted in the scaffold's `app_bar` slot, which supplies the status-bar inset
/// and the bar height (see `scaffold_widget.dart`) and gives this content the
/// full width — so leading/title/actions never overflow. This is layout only.
///
/// With `center_title` the title sits at the true horizontal center of the full
/// width (leading and actions float over the edges), so it stays centered no
/// matter how wide the actions are. Without it, the title is left-aligned and
/// fills the gap between leading and actions.
///
/// For a *scroll-away* or *collapsing* bar use `sliver_app_bar` in a
/// `custom_scroll_view` instead — a native [SliverAppBar] owns that behaviour.
///
/// ```yaml
/// _type: app_bar
/// center_title: true
/// _slots: { actions: { _type: text, value: actions }, leading: { _type: text, value: leading }, title: { _type: text, value: title } }
/// ```
///
/// Props:
/// - `center_title` (`flag`, default `false`) — centers the title across the full bar width.
/// - `horizontal_padding` (`size` (scaled by EngineMetrics), default `0.0`) — insets app-bar content from both horizontal edges.
/// - `background_color` (`color`, default `null`) — paints the widget background.
///
/// Child: `_slots: { actions, leading, title }`.
final class AppBarWidget {
  const AppBarWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) {
    final leading = slots['leading'];
    final title = slots['title'];
    final actions = slots['actions'];
    final centerTitle = PropsResolver.flag(props['center_title']) ?? false;
    final padding = EdgeInsets.symmetric(
      horizontal:
          PropsResolver.size(context, props['horizontal_padding']) ?? 0.0,
    );

    final Widget content;
    if (centerTitle && title != null) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                if (leading != null) leading,
                const Spacer(),
                if (actions != null) actions,
              ],
            ),
          ),
          title,
        ],
      );
    } else {
      content = Row(
        children: [
          if (leading != null) leading,
          // Always claim the middle so actions stay right-aligned even when
          // there is no title to push them over.
          Expanded(
            child: title == null
                ? const SizedBox.shrink()
                : Align(alignment: Alignment.centerLeft, child: title),
          ),
          if (actions != null) actions,
        ],
      );
    }

    final padded = Padding(padding: padding, child: content);
    final background = PropsResolver.color(props['background_color']);
    return background == null
        ? padded
        : ColoredBox(color: background, child: padded);
  }
}
