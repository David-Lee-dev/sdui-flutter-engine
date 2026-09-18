import 'package:flutter/widgets.dart';

/// `sliver_list` — Builds a non-lazy [SliverList] from the node's box children.
///
/// ```yaml
/// _type: sliver_list
/// _children:
///   - { _type: text, value: a }
///   - { _type: text, value: b }
/// ```
///
/// Props:
/// - None.
///
/// Child: `_children`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverListWidget {
  const SliverListWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return SliverList(delegate: SliverChildListDelegate(children));
  }
}
