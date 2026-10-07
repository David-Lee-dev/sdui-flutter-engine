import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Pointer origins are isolated by Navigator and consumed by a single push.
final class TransitionOrigins {
  static final _registries = Expando<TransitionOrigins>();

  static TransitionOrigins of(NavigatorState navigator) =>
      _registries[navigator] ??= TransitionOrigins();

  Duration? _pointerTime;
  DateTime? _recordedAt;
  Offset? _point;
  TransitionOrigin? _armed;
  Timer? _expiry;
  final Set<TransitionOrigin> _active = {};

  void pointerDown(PointerDownEvent event) {
    if (_pointerTime == event.timeStamp && _point == event.position) return;
    _expiry?.cancel();
    _armed?.dispose();
    _armed = null;
    _pointerTime = event.timeStamp;
    _point = event.position;
    _recordedAt = DateTime.now();
  }

  void arm(TransitionOrigin origin) {
    _armed?.dispose();
    _armed = origin;
    _expiry?.cancel();
    _expiry = Timer(const Duration(seconds: 1), () => disarm(origin));
  }

  void disarm(TransitionOrigin origin) {
    if (!identical(_armed, origin)) return;
    _expiry?.cancel();
    _armed = null;
    origin.dispose();
  }

  ({TransitionOrigin? source, Offset? point}) consume() {
    _expiry?.cancel();
    final source = _armed;
    _armed = null;
    final fresh =
        _recordedAt != null &&
        DateTime.now().difference(_recordedAt!) <= const Duration(seconds: 1);
    final valid = fresh && source?.currentRect() != null;
    if (!valid) source?.dispose();
    final result = (
      source: valid ? source : null,
      point: fresh ? _point : null,
    );
    _point = null;
    _recordedAt = null;
    _pointerTime = null;
    return result;
  }

  bool suppresses(Object tag) =>
      _active.any((origin) => origin.tags.contains(tag));

  void activate(TransitionOrigin origin) => _active.add(origin);
  void release(TransitionOrigin origin) => _active.remove(origin);
}

/// Owns captured pixels until its destination route is removed. The source
/// supplies live geometry and a paint-only visibility notifier, never a clone
/// of its widget tree or GlobalKeys.
final class TransitionOrigin {
  TransitionOrigin({
    required this.rect,
    required this.radius,
    required this.image,
    required this.currentRect,
    required this.hidden,
    required this.tags,
  });

  Rect rect;
  final double radius;
  final ui.Image image;
  final Rect? Function() currentRect;
  final ValueNotifier<bool> hidden;
  final Set<Object> tags;
  TransitionOrigins? _registry;
  bool _disposed = false;

  void activate(TransitionOrigins registry) {
    if (_disposed) return;
    _registry = registry;
    registry.activate(this);
  }

  void setHidden(bool value) {
    if (!_disposed && hidden.value != value) hidden.value = value;
  }

  void refresh() {
    rect = currentRect() ?? rect;
  }

  void dispose() {
    if (_disposed) return;
    setHidden(false);
    _disposed = true;
    _registry?.release(this);
    image.dispose();
  }
}

/// Supplies the selected push's origin to built-in effects without changing IR
/// or the app navigation contract.
class TransitionOriginScope extends InheritedWidget {
  const TransitionOriginScope({
    super.key,
    this.source,
    this.point,
    required super.child,
  });

  final TransitionOrigin? source;
  final Offset? point;

  static TransitionOriginScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TransitionOriginScope>();

  @override
  bool updateShouldNotify(TransitionOriginScope oldWidget) =>
      source != oldWidget.source || point != oldWidget.point;
}
