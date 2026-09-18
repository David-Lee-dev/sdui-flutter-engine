import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Computes a corner radius from a widget's rendered size.
final class AdaptiveRadius {
  const AdaptiveRadius._();

  /// The radius used for large widgets and before layout is measured.
  static const double maxRadius = 14.0;

  /// The smallest adaptive radius.
  static const double minRadius = 8.0;

  /// The dimension at which the maximum radius is used.
  static const double threshold = 200.0;

  /// Returns the size-adaptive radius for [size].
  static double compute(Size size) {
    if (size.width.isInfinite && size.height.isInfinite) return maxRadius;
    final width = size.width.isInfinite ? threshold : size.width;
    final height = size.height.isInfinite ? threshold : size.height;
    if (width >= threshold && height >= threshold) return maxRadius;
    return math.sqrt(math.min(width, height)).clamp(minRadius, maxRadius);
  }
}
