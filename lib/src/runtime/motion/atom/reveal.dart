import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Reveals the child by clipping and expanding it from a selected edge.
final class RevealMotion extends Motion {
  const RevealMotion();

  @override
  String get type => 'reveal';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final factor = t.clamp(0.0, 1.0).toDouble();
    final direction = p.text('direction');
    final (alignment, widthFactor, heightFactor) = switch (direction) {
      'down' => (Alignment.topCenter, null, factor),
      'left' => (Alignment.centerRight, factor, null),
      'right' => (Alignment.centerLeft, factor, null),
      _ => (Alignment.bottomCenter, null, factor),
    };
    return ClipRect(
      child: Align(
        alignment: alignment,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }
}
