/// A scope's `_skeleton_style`: the skeleton paint keys it overrides for the
/// skeletons under it, each `null` when omitted.
///
/// Values are validated literals; the runtime decodes them once.
final class SkeletonStyleOverride {
  const SkeletonStyleOverride({
    this.effect,
    this.base,
    this.highlight,
    this.durationMs,
  });

  /// `tint`, `breathe` or `shimmer`.
  final String? effect;

  /// A color literal or a gradient map, as in widget props.
  final Object? base;
  final Object? highlight;

  /// One breathe or shimmer cycle in milliseconds.
  final int? durationMs;
}
