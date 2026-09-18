import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Interpolates the child’s opacity while clamping it to Flutter’s valid range.
class FadeMotion extends Motion {
  const FadeMotion();

  @override
  String get type => 'fade';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.number('begin', 0);
    final end = p.number('end', 1);
    return Opacity(
      opacity: (begin + (end - begin) * t).clamp(0.0, 1.0).toDouble(),
      child: child,
    );
  }
}
