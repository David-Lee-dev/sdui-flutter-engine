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
    this.merge,
  });

  final Directive bones;
  final Directive child;

  /// The source node's tree path for diagnostics.
  final String path;

  /// How the [bones] swap to [child], from the node's `_presence`.
  final PresenceConfig presence;

  /// When set (`_skeleton: merge`), [bones] are laid out but not painted and
  /// one rounded box of their size is painted instead.
  final SkeletonMerge? merge;
}

/// The box a merged `_skeleton` paints over its derived bones.
final class SkeletonMerge {
  const SkeletonMerge({this.radius = 8, this.width});

  /// Corner radius (`shape: pill` compiles to 999).
  final num radius;

  /// The width the bones are laid out under, or `null` for their own.
  final num? width;
}
