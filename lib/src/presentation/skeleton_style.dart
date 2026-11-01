import 'package:flutter/painting.dart';

/// How skeleton bones are painted while a scope loads.
enum SkeletonEffect {
  /// The base paint, still. Nothing ticks.
  tint,

  /// The whole outline eases from base to highlight and back each period.
  breathe,

  /// A highlight band sweeps left to right across the outline each period.
  shimmer,
}

/// One paint of a skeleton: a solid color or a gradient over the slot.
final class SkeletonPaint {
  const SkeletonPaint.color(Color this.color) : gradient = null;

  const SkeletonPaint.gradient(Gradient this.gradient) : color = null;

  final Color? color;
  final Gradient? gradient;

  /// The paint as a gradient; a color is a one-color gradient, so effects
  /// blend colors and gradients alike.
  Gradient get asGradient =>
      gradient ?? LinearGradient(colors: [color!, color!]);

  /// The colors the paint runs through, left to right.
  List<Color> get colors => gradient?.colors ?? [color!];
}

/// App-owned defaults for skeleton painting. A template's
/// `_scope._skeleton_style` overrides them key by key for the skeletons
/// under that scope.
///
/// The defaults are a still grey tint; [highlight] and [duration] serve
/// [SkeletonEffect.breathe] and [SkeletonEffect.shimmer].
final class SkeletonStyle {
  const SkeletonStyle({
    this.effect = SkeletonEffect.tint,
    this.base = const SkeletonPaint.color(Color(0xFF2C2C2C)), // surface30
    this.highlight = const SkeletonPaint.color(Color(0xFF4B4B4B)), // surface50
    this.duration = const Duration(milliseconds: 1500),
  });

  final SkeletonEffect effect;
  final SkeletonPaint base;
  final SkeletonPaint highlight;

  /// One breathe or shimmer cycle.
  final Duration duration;

  /// This style with the given values in place; `null` keeps a value.
  SkeletonStyle merge({
    SkeletonEffect? effect,
    SkeletonPaint? base,
    SkeletonPaint? highlight,
    Duration? duration,
  }) => SkeletonStyle(
    effect: effect ?? this.effect,
    base: base ?? this.base,
    highlight: highlight ?? this.highlight,
    duration: duration ?? this.duration,
  );
}
