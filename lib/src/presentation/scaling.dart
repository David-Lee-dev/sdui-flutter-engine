/// Responsive scaling configuration for template metrics.
///
/// Template dimensions are authored against [baseWidth]; at runtime they
/// scale with the device width, clamped to [minScale]..[maxScale]. Defaults
/// mirror the engine's tuned values (390-wide designs, 0.82..1.0).
final class SduiScaling {
  const SduiScaling({
    this.baseWidth = 390,
    this.minScale = 0.82,
    this.maxScale = 1.0,
  });

  final double baseWidth;
  final double minScale;
  final double maxScale;
}
