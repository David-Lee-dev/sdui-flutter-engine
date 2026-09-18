import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Translates the child between two logical-pixel offsets.
class MoveMotion extends Motion {
  const MoveMotion();

  @override
  String get type => 'move';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.offset('begin', Offset.zero);
    final end = p.offset('end', Offset.zero);
    return Transform.translate(
      offset: Offset.lerp(begin, end, t)!,
      child: child,
    );
  }
}
