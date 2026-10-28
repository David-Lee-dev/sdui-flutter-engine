import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

import '_base.dart';

/// Selects the platform feedback strength for a haptic step.
enum HapticLevel { light, medium, strong }

/// One short transient tap of a `pattern`, played [delay] after the previous one.
class HapticPulse {
  const HapticPulse({
    this.intensity = 1.0,
    this.sharpness = 0.5,
    this.delay = Duration.zero,
  });

  /// 0–1.
  final double intensity;

  /// 0–1; only iOS can vary it.
  final double sharpness;
  final Duration delay;
}

/// Plays one haptic impulse at the requested strength.
abstract class HapticPlayer {
  Future<void> impact(HapticLevel level);
  Future<void> selection();
  Future<void> vibrate();

  /// Whether the device can play [tap].
  Future<bool> supportsTaps();

  /// Plays one native transient tap.
  Future<void> tap(double intensity, double sharpness);
}

/// Maps engine haptic strengths to Flutter platform feedback and native taps
/// to the plugin channel.
class SystemHapticPlayer implements HapticPlayer {
  SystemHapticPlayer();

  /// The engine's player; asks the device for tap support once per process.
  static final shared = SystemHapticPlayer();

  static const _channel = MethodChannel('sdui_engine/haptic');

  Future<bool>? _supported;

  @override
  Future<bool> supportsTaps() => _supported ??= _askSupport();

  /// No plugin (tests, web, desktop) or a platform failure means unsupported.
  static Future<bool> _askSupport() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> tap(double intensity, double sharpness) =>
      _channel.invokeMethod<void>('tap', {
        'intensity': intensity,
        'sharpness': sharpness,
      });

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

/// The semantic haptic vocabulary (`success` / `warning` / `error`) and its
/// rhythms, plus the native tap `pattern`s templates spell out.
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
  /// @param player - what fires the impulses; the engine's shared player by default
  /// @param isCancelled - checked between pulses so a disposed caller stops mid-pattern
  /// @returns whether [variant] named a known pattern
  static Future<bool> play(
    String? variant, {
    HapticLevel? intensity,
    HapticPlayer? player,
    bool Function()? isCancelled,
  }) async {
    final pattern = _patterns[variant];
    if (pattern == null) return false;
    player ??= SystemHapticPlayer.shared;

    final base = intensity ?? pattern.base;
    for (var i = 0; i < pattern.offsets.length; i++) {
      if (isCancelled?.call() ?? false) return true;
      if (i > 0) await Future<void>.delayed(pattern.gap);
      await player.impact(_shift(base, pattern.offsets[i]));
    }
    return true;
  }

  /// Reads a template `pattern` into pulses, clamping each value into range.
  ///
  /// @returns null unless [value] is a non-empty list of maps
  static List<HapticPulse>? pulses(Object? value) {
    if (value is! List || value.isEmpty) return null;
    if (value.any((p) => p is! Map)) return null;

    return [
      for (final Map p in value)
        HapticPulse(
          intensity: _unit(p['intensity'], 1.0),
          sharpness: _unit(p['sharpness'], 0.5),
          delay: Duration(
            milliseconds: math.max(0, _num(p['delay'])?.round() ?? 0),
          ),
        ),
    ];
  }

  /// Plays [pulses] as native taps, each after its delay.
  ///
  /// An intensity-0 pulse only keeps its delay: Android plays scale 0 as the
  /// weakest perceptible click rather than silence, so it is never sent.
  ///
  /// @param isCancelled - checked before each pulse and after each delay
  static Future<void> tap(
    List<HapticPulse> pulses, {
    required HapticPlayer player,
    bool Function()? isCancelled,
  }) async {
    bool cancelled() => isCancelled?.call() ?? false;

    for (final pulse in pulses) {
      if (cancelled()) return;
      if (pulse.delay > Duration.zero) await Future<void>.delayed(pulse.delay);
      if (cancelled()) return;
      if (pulse.intensity == 0) continue;
      await player.tap(pulse.intensity, pulse.sharpness);
    }
  }

  /// Reads a strength name. Null when [value] is not one.
  static HapticLevel? level(String? value) => switch (value) {
    'light' => HapticLevel.light,
    'medium' => HapticLevel.medium,
    'strong' || 'heavy' => HapticLevel.strong,
    _ => null,
  };

  static double _unit(Object? value, double fallback) =>
      _num(value)?.toDouble().clamp(0.0, 1.0) ?? fallback;

  static num? _num(Object? value) => value is num ? value : null;

  static HapticLevel _shift(HapticLevel base, int delta) {
    final i = (base.index + delta).clamp(0, HapticLevel.values.length - 1);
    return HapticLevel.values[i];
  }
}

/// Plays a single haptic or a timed pattern without retaining widget state.
class HapticDriver extends Driver {
  const HapticDriver({HapticPlayer? player}) : _custom = player;

  final HapticPlayer? _custom;

  HapticPlayer get _player => _custom ?? SystemHapticPlayer.shared;

  @override
  String get type => 'sys_haptic';

  @override
  Future<Object?> run(DriverContext ctx) async {
    if (ctx.isCancelled) return null;

    final pulses = HapticSemantics.pulses(ctx.params['pattern']);
    if (pulses != null && await _player.supportsTaps()) {
      await HapticSemantics.tap(
        pulses,
        player: _player,
        isCancelled: () => ctx.isCancelled,
      );
      return null;
    }

    final variant = _str(ctx.params['variant']);

    final played = await HapticSemantics.play(
      variant,
      intensity: HapticSemantics.level(_str(ctx.params['intensity'])),
      player: _player,
      isCancelled: () => ctx.isCancelled,
    );
    if (played) return null;

    switch (variant) {
      case 'light':
        await _player.impact(HapticLevel.light);
      case 'medium':
        await _player.impact(HapticLevel.medium);
      case 'heavy':
      case 'strong':
        await _player.impact(HapticLevel.strong);
      case 'selection':
        await _player.selection();
      case 'vibrate':
        await _player.vibrate();
    }
    return null;
  }

  static String? _str(Object? value) => value is String ? value : null;
}
