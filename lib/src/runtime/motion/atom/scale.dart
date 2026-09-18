import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Uniformly scales the child between numeric endpoints.
class ScaleMotion extends Motion {
  const ScaleMotion();

  @override
  String get type => 'scale';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.number('begin', 1);
    final end = p.number('end', 1);
    final s = begin + (end - begin) * t;
    return Transform.scale(scale: s.toDouble(), child: child);
  }
}
