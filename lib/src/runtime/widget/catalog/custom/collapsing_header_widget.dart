import 'package:flutter/widgets.dart';

import '../../../util/props_resolver.dart';
import '../../contract/child_builder.dart';

/// `collapsing_header` — Builds a [SliverPersistentHeader] whose child receives scroll-state variables.
///
/// The child is built lazily with `shrinkOffset`, normalized `progress`, and
/// `overlapsContent`, allowing template bindings to react during scrolling.
///
/// ```yaml
/// _type: collapsing_header
/// height: 1
/// _child: { _type: text, value: progress }
/// ```
///
/// Props:
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
/// - `max_extent` (`size` (scaled by EngineMetrics), default `height ?? 56.0`) — largest height of the persistent header.
/// - `min_extent` (`size` (scaled by EngineMetrics), default `height ?? maxExtent`) — smallest height of the persistent header.
/// - `pinned` (`flag`, default `false`) — keeps the header visible at its minimum extent.
/// - `floating` (`flag`, default `false`) — reveals the header as soon as scrolling reverses.
///
/// Child: lazily built `_child`.
///
/// Produces a sliver — place it inside `custom_scroll_view`.
final class CollapsingHeaderWidget {
  const CollapsingHeaderWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    int childCount,
    ChildBuilder buildChild,
  ) {
    final height = PropsResolver.size(context, props['height']);
    final maxExtent =
        PropsResolver.size(context, props['max_extent']) ?? height ?? 56.0;
    final minExtent =
        PropsResolver.size(context, props['min_extent']) ?? height ?? maxExtent;
    return SliverPersistentHeader(
      pinned: PropsResolver.flag(props['pinned']) ?? false,
      floating: PropsResolver.flag(props['floating']) ?? false,
      delegate: _CollapsingHeaderDelegate(
        buildChild: buildChild,
        minExtentValue: minExtent,
        maxExtentValue: maxExtent,
      ),
    );
  }
}

class _CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingHeaderDelegate({
    required this.buildChild,
    required this.minExtentValue,
    required this.maxExtentValue,
  });

  final ChildBuilder buildChild;
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
  ) {
    final range = maxExtentValue - minExtentValue;
    final progress = range <= 0 ? 0.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final child = buildChild(
      0,
      vars: {
        'shrink_offset': shrinkOffset,
        'progress': progress,
        'overlaps_content': overlapsContent,
      },
    );
    return SizedBox.expand(child: child ?? const SizedBox.shrink());
  }

  @override
  bool shouldRebuild(covariant _CollapsingHeaderDelegate old) =>
      old.buildChild != buildChild ||
      old.minExtentValue != minExtentValue ||
      old.maxExtentValue != maxExtentValue;
}
