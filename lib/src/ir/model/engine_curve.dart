/// Names accepted for motion and page-transition curves.
abstract final class EngineCurveNames {
  /// Material 3 easing names (since 0.9.0).
  static const Set<String> material3 = {
    'emphasized',
    'emphasized_decelerate',
    'emphasized_accelerate',
    'standard',
    'standard_decelerate',
    'standard_accelerate',
  };

  /// `EngineSpringNames.presets` used as a normalized 0 -> 1 curve (since
  /// 0.9.0).
  static const Set<String> spring = {
    'spatial_fast',
    'spatial_default',
    'spatial_slow',
    'effect_default',
  };

  static const Set<String> all = {
    'linear',
    'ease',
    'ease_in',
    'ease_out',
    'ease_in_out',
    'fast_out_slow_in',
    'bounce_out',
    'elastic_out',
    'decelerate',
    ...material3,
    ...spring,
  };
}
