import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sliver_padding` — Adds resolved padding around the node's first sliver child.
///
/// ```yaml
/// _type: sliver_padding
/// padding: example
/// _child: { _type: sliver_list, _children: [{ _type: text, value: hi }] }
/// ```
///
/// Props:
/// - `padding` (`edge`, default `EdgeInsets.zero`) — inner spacing.
///
/// Child: `_child`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverPaddingWidget {
  const SliverPaddingWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SliverPadding(
      padding: PropsResolver.edge(context, props['padding']) ?? EdgeInsets.zero,
      sliver: children.isEmpty ? const SliverToBoxAdapter() : children.first,
    );
  }
}
