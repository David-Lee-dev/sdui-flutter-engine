import 'dart:math' as math;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

import '../_base.dart';

part 'haptic_presets.dart';

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

/// A named preset: transient [taps], optionally over a continuous vibration
/// shaped by the [intensity] and [sharpness] curves.
///
/// Curve points are (milliseconds from the pattern start, 0–1).
class HapticPattern {
  const HapticPattern({
    this.taps = const [],
    this.intensity = const [],
    this.sharpness = const [],
  });

  final List<HapticPulse> taps;
  final List<(int, double)> intensity;
  final List<(int, double)> sharpness;

  /// Until the last tap or curve point, whichever is later.
  Duration get duration {
    var tapsEnd = Duration.zero;
    for (final tap in taps) {
      tapsEnd += tap.delay;
    }
    final curvesEnd = [
      for (final curve in [intensity, sharpness])
        if (curve.isNotEmpty) curve.last.$1,
    ].fold(0, math.max);
    return Duration(milliseconds: math.max(tapsEnd.inMilliseconds, curvesEnd));
  }
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

  /// Whether the device can [play] a continuous pattern.
  Future<bool> supportsContinuous();

  /// Starts [pattern] natively — taps and curves together — and returns
  /// without waiting for it to finish.
  Future<void> play(HapticPattern pattern);

  /// Stops a pattern started by [play].
  Future<void> stop();
}

/// Maps engine haptic strengths to Flutter platform feedback and native taps
/// to the plugin channel.
class SystemHapticPlayer implements HapticPlayer {
  SystemHapticPlayer();

  /// The engine's player; asks the device for tap and continuous support once
  /// per process.
  static final shared = SystemHapticPlayer();

  static const _channel = MethodChannel('sdui_engine/haptic');

  Future<bool>? _supported;
  Future<bool>? _continuous;

  @override
  Future<bool> supportsTaps() => _supported ??= _askSupport('isSupported');

  @override
  Future<bool> supportsContinuous() =>
      _continuous ??= _askSupport('isContinuousSupported');

  /// No plugin (tests, web, desktop) or a platform failure means unsupported.
  static Future<bool> _askSupport(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
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

  /// Sends taps at absolute times (ms from start) so the native side can
  /// schedule them in one pattern with the curves.
  @override
  Future<void> play(HapticPattern pattern) {
    var at = 0;
    final taps = [
      for (final tap in pattern.taps)
        [at += tap.delay.inMilliseconds, tap.intensity, tap.sharpness],
    ];
    return _channel.invokeMethod<void>('play', {
      'taps': taps,
      'intensity': [
        for (final (ms, v) in pattern.intensity) [ms, v],
      ],
      'sharpness': [
        for (final (ms, v) in pattern.sharpness) [ms, v],
      ],
    });
  }

  @override
  Future<void> stop() => _channel.invokeMethod<void>('stop');

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

/// Tap versions of the legacy names templates use; intensity tiers light 0.5 /
/// medium 0.7 / strong 1.0 follow Android guidance, values to be tuned on device.
const Map<String, List<HapticPulse>> legacyPresets = {
  'light': [HapticPulse(intensity: 0.5)],
  'success': [
    HapticPulse(intensity: 0.5),
    HapticPulse(intensity: 0.7, delay: Duration(milliseconds: 70)),
  ],
  'warning': [
    HapticPulse(intensity: 0.7),
    HapticPulse(intensity: 0.7, delay: Duration(milliseconds: 130)),
  ],
  'error': [
    HapticPulse(intensity: 1.0),
    HapticPulse(intensity: 1.0, delay: Duration(milliseconds: 130)),
    HapticPulse(intensity: 1.0, delay: Duration(milliseconds: 130)),
  ],
};

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

    // Without the support it needs a preset plays nothing; a continuous one
    // never falls back to just its taps.
    final basic = basicPresets[variant];
    if (basic != null) {
      if (await _player.supportsTaps()) {
        await HapticSemantics.tap(
          basic,
          player: _player,
          isCancelled: () => ctx.isCancelled,
        );
      }
      return null;
    }

    final continuous = continuousPresets[variant];
    if (continuous != null) {
      if (await _player.supportsContinuous()) {
        await _playContinuous(continuous, ctx);
      }
      return null;
    }

    // Without tap support a legacy name keeps its platform feedback below.
    final legacy = legacyPresets[variant];
    if (legacy != null && await _player.supportsTaps()) {
      await HapticSemantics.tap(
        legacy,
        player: _player,
        isCancelled: () => ctx.isCancelled,
      );
      return null;
    }

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

  static const _cancelPoll = Duration(milliseconds: 50);

  /// Starts [pattern] natively and holds the run for its length, stopping
  /// the vibration as soon as the run is cancelled.
  Future<void> _playContinuous(HapticPattern pattern, DriverContext ctx) async {
    await _player.play(pattern);

    var left = pattern.duration;
    while (left > Duration.zero) {
      final step = left < _cancelPoll ? left : _cancelPoll;
      await Future<void>.delayed(step);
      left -= step;
      if (ctx.isCancelled) {
        await _player.stop();
        return;
      }
    }
  }

  static String? _str(Object? value) => value is String ? value : null;
}
