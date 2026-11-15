import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../../../../contract/model_3d_source.dart';
import '../../../../util/props_resolver.dart';
import 'model_3d_frame_clock.dart';
import 'model_3d_props.dart';

/// Owns renderer-independent morph easing and intermittent blink frames.
final class Model3dExpressions {
  Model3dExpressions({
    required TickerProvider vsync,
    required int? frameRate,
    required this.onChanged,
  }) {
    _clock = Model3dFrameClock(vsync: vsync, rate: frameRate, onTick: _tick);
  }

  final void Function(Map<String, double>) onChanged;
  late final Model3dFrameClock _clock;
  final _random = math.Random();
  Map<String, double> _weights = {};
  Map<String, double> _from = {};
  Map<String, double> _target = {};
  Duration _duration = Duration.zero;
  Duration _morphElapsed = Duration.zero;
  Duration _last = Duration.zero;
  bool _morphing = false;
  bool _active = true;
  ({String target, int every, int duration})? _blink;
  Timer? _wait;
  Duration? _blinkElapsed;
  final _restoreTargets = <String>{};

  void update(Object? raw, Duration duration) {
    final target = <String, double>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final value = PropsResolver.number(entry.value);
        if (entry.key is String && value != null && value >= 0 && value <= 1) {
          target[entry.key as String] = value;
        }
      }
    }
    if (mapEquals(target, _target)) return;
    _from = {
      for (final key in {..._weights.keys, ...target.keys})
        key: _weights[key] ?? 0,
    };
    _target = target;
    _duration = duration;
    _morphElapsed = Duration.zero;
    _morphing = true;
    if (duration == Duration.zero && _active) _tick(_last);
    _start();
  }

  void setBlink(Object? raw) {
    final map = raw is Map ? raw : const {};
    final every = PropsResolver.integer(map['every']) ?? 4000;
    final duration = PropsResolver.integer(map['duration']) ?? 150;
    final next = (raw == true || raw is Map) && every > 0 && duration > 0
        ? (
            target: PropsResolver.text(map['target']) ?? 'blink',
            every: every,
            duration: duration,
          )
        : null;
    if (next == _blink) return;
    final old = _blink;
    _wait?.cancel();
    _wait = null;
    _blink = next;
    if (_blinkElapsed != null && old != null) {
      if (_active) {
        onChanged({..._weights, old.target: _weights[old.target] ?? 0});
      } else {
        _restoreTargets.add(old.target);
      }
    }
    _blinkElapsed = null;
    if (!_morphing) _clock.stop();
    _schedule();
  }

  void _schedule() {
    if (!_active || _blink == null || _wait != null || _blinkElapsed != null) {
      return;
    }
    final blink = _blink!;
    _wait = Timer(
      Duration(
        milliseconds: (blink.every * (0.7 + _random.nextDouble() * 0.6))
            .round(),
      ),
      () {
        _wait = null;
        if (!_active || _blink != blink) return;
        _blinkElapsed = Duration.zero;
        _start();
      },
    );
  }

  void _start() {
    if (!_active || _clock.isActive || (!_morphing && _blinkElapsed == null)) {
      return;
    }
    _last = Duration.zero;
    _clock.start();
  }

  void _tick(Duration elapsed) {
    final dt = elapsed - _last;
    _last = elapsed;
    if (_morphing) {
      _morphElapsed += dt;
      final t = _duration.inMicroseconds <= 0
          ? 1.0
          : (_morphElapsed.inMicroseconds / _duration.inMicroseconds).clamp(
              0.0,
              1.0,
            );
      final eased = 1 - (1 - t) * (1 - t);
      _weights = {
        for (final entry in _from.entries)
          entry.key:
              entry.value + ((_target[entry.key] ?? 0) - entry.value) * eased,
      };
      _morphing = t < 1;
    }
    final output = Map.of(_weights);
    final blink = _blink;
    if (_blinkElapsed != null && blink != null) {
      _blinkElapsed = _blinkElapsed! + dt;
      final t = (_blinkElapsed!.inMicroseconds / (blink.duration * 1000)).clamp(
        0.0,
        1.0,
      );
      final pulse = 1 - (2 * t - 1).abs();
      final base = output[blink.target] ?? 0;
      output[blink.target] = base + (1 - base) * pulse;
      if (t >= 1) {
        _blinkElapsed = null;
        _schedule();
      }
    }
    if (output.isNotEmpty) onChanged(Map.unmodifiable(output));
    if (!_morphing && _blinkElapsed == null) _clock.stop();
  }

  void setActive(bool active) {
    if (_active == active) return;
    _active = active;
    if (!active) {
      _clock.stop();
      _wait?.cancel();
      _wait = null;
    } else {
      if (_restoreTargets.isNotEmpty) {
        onChanged({
          ..._weights,
          for (final name in _restoreTargets) name: _weights[name] ?? 0,
        });
        _restoreTargets.clear();
      }
      _start();
      _schedule();
    }
  }

  void reset() {
    _clock.stop();
    _wait?.cancel();
    _wait = null;
    _blink = null;
    _restoreTargets.clear();
    _blinkElapsed = null;
    _morphing = false;
    _weights = {};
    _from = {};
    _target = {};
  }

  void dispose() {
    _wait?.cancel();
    _clock.dispose();
  }
}

Model3dLayer? parseModel3dLayer(Object? raw) {
  if (raw is! Map) return null;
  final clip = PropsResolver.text(raw['clip']);
  if (clip == null || clip.isEmpty) return null;
  final weight = PropsResolver.number(raw['weight']);
  return Model3dLayer(
    clip: clip,
    loop: PropsResolver.flag(raw['loop']) ?? false,
    weight: weight != null ? weight.clamp(0, 1) : 1,
  );
}

Model3dLookAt? parseModel3dLookAt(Object? raw) {
  if (raw is! Map) return null;
  double number(String key, double fallback, double min, double max) {
    final n = PropsResolver.number(raw[key]);
    return n != null ? n.clamp(min, max) : fallback;
  }

  final target = raw['target'] ?? 'camera';
  final point = parseModel3dPoint(target, coerceStrings: true);
  if (target != 'camera' && target != 'pointer' && point == null) return null;
  return Model3dLookAt(
    bone: PropsResolver.text(raw['bone']) ?? 'head',
    target: point != null
        ? Model3dLookAtTarget.point
        : target == 'pointer'
        ? Model3dLookAtTarget.pointer
        : Model3dLookAtTarget.camera,
    point: point,
    weight: number('weight', 1, 0, 1),
    maxYaw: number('max_yaw', 60, 0, 180),
    maxPitch: number('max_pitch', 30, 0, 90),
    duration: Duration(
      milliseconds: number('duration', 150, 0, 2147483647).round(),
    ),
  );
}
