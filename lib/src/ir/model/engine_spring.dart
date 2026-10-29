/// Physical parameters of a `_morph._spring`.
///
/// [carriesVelocity] is false for effect springs: a retarget starts from rest
/// instead of handing the current velocity to the new simulation.
final class EngineSpringSpec {
  const EngineSpringSpec({
    required this.stiffness,
    required this.dampingRatio,
    this.mass = 1,
    this.carriesVelocity = true,
  });

  final double stiffness;
  final double dampingRatio;
  final double mass;
  final bool carriesVelocity;

  @override
  bool operator ==(Object other) =>
      other is EngineSpringSpec &&
      other.stiffness == stiffness &&
      other.dampingRatio == dampingRatio &&
      other.mass == mass &&
      other.carriesVelocity == carriesVelocity;

  @override
  int get hashCode =>
      Object.hash(stiffness, dampingRatio, mass, carriesVelocity);
}

/// Preset names accepted by `_morph._spring`.
abstract final class EngineSpringNames {
  static const Map<String, EngineSpringSpec> presets = {
    'spatial_fast': EngineSpringSpec(stiffness: 1400, dampingRatio: 0.8),
    'spatial_default': EngineSpringSpec(stiffness: 700, dampingRatio: 0.75),
    'spatial_slow': EngineSpringSpec(stiffness: 300, dampingRatio: 0.85),
    'effect_default': EngineSpringSpec(
      stiffness: 800,
      dampingRatio: 1,
      carriesVelocity: false,
    ),
  };
}
