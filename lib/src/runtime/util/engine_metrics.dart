import 'package:flutter/widgets.dart';

import '../engine_presentation.dart';

/// Supplies the responsive dimension scale used by property decoders.
///
/// Ratios, colors, durations, and enums deliberately do not consume this scale.
class EngineMetrics extends InheritedWidget {
  const EngineMetrics({super.key, required this.scale, required super.child});

  final double scale;

  /// Scaling policy comes from the boot-injected [SduiScaling] — templates
  /// are authored against its `baseWidth` (the design frame width), scaled
  /// down to `minScale` on narrow devices, and never upscaled beyond
  /// `maxScale` (extra width becomes breathing room by design).
  static double scaleForWidth(double width) {
    final scaling = EnginePresentation.value.scaling;
    if (!width.isFinite || width <= 0) return scaling.maxScale;
    return (width / scaling.baseWidth).clamp(
      scaling.minScale,
      scaling.maxScale,
    );
  }

  static double scaleOf(BuildContext context) {
    final metrics = context.dependOnInheritedWidgetOfExactType<EngineMetrics>();
    return metrics?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(EngineMetrics oldWidget) => scale != oldWidget.scale;
}
