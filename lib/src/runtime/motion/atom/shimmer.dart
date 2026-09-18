import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Sweeps a repeating highlight shader across the child.
final class ShimmerMotion extends Motion {
  const ShimmerMotion();

  @override
  String get type => 'shimmer';

  @override
  MotionPlan plan(MotionParams p) => MotionPlan(
    duration: p.duration('duration', const Duration(milliseconds: 1200)),
    curve: p.curve('curve', Curves.linear),
    delay: p.duration('delay', Duration.zero),
    repeat: p.flag('repeat', fallback: true),
    reverse: p.flag('reverse', fallback: false),
    trigger: p.raw('trigger'),
  );

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final base = p.color('base', const Color(0x00FFFFFF));
    final highlight = p.color('highlight', const Color(0x8CFFFFFF));
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) => LinearGradient(
        colors: [base, highlight, base],
        stops: const [0.35, 0.5, 0.65],
        transform: _SlideGradient(t),
      ).createShader(rect),
      child: child,
    );
  }
}

final class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.t);

  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues((t * 2 - 1) * bounds.width, 0, 0);
}
