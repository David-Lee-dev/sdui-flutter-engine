import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';

import '../../../../util/props_resolver.dart';

/// Which drag axes rotate the camera.
enum Model3dRotate { none, horizontal, vertical, free }

/// The `controls` prop of a `model_3d`: how gestures move the camera.
final class Model3dControls {
  const Model3dControls({
    this.rotate = Model3dRotate.none,
    this.minPitch = -60,
    this.maxPitch = 60,
    this.minZoom,
    this.maxZoom,
    this.sensitivity = 1,
    this.inertia = true,
    this.returnAfter,
  });

  /// Gestures off: the model passes every pointer to its ancestors.
  static const none = Model3dControls();

  final Model3dRotate rotate;

  /// Pitch limits in degrees.
  final double minPitch;
  final double maxPitch;

  /// Pinch zoom limits; both null turns pinch zoom off.
  final double? minZoom;
  final double? maxZoom;

  /// Multiplies the base rate of half a degree per logical pixel.
  final double sensitivity;

  /// Whether a fling keeps the camera turning and slowing down.
  final bool inertia;

  /// When set, the camera eases back to the template's `camera` over this
  /// long after the gesture ends; otherwise it stays where it was left.
  final Duration? returnAfter;

  bool get zooms {
    final min = minZoom;
    final max = maxZoom;
    return min != null && max != null && max > min;
  }

  bool get active => rotate != Model3dRotate.none || zooms;

  @override
  bool operator ==(Object other) =>
      other is Model3dControls &&
      other.rotate == rotate &&
      other.minPitch == minPitch &&
      other.maxPitch == maxPitch &&
      other.minZoom == minZoom &&
      other.maxZoom == maxZoom &&
      other.sensitivity == sensitivity &&
      other.inertia == inertia &&
      other.returnAfter == returnAfter;

  @override
  int get hashCode => Object.hash(
    rotate,
    minPitch,
    maxPitch,
    minZoom,
    maxZoom,
    sensitivity,
    inertia,
    returnAfter,
  );

  /// Parses `controls`; `interactive: true` without `controls` means free
  /// rotation.
  static Model3dControls parse(Object? raw, {required bool interactive}) {
    if (raw is! Map) {
      return interactive
          ? const Model3dControls(rotate: Model3dRotate.free)
          : none;
    }
    final rotate = switch (PropsResolver.text(raw['rotate'])) {
      'none' => Model3dRotate.none,
      'horizontal' => Model3dRotate.horizontal,
      'vertical' => Model3dRotate.vertical,
      _ => Model3dRotate.free,
    };
    final minPitch = PropsResolver.number(raw['min_pitch']) ?? -60;
    final maxPitch = PropsResolver.number(raw['max_pitch']) ?? 60;
    // Either bound turns pinch on; the absent one is the framed view (1).
    final minZoom = PropsResolver.number(raw['min_zoom']);
    final maxZoom = PropsResolver.number(raw['max_zoom']);
    final zooms = minZoom != null || maxZoom != null;
    final returnMs = PropsResolver.integer(raw['return_duration']);
    return Model3dControls(
      rotate: rotate,
      minPitch: math.min(minPitch, maxPitch),
      maxPitch: math.max(minPitch, maxPitch),
      minZoom: zooms ? math.min(minZoom ?? 1, maxZoom ?? 1) : null,
      maxZoom: zooms ? math.max(minZoom ?? 1, maxZoom ?? 1) : null,
      sensitivity: PropsResolver.number(raw['sensitivity']) ?? 1,
      inertia: PropsResolver.flag(raw['inertia']) ?? true,
      returnAfter: returnMs == null || returnMs <= 0
          ? null
          : Duration(milliseconds: returnMs),
    );
  }
}

/// Parses the `camera` prop: the resting camera and how long a change to it
/// takes.
(Model3dCamera, Duration) parseModel3dCamera(Object? raw) {
  if (raw is! Map) {
    return (const Model3dCamera(), const Duration(milliseconds: 300));
  }
  return (
    Model3dCamera(
      yaw: PropsResolver.number(raw['yaw']) ?? 0,
      pitch: PropsResolver.number(raw['pitch']) ?? 0,
      zoom: PropsResolver.number(raw['zoom']) ?? 1,
    ),
    Duration(milliseconds: PropsResolver.integer(raw['duration']) ?? 300),
  );
}

/// Parses `auto_rotate`: degrees per second, `true` for 30, off otherwise.
double parseAutoRotate(Object? raw) {
  if (raw is num) return raw.toDouble();
  return PropsResolver.flag(raw) == true ? 30 : 0;
}

/// Turns gestures, inertia, auto-rotation and changes of the resting camera
/// into one [Model3dCamera] per frame.
///
/// The camera is the resting camera (`camera`, plus accumulated
/// auto-rotation) with the user's offset on top. Gestures move the offset;
/// `return_duration` eases it back to zero.
final class Model3dCameraRig {
  Model3dCameraRig({
    required TickerProvider vsync,
    required Model3dCamera rest,
    required this.controls,
    required this.autoRotate,
    required this.onChanged,
  }) : _restTo = rest,
       _restFrom = rest {
    _ticker = vsync.createTicker(_tick);
    _syncTicker();
  }

