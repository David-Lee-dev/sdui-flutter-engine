import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../util/props_resolver.dart';

/// `loading_indicator` — Shows a branded indeterminate spinner.
///
/// Unlike `circular_progress_indicator` this one is always indeterminate and
/// always sizes itself from [size], so it needs no `sizedbox` wrapper.
///
/// ```yaml
/// _type: loading_indicator
/// variant: staggered_dots_wave
/// size: 20
/// color: '#000000'
/// ```
///
/// Props:
/// - `variant` (`string`, default `staggered_dots_wave`) — animation style; an
///   unknown value falls back to a plain ring so a typo degrades rather than throws.
/// - `size` (`number`, default `24`) — width and height in logical pixels.
/// - `color` (`color`, default theme primary) — primary animation color.
/// - `secondary_color` (`color`, default `color`) — second color; only
///   `flickr` and `twisting_dots` use two.
///
/// Child: none.
final class LoadingIndicatorWidget {
  const LoadingIndicatorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final size = PropsResolver.number(props['size'])?.toDouble() ?? 24.0;
    final color =
        PropsResolver.color(props['color']) ??
        Theme.of(context).colorScheme.primary;
    final secondary = PropsResolver.color(props['secondary_color']) ?? color;

    return switch (props['variant']) {
      'falling_dot' => LoadingAnimationWidget.fallingDot(
        color: color,
        size: size,
      ),
      'four_rotating_dots' => LoadingAnimationWidget.fourRotatingDots(
        color: color,
        size: size,
      ),
      'progressive_dots' => LoadingAnimationWidget.progressiveDots(
        color: color,
        size: size,
      ),
      'discrete_circle' => LoadingAnimationWidget.discreteCircle(
        color: color,
        size: size,
      ),
      'three_arched_circle' => LoadingAnimationWidget.threeArchedCircle(
        color: color,
        size: size,
      ),
      'bouncing_ball' => LoadingAnimationWidget.bouncingBall(
        color: color,
        size: size,
      ),
      'flickr' => LoadingAnimationWidget.flickr(
        leftDotColor: color,
        rightDotColor: secondary,
        size: size,
      ),
      'hexagon_dots' => LoadingAnimationWidget.hexagonDots(
        color: color,
        size: size,
      ),
      'beat' => LoadingAnimationWidget.beat(color: color, size: size),
      'dots_triangle' => LoadingAnimationWidget.dotsTriangle(
        color: color,
        size: size,
      ),
      'half_triangle_dot' => LoadingAnimationWidget.halfTriangleDot(
        color: color,
        size: size,
      ),
      'two_rotating_arc' => LoadingAnimationWidget.twoRotatingArc(
        color: color,
        size: size,
      ),
      'horizontal_rotating_dots' =>
        LoadingAnimationWidget.horizontalRotatingDots(color: color, size: size),
      'newton_cradle' => LoadingAnimationWidget.newtonCradle(
        color: color,
        size: size,
      ),
      'ink_drop' => LoadingAnimationWidget.inkDrop(color: color, size: size),
      'twisting_dots' => LoadingAnimationWidget.twistingDots(
        leftDotColor: color,
        rightDotColor: secondary,
        size: size,
      ),
      'staggered_dots_wave' || null => LoadingAnimationWidget.staggeredDotsWave(
        color: color,
        size: size,
      ),
      'stretched_dots' => LoadingAnimationWidget.stretchedDots(
        color: color,
        size: size,
      ),
      'wave_dots' => LoadingAnimationWidget.waveDots(color: color, size: size),
      'three_rotating_dots' => LoadingAnimationWidget.threeRotatingDots(
        color: color,
        size: size,
      ),
      _ => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      ),
    };
  }
}
