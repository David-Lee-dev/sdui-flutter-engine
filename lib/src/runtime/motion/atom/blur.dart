import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Interpolates a backdrop-independent blur over the child’s rendered pixels.
final class BlurMotion extends Motion {
  const BlurMotion();

  @override
  String get type => 'blur';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.number('begin', 8);
    final end = p.number('end', 0);
    final sigma = begin + (end - begin) * t;
    if (sigma < 0.01) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: sigma.toDouble(),
        sigmaY: sigma.toDouble(),
      ),
      child: child,
    );
  }
}
