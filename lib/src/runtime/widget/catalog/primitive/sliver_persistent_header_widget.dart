import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';

/// `sliver_persistent_header` — Builds a [SliverPersistentHeader] with a fixed child and resolved extents.
///
/// A single `height` fixes both extents; independently supplied bounds support
/// shrinking headers while preserving Flutter's delegate contract.
///
/// ```yaml
/// _type: sliver_persistent_header
/// height: 1
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
/// - `max_extent` (`size` (scaled by EngineMetrics), default `height ?? 56.0`) — largest height of the persistent header.
/// - `min_extent` (`size` (scaled by EngineMetrics), default `height ?? maxExtent`) — smallest height of the persistent header.
/// - `floating` (`flag`, default `false`) — reveals the header as soon as scrolling reverses.
/// - `pinned` (`flag`, default `false`) — keeps the header visible at its minimum extent.
///
/// Child: `_child`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class SliverPersistentHeaderWidget {
  const SliverPersistentHeaderWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final height = PropsResolver.size(context, props['height']);
    final maxExtent =
        PropsResolver.size(context, props['max_extent']) ?? height ?? 56.0;
    final minExtent =
        PropsResolver.size(context, props['min_extent']) ?? height ?? maxExtent;
    final floating = PropsResolver.flag(props['floating']) ?? false;
    return SliverPersistentHeader(
      pinned: PropsResolver.flag(props['pinned']) ?? false,
      floating: floating,
      delegate: _FixedExtentHeaderDelegate(
        minExtentValue: minExtent,
        maxExtentValue: maxExtent,
        child: children.isEmpty ? const SizedBox.shrink() : children.first,
      ),
    );
  }
}

class _FixedExtentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedExtentHeaderDelegate({
    required this.child,
    required this.minExtentValue,
    required this.maxExtentValue,
  });

  final Widget child;
  final double minExtentValue;
  final double maxExtentValue;

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _FixedExtentHeaderDelegate oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.minExtentValue != minExtentValue ||
      oldDelegate.maxExtentValue != maxExtentValue;
}
