import 'package:flutter/widgets.dart';

import '../_base.dart';

const _blendTable = <String, BlendMode>{
  'src_atop': BlendMode.srcATop,
  'modulate': BlendMode.modulate,
  'overlay': BlendMode.overlay,
  'color': BlendMode.color,
  'screen': BlendMode.screen,
};

/// Interpolates a color overlay using a constrained set of blend modes.
final class TintMotion extends Motion {
  const TintMotion();

  @override
  String get type => 'tint';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    final begin = p.color('begin', const Color(0x66000000));
    final end = p.color('end', const Color(0x00000000));
    final blend = _blendTable[p.text('blend')] ?? BlendMode.srcATop;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(Color.lerp(begin, end, t) ?? end, blend),
      child: child,
    );
  }
}
