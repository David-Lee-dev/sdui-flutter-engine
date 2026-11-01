import 'package:flutter/widgets.dart';

import '../_base.dart';

/// Reveals the child by clipping and expanding it from a selected edge.
///
/// Only the reveal axis changes: the other axis keeps the child's size
/// (factor 1), so a bounded constraint never stretches it.
final class RevealMotion extends Motion {
  const RevealMotion();

  @override
  String get type => 'reveal';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  bool get affectsLayout => true;

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final factor = t.clamp(0.0, 1.0).toDouble();
    final direction = p.text('direction');
    final (alignment, widthFactor, heightFactor) = switch (direction) {
      'down' => (Alignment.topCenter, 1.0, factor),
      'left' => (Alignment.centerRight, factor, 1.0),
      'right' => (Alignment.centerLeft, factor, 1.0),
      _ => (Alignment.bottomCenter, 1.0, factor),
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
