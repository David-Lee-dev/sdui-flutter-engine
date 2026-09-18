import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Interpolates color saturation with a luminance-preserving matrix.
final class SaturateMotion extends Motion {
  const SaturateMotion();

  @override
  String get type => 'saturate';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.number('begin', 0);
    final end = p.number('end', 1);
    final saturation = (begin + (end - begin) * t).clamp(0.0, 2.0).toDouble();
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_saturationMatrix(saturation)),
      child: child,
    );
  }
}

List<double> _saturationMatrix(double s) {
  const r = 0.2126;
  const g = 0.7152;
  const b = 0.0722;
  final inverse = 1 - s;
  return [
    inverse * r + s,
    inverse * g,
    inverse * b,
    0,
    0,
    inverse * r,
    inverse * g + s,
    inverse * b,
    0,
    0,
    inverse * r,
    inverse * g,
    inverse * b + s,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}
