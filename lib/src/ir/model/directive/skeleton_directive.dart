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
