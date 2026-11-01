part of '_base.dart';

/// Shows [bones] in place of [child] while the nearest loading scope loads.
///
/// [bones] is compiled from the node's `_skeleton` (derived, given or
/// repeated for a loop) and reads none of the loaded data. [child] is the
/// node with its `_if` and `_loop` boundaries.
final class SkeletonDirective extends Directive {
  const SkeletonDirective({
    required this.bones,
    required this.child,
    required this.path,
    this.presence = const PresenceConfig(),
  });

  final Directive bones;
  final Directive child;

  /// The source node's tree path for diagnostics.
  final String path;

  /// How the [bones] swap to [child], from the node's `_presence`.
  final PresenceConfig presence;
}

/// A `_skeleton: merge` within bones: lays [bones] out but paints one
/// rounded box of their size instead. It holds no loading slot of its own;
/// the slot whose bones contain it (the node's own, or an ancestor's
/// derived `_skeleton`) loads and swaps.
final class MergedBonesDirective extends Directive {
  const MergedBonesDirective({
    required this.bones,
    required this.merge,
    required this.path,
  });

  /// The node's bones, derived as for `_skeleton: true`.
  final Directive bones;

  final SkeletonMerge merge;

  /// The source node's tree path for diagnostics.
  final String path;
}

/// The box a merged `_skeleton` paints over its derived bones.
final class SkeletonMerge {
  const SkeletonMerge({this.radius = 8, this.width});

  /// Corner radius (`shape: pill` compiles to 999).
  final num radius;

  /// The width the bones are laid out under, or `null` for their own.
  final num? width;
}