  /// Base rotation rate: degrees per logical pixel at `sensitivity: 1`.
  static const degreesPerPixel = 0.5;

  /// Fling velocity decay rate per second.
  static const _friction = 5.0;

  Model3dControls controls;

  /// Degrees per second; 0 is off.
  double autoRotate;

  final ValueChanged<Model3dCamera> onChanged;

  late final Ticker _ticker;

  /// The previous tick's time; null until the next tick sets it, which then
  /// moves nothing.
  Duration? _last;

  Model3dCamera _restFrom;
  Model3dCamera _restTo;
  Duration _restDuration = Duration.zero;
  double _restT = 1;

  double _spin = 0;
  double _yaw = 0;
  double _pitch = 0;
  double _zoom = 1;
  double _zoomAtStart = 1;

  double _yawVelocity = 0;
  double _pitchVelocity = 0;

  bool _dragging = false;
  bool _returning = false;
  double _returnT = 1;
  (double, double, double) _returnFrom = (0, 0, 1);

  Model3dCamera? _sent;

  Model3dCamera get rest {
    final t = Curves.easeInOut.transform(_restT);
    return Model3dCamera(
      yaw: _lerp(_restFrom.yaw, _restTo.yaw, t),
      pitch: _lerp(_restFrom.pitch, _restTo.pitch, t),
      zoom: _lerp(_restFrom.zoom, _restTo.zoom, t),
    );
  }

