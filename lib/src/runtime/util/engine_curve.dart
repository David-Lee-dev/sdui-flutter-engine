import 'package:flutter/widgets.dart';

/// Resolves a template curve name to a Flutter [Curve].
///
/// Names are snake_case (the v3 template convention) and map to the matching
/// [Curves] constant. Unknown names fall back to the given default so a bad
/// value degrades to linear motion rather than throwing.
final class EngineCurve {
  const EngineCurve._();

  static const Map<String, Curve> _curves = {
    'linear': Curves.linear,
    'ease': Curves.ease,
    'ease_in': Curves.easeIn,
    'ease_out': Curves.easeOut,
    'ease_in_out': Curves.easeInOut,
    'fast_out_slow_in': Curves.fastOutSlowIn,
    'bounce_out': Curves.bounceOut,
    'elastic_out': Curves.elasticOut,
    'decelerate': Curves.decelerate,
  };

  /// The [Curve] for [name], or [fallback] when the name is unknown/null.
  static Curve resolve(String? name, {Curve fallback = Curves.linear}) =>
      _curves[name] ?? fallback;
}
