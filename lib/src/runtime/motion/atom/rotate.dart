import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Rotates the child in two or three dimensions using radian endpoints.
///
/// `align` moves the pivot: the default centre spin suits badges and spinners,
/// while a pendulum swing needs the pivot at the point the child hangs from
/// (`top_center`), otherwise the top edge sweeps as much as the bottom.
class RotateMotion extends Motion {
  const RotateMotion();

  @override
  String get type => 'rotate';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.number('begin', 0);
    final end = p.number('end', 0);
    final a = (begin + (end - begin) * t).toDouble();
    final axis = p.text('axis') ?? 'z';
    final align = p.alignment('align', Alignment.center);
    if (axis == 'z') {
      return Transform.rotate(angle: a, alignment: align, child: child);
    }
    // Perspective keeps X/Y rotations legible instead of producing a flat skew.
    final m = Matrix4.identity()..setEntry(3, 2, 0.001);
    axis == 'x' ? m.rotateX(a) : m.rotateY(a);
    return Transform(transform: m, alignment: align, child: child);
  }
}