  /// The camera to render now.
  Model3dCamera get camera {
    // The offsets are clamped as gestures set them, so the template's own
    // `camera` is never clamped.
    final base = rest;
    return Model3dCamera(
      yaw: _wrap(base.yaw + _spin + _yaw),
      pitch: base.pitch + _pitch,
      zoom: base.zoom * _zoom,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static double _wrap(double degrees) {
    final wrapped = degrees % 360;
    return wrapped > 180 ? wrapped - 360 : wrapped;
  }

  /// Moves the resting camera to [to] over [duration].
  void setRest(Model3dCamera to, Duration duration) {
    if (to == _restTo) return;
    _restFrom = rest;
    _restTo = to;
    _restDuration = duration;
    _restT = duration == Duration.zero ? 1 : 0;
    _emit();
    _syncTicker();
  }

  void update({required Model3dControls controls, required double autoRotate}) {
    this.controls = controls;
    this.autoRotate = autoRotate;
    _emit();
    _syncTicker();
  }

  void dragStart() {
    _dragging = true;
    _returning = false;
    _yawVelocity = 0;
    _pitchVelocity = 0;
    _zoomAtStart = _zoom;
    _syncTicker();
  }

  /// Rotates by a drag of [delta] logical pixels, on the axes `rotate`
  /// allows: dragging right turns the model's front to the right, dragging
  /// down tips its top toward the viewer.
  void dragUpdate(Offset delta) {
    final rate = degreesPerPixel * controls.sensitivity;
    if (_rotatesYaw) _yaw -= delta.dx * rate;
    if (_rotatesPitch) {
      final base = rest.pitch;
      _pitch =
          (base + _pitch + delta.dy * rate).clamp(
            controls.minPitch,
            controls.maxPitch,
          ) -
          base;
    }
    _emit();
  }

  /// Scales the zoom by [scale] relative to the gesture start.
  void pinchUpdate(double scale) {
    if (!controls.zooms) return;
    final base = rest.zoom;
    _zoom =
        (base * _zoomAtStart * scale).clamp(
          controls.minZoom!,
          controls.maxZoom!,
        ) /
        base;
    _emit();
  }

  /// Ends a gesture released at [velocity] logical pixels per second.
  void dragEnd(Offset velocity) {
    _dragging = false;
    if (controls.returnAfter != null) {
      _returning = true;
      _returnT = 0;
      _returnFrom = (_yaw, _pitch, _zoom);
    } else if (controls.inertia) {
      final rate = degreesPerPixel * controls.sensitivity;
      if (_rotatesYaw) _yawVelocity = -velocity.dx * rate;
      if (_rotatesPitch) _pitchVelocity = velocity.dy * rate;
    }
    _syncTicker();
  }

  bool get _rotatesYaw =>
      controls.rotate == Model3dRotate.horizontal ||
      controls.rotate == Model3dRotate.free;

  bool get _rotatesPitch =>
      controls.rotate == Model3dRotate.vertical ||
      controls.rotate == Model3dRotate.free;

  bool get _coasting => _yawVelocity != 0 || _pitchVelocity != 0;

  bool get _busy =>
      _restT < 1 || _returning || _coasting || (autoRotate != 0 && !_dragging);

  void _syncTicker() {
    if (_busy && !_ticker.isActive) {
      _last = null;
      _ticker.start();
    } else if (!_busy && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    final last = _last;
    _last = elapsed;
    if (last == null) return;
    final dt = (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0) return;

    if (_restT < 1) {
      _restT = _restDuration == Duration.zero
          ? 1
          : math.min(
              1,
              _restT +
                  dt *
                      Duration.microsecondsPerSecond /
                      _restDuration.inMicroseconds,
            );
    }

    if (_returning) {
      final duration = controls.returnAfter;
      _returnT = duration == null
          ? 1
          : math.min(
              1,
              _returnT +
                  dt * Duration.microsecondsPerSecond / duration.inMicroseconds,
            );
      final k = 1 - Curves.easeOut.transform(_returnT);
      _yaw = _returnFrom.$1 * k;
      _pitch = _returnFrom.$2 * k;
      _zoom = 1 + (_returnFrom.$3 - 1) * k;
      if (_returnT >= 1) _returning = false;
    }

    if (_coasting) {
      _yaw += _yawVelocity * dt;
      if (_pitchVelocity != 0) {
        final base = rest.pitch;
        final pitch = base + _pitch + _pitchVelocity * dt;
        final clamped = pitch.clamp(controls.minPitch, controls.maxPitch);
        if (clamped != pitch) _pitchVelocity = 0;
        _pitch = clamped - base;
      }
      final decay = math.exp(-_friction * dt);
      _yawVelocity *= decay;
      _pitchVelocity *= decay;
      if (_yawVelocity.abs() < 2) _yawVelocity = 0;
      if (_pitchVelocity.abs() < 2) _pitchVelocity = 0;
    } else if (!_dragging && autoRotate != 0) {
      _spin = _wrap(_spin + autoRotate * dt);
    }

    _emit();
    _syncTicker();
  }

  void _emit() {
    final camera = this.camera;
    if (camera == _sent) return;
    _sent = camera;
    onChanged(camera);
  }

  /// Counts the next tick from itself. A muted ticker still runs its clock,
  /// so after a hidden view shows again the first tick would otherwise play
  /// the hidden time at once.
  void resume() => _last = null;

  void dispose() => _ticker.dispose();
}

/// Routes gestures over the model to [rig] through the gesture arena: a
/// horizontal-only model leaves vertical drags to an enclosing scroll view,
/// and taps always reach ancestors.
///
/// It always builds one [GestureDetector], only swapping its callbacks, so
/// enabling it never remounts the renderer's view below.
final class Model3dGestureLayer extends StatelessWidget {
  const Model3dGestureLayer({
    super.key,
    required this.rig,
    required this.controls,
    required this.enabled,
    required this.child,
  });

  final Model3dCameraRig rig;
  final Model3dControls controls;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final on = enabled && controls.active;
    final zooms = on && controls.zooms;
    final rotate = on && !zooms ? controls.rotate : Model3dRotate.none;
    final horizontal = rotate == Model3dRotate.horizontal;
    final vertical = rotate == Model3dRotate.vertical;
    final free = rotate == Model3dRotate.free;
    return GestureDetector(
      behavior: on ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onScaleStart: zooms ? (_) => rig.dragStart() : null,
      onScaleUpdate: zooms
          ? (details) {
              if (details.pointerCount > 1) {
                rig.pinchUpdate(details.scale);
              } else {
                rig.dragUpdate(details.focalPointDelta);
              }
            }
          : null,
      onScaleEnd: zooms
          ? (details) => rig.dragEnd(details.velocity.pixelsPerSecond)
          : null,
      onHorizontalDragStart: horizontal ? (_) => rig.dragStart() : null,
      onHorizontalDragUpdate: horizontal
          ? (details) => rig.dragUpdate(Offset(details.delta.dx, 0))
          : null,
      onHorizontalDragEnd: horizontal
          ? (details) => rig.dragEnd(details.velocity.pixelsPerSecond)
          : null,
      onHorizontalDragCancel: horizontal
          ? () => rig.dragEnd(Offset.zero)
          : null,
      onVerticalDragStart: vertical ? (_) => rig.dragStart() : null,
      onVerticalDragUpdate: vertical
          ? (details) => rig.dragUpdate(Offset(0, details.delta.dy))
          : null,
      onVerticalDragEnd: vertical
          ? (details) => rig.dragEnd(details.velocity.pixelsPerSecond)
          : null,
      onVerticalDragCancel: vertical ? () => rig.dragEnd(Offset.zero) : null,
      onPanStart: free ? (_) => rig.dragStart() : null,
      onPanUpdate: free ? (details) => rig.dragUpdate(details.delta) : null,
      onPanEnd: free
          ? (details) => rig.dragEnd(details.velocity.pixelsPerSecond)
          : null,
      onPanCancel: free ? () => rig.dragEnd(Offset.zero) : null,
      child: child,
    );
  }
}
