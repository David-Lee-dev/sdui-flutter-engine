import 'package:flutter/widgets.dart';

/// `sliver_to_box_adapter` — Adapts the node's first box child to Flutter's sliver protocol.
///
/// ```yaml
/// _type: sliver_to_box_adapter
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - None.
///
/// Child: `_child`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverToBoxAdapterWidget {
  const SliverToBoxAdapterWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SliverToBoxAdapter(child: children.isEmpty ? null : children.first);
  }
}
