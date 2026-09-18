import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

import '_base.dart';

/// Selects the platform feedback strength for a haptic step.
enum HapticLevel { light, medium, strong }

/// Plays one haptic impulse at the requested strength.
abstract class HapticPlayer {
  Future<void> impact(HapticLevel level);
  Future<void> selection();
  Future<void> vibrate();
}

/// Maps engine haptic strengths to Flutter platform feedback.
class SystemHapticPlayer implements HapticPlayer {
  const SystemHapticPlayer();

  @override
  Future<void> impact(HapticLevel level) => switch (level) {
    HapticLevel.light => HapticFeedback.lightImpact(),
    HapticLevel.medium => HapticFeedback.mediumImpact(),
    HapticLevel.strong =>
      defaultTargetPlatform == TargetPlatform.android
          ? HapticFeedback.vibrate()
          : HapticFeedback.heavyImpact(),
  };

  @override
  Future<void> selection() => HapticFeedback.selectionClick();

  @override
  Future<void> vibrate() => HapticFeedback.vibrate();
}

class _Pattern {
  const _Pattern(this.base, this.offsets, this.gap);

  final HapticLevel base;
  final List<int> offsets;
  final Duration gap;
}

/// The semantic haptic vocabulary (`success` / `warning` / `error`) and its rhythms.
///
/// Lives beside [HapticDriver] rather than inside it because callers outside the
/// action flow reach for the same names — the app's game widgets fire these
/// directly. A second copy of the rhythm would drift, and the drift only shows on
/// a device.
class HapticSemantics {
  const HapticSemantics._();

  static const _patterns = <String, _Pattern>{
    'success': _Pattern(HapticLevel.light, [0, 1], Duration(milliseconds: 70)),
    'warning': _Pattern(HapticLevel.medium, [
      0,
      0,
    ], Duration(milliseconds: 130)),
    'error': _Pattern(HapticLevel.strong, [
      0,
      0,
      0,
    ], Duration(milliseconds: 130)),
  };

  /// Plays the rhythm named by [variant].
  ///
  /// @param variant - `success`, `warning` or `error`; any other name plays nothing
  /// @param intensity - overrides the pattern's base strength, keeping its rhythm
  /// @param player - what fires the impulses; tests pass a fake
  /// @param isCancelled - checked between pulses so a disposed caller stops mid-pattern
  /// @returns whether [variant] named a known pattern
  static Future<bool> play(
    String? variant, {
    HapticLevel? intensity,
    HapticPlayer player = const SystemHapticPlayer(),
    bool Function()? isCancelled,
  }) async {
    final pattern = _patterns[variant];
    if (pattern == null) return false;

    final base = intensity ?? pattern.base;
    for (var i = 0; i < pattern.offsets.length; i++) {
      if (isCancelled?.call() ?? false) return true;
      if (i > 0) await Future<void>.delayed(pattern.gap);
      await player.impact(_shift(base, pattern.offsets[i]));
    }
    return true;
  }

  /// Reads a strength name. Null when [value] is not one.
  static HapticLevel? level(String? value) => switch (value) {
    'light' => HapticLevel.light,
    'medium' => HapticLevel.medium,
    'strong' || 'heavy' => HapticLevel.strong,
    _ => null,
  };

  static HapticLevel _shift(HapticLevel base, int delta) {
    final i = (base.index + delta).clamp(0, HapticLevel.values.length - 1);
    return HapticLevel.values[i];
  }
}

/// Plays a single haptic or a timed pattern without retaining widget state.
class HapticDriver extends Driver {
  const HapticDriver({HapticPlayer player = const SystemHapticPlayer()})
    : _player = player;

  final HapticPlayer _player;

  @override
  String get type => 'sys_haptic';

  @override
  Future<Object?> run(DriverContext ctx) async {
    if (ctx.isCancelled) return null;
    final variant = _str(ctx.params['variant']);

    final played = await HapticSemantics.play(
      variant,
      intensity: HapticSemantics.level(_str(ctx.params['intensity'])),
      player: _player,
      isCancelled: () => ctx.isCancelled,
    );
    if (played) return null;

    switch (variant) {
      case 'medium':
        await _player.impact(HapticLevel.medium);
      case 'heavy':
      case 'strong':
        await _player.impact(HapticLevel.strong);
      case 'selection':
        await _player.selection();
      case 'vibrate':
        await _player.vibrate();
      default:
        await _player.impact(HapticLevel.light);
    }
    return null;
  }

  static String? _str(Object? value) => value is String ? value : null;
}
