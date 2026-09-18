import 'package:flutter/widgets.dart';

/// Supplies the responsive dimension scale used by property decoders.
///
/// Ratios, colors, durations, and enums deliberately do not consume this scale.
class EngineMetrics extends InheritedWidget {
  const EngineMetrics({super.key, required this.scale, required super.child});

  final double scale;

  /// Logical width the templates are authored against — the Figma frame width.
  ///
  /// Every pixel dimension in a template is a number read off that frame, so
  /// this must track the design file. A base narrower than the design renders
  /// those numbers oversized on any device below the design width, which is
  /// read on screen as unwanted wrapping and overflow rather than as a scale
  /// error.
  static const double _baseWidth = 390.0;

  /// Floor on the downscale, so captions stay legible on the narrowest phones.
  /// It bites below roughly 320dp — a device narrower than that renders larger
  /// than its share and has to be handled by the layout, not by this scale.
  static const double _minScale = 0.82;

  /// Templates are never upscaled. Width beyond the design frame becomes
  /// breathing room, which is what the design intends; growing every dimension
  /// would just re-crop the same layout on a bigger screen.
  static const double _maxScale = 1.0;

  static double scaleForWidth(double width) {
    if (!width.isFinite || width <= 0) return _maxScale;
    return (width / _baseWidth).clamp(_minScale, _maxScale);
  }

  static double scaleOf(BuildContext context) {
    final metrics = context.dependOnInheritedWidgetOfExactType<EngineMetrics>();
    return metrics?.scale ?? 1.0;
  }

  @override
  bool updateShouldNotify(EngineMetrics oldWidget) => scale != oldWidget.scale;
}
