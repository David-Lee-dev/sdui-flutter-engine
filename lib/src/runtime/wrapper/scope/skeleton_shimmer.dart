import 'package:flutter/widgets.dart';

/// The shimmer look shared by hand-drawn and automatic skeletons, so both
/// read the same.
abstract final class SkeletonShimmer {
  static const Color base = Color(0xFF2C2C2C); // surface30
  static const Color highlight = Color(0xFF4B4B4B); // surface50

  /// Standard shimmer cadence (the `shimmer` package's default period).
  static const Duration period = Duration(milliseconds: 1500);

  /// The standard shimmer gradient: a highlight band padded by base on both ends
  /// (so a base gap follows each pass), swept left→right as [t] goes 0→1. Clamp
  /// tiling keeps everything base once the band slides off. Matches the widely
  /// used `shimmer` package's default colors/stops/direction.
  static LinearGradient gradient(double t) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    colors: const [base, base, highlight, base, base],
    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    transform: _SlideTransform(2 * t - 1),
  );
}

/// Translates a gradient horizontally by [percent] of the bounds' width, moving
/// the highlight band across (and past) the subtree each cycle.
class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * percent, 0, 0);
}
