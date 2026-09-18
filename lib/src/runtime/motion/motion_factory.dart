import '_base.dart';
import 'atom/fade.dart';
import 'atom/blur.dart';
import 'atom/move.dart';
import 'atom/reveal.dart';
import 'atom/rotate.dart';
import 'atom/saturate.dart';
import 'atom/scale.dart';
import 'atom/shimmer.dart';
import 'atom/tint.dart';

/// Owns the process-wide mapping from motion names to implementations.
final class MotionFactory {
  const MotionFactory._();

  static const Map<String, Motion> _builtins = {
    'fade': FadeMotion(),
    'move': MoveMotion(),
    'scale': ScaleMotion(),
    'rotate': RotateMotion(),
    'reveal': RevealMotion(),
    'tint': TintMotion(),
    'blur': BlurMotion(),
    'shimmer': ShimmerMotion(),
    'saturate': SaturateMotion(),
  };

  static final Map<String, Motion> _motions = {..._builtins};

  static bool _frozen = false;

  /// Prevents further motion registration for the current configuration.
  static void freeze() => _frozen = true;

  /// Installs or replaces [motion] before the factory is frozen.
  static void register(Motion motion) {
    if (_frozen) {
      throw StateError('MotionFactory is frozen — register before freeze().');
    }
    _motions[motion.type] = motion;
  }

  /// Registers each motion in iteration order.
  static void registerAll(Iterable<Motion> motions) {
    for (final motion in motions) {
      register(motion);
    }
  }

  /// Restores the built-in motions and unfreezes the factory.
  static void reset() {
    _frozen = false;
    _motions
      ..clear()
      ..addAll(_builtins);
  }

  /// Returns the motion registered for [type].
  ///
  /// Throws [StateError] when [type] is unknown.
  static Motion resolve(String type) {
    final motion = _motions[type];
    if (motion == null) {
      throw StateError('Unknown motion type: "$type".');
    }
    return motion;
  }
}
