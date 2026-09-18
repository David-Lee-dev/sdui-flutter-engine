import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sliver_fill_remaining` — Builds [SliverFillRemaining] around the node's first box child.
///
/// ```yaml
/// _type: sliver_fill_remaining
/// has_scroll_body: true
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `has_scroll_body` (`flag`, default `true`) — allows the child to occupy scrollable space beyond the viewport.
/// - `fill_overscroll` (`flag`, default `false`) — stretches the child into overscroll space.
///
/// Child: `_child`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverFillRemainingWidget {
  const SliverFillRemainingWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SliverFillRemaining(
      hasScrollBody: PropsResolver.flag(props['has_scroll_body']) ?? true,
      fillOverscroll: PropsResolver.flag(props['fill_overscroll']) ?? false,
      child: children.isEmpty ? null : children.first,
    );
  }
}
