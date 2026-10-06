import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../../contract/video_source.dart';
import 'video_source_registry.dart';

final _sessions = Expando<Map<(String, String), SharedVideoSession>>();

/// A shared-element participant exposes its leased media to the Hero shuttle.
class SharedVideoScope extends InheritedWidget {
  const SharedVideoScope({
    super.key,
    required this.navigator,
    required this.tag,
    required this.leases,
    required this.canShare,
    required super.child,
  });

  final NavigatorState navigator;
  final String tag;
  final Set<SharedVideoLease> leases;
  final bool Function() canShare;

  static SharedVideoScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SharedVideoScope>();

  @override
  bool updateShouldNotify(SharedVideoScope oldWidget) =>
      navigator != oldWidget.navigator || tag != oldWidget.tag;
}

/// Retains one controller across route participants and the live flight.
class SharedVideoSession extends ChangeNotifier {
  SharedVideoSession._(this._registry, this._key) {
    ready = _initialize();
  }

  final Map<(String, String), SharedVideoSession> _registry;
  final (String, String) _key;
  final List<SharedVideoLease> _leases = [];
  late final Future<void> ready;
  SduiVideoController? controller;
  SharedVideoLease? active;
  int _flights = 0;
  bool initialized = false;
  bool _disposed = false;
  Future<void> _configuration = Future.value();

  static SharedVideoLease acquire(
    SharedVideoScope scope,
    String src,
    ModalRoute<dynamic> route, {
    required bool loop,
    required bool muted,
    required bool autoplay,
    required VoidCallback onPlayback,
  }) {
    final registry = _sessions[scope.navigator] ??= {};
    final key = (scope.tag, src);
    // Duplicate videos in one route must never steal each other's presenter.
    var session = registry[key];
    if (!scope.canShare() ||
        (session != null &&
            session._leases.any(
              (lease) => lease.route == route || !lease.canShare(),
            ))) {
      session = SharedVideoSession._({}, key);
    } else {
      session ??= registry[key] = SharedVideoSession._(registry, key);
    }
    final lease = SharedVideoLease._(
      session,
      route,
      loop,
      muted,
      autoplay,
      onPlayback,
      scope.canShare,
    );
    session._leases.add(lease);
    scope.leases.add(lease);
    session.refreshOwner();
    return lease;
  }

  Future<void> _initialize() async {
    try {
      final value = await VideoSourceRegistry.current.controllerFor(
        VideoRequest(src: _key.$2),
      );
      controller = value;
      if (_disposed) {
        await value.dispose();
        return;
      }
      await value.initialize();
      if (_disposed) return;
      initialized = true;
      value.addListener(_onPlayback);
      refreshOwner();
      _notify();
    } catch (_) {
      final value = controller;
      controller = null;
      if (!_disposed) await value?.dispose();
      initialized = false;
      _notify();
    }
  }

  void _onPlayback() => active?.onPlayback();

  void _notify() {
    if (_disposed) return;
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }
    // Acquiring and releasing route children can happen during build/dispose.
    // Ownership changes immediately; presentation rebuilds at the frame boundary.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void refreshOwner() {
    if (_disposed) return;
    final next =
        _leases.where((lease) => lease.route.isCurrent).lastOrNull ??
        _leases.lastOrNull;
    if (active != next) {
      active = next;
      _configure(next);
      _notify();
    } else if (initialized && next != null && !next.configured) {
      _configure(next);
    }
  }

  void _configure(SharedVideoLease? lease) {
    if (!initialized || lease == null) return;
    lease.configured = true;
    _configuration = _configuration
        .then((_) async {
          final value = controller;
          if (_disposed || active != lease || value == null) return;
          await value.setLooping(lease.loop);
          if (_disposed || active != lease) return;
          await value.setVolume(lease.muted ? 0 : 1);
          if (_disposed || active != lease) return;
          if (lease.autoplay && !value.playback.isPlaying) await value.play();
        })
        .catchError((Object _) {});
  }

  bool get hasMultipleLeases => _leases.length > 1;

  bool ownsPlayback(SharedVideoLease lease) => active == lease;

  /// A flight holds a reference even if either route disappears mid-transition.
  VoidCallback retainFlight() {
    _flights++;
    _notify();
    var released = false;
    return () {
      if (released) return;
      released = true;
      _flights--;
      refreshOwner();
      _notify();
      _disposeIfUnused();
    };
  }

  Widget buildView({BoxFit fit = BoxFit.cover}) {
    final value = controller;
    if (!initialized || value == null) return const SizedBox.shrink();
    final playback = value.playback;
    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: playback.width,
        height: playback.height,
        child: value.buildView(),
      ),
    );
  }

  void _release(SharedVideoLease lease) {
    _leases.remove(lease);
    refreshOwner();
    _disposeIfUnused();
  }

  void _disposeIfUnused() {
    if (_disposed || _leases.isNotEmpty || _flights != 0) return;
    _disposed = true;
    if (identical(_registry[_key], this)) _registry.remove(_key);
    final value = controller;
    controller = null;
    value?.removeListener(_onPlayback);
    unawaited(value?.dispose());
    super.dispose();
  }
}

class SharedVideoLease {
  SharedVideoLease._(
    this.session,
    this.route,
    this.loop,
    this.muted,
    this.autoplay,
    this.onPlayback,
    this.canShare,
  ) {
    route.animation?.addListener(session.refreshOwner);
    route.secondaryAnimation?.addListener(session.refreshOwner);
  }

  final SharedVideoSession session;
  final ModalRoute<dynamic> route;
  final VoidCallback onPlayback;
  final bool Function() canShare;
  bool loop;
  bool muted;
  bool autoplay;
  bool configured = false;
  bool _released = false;

  void configure({
    required bool loop,
    required bool muted,
    required bool autoplay,
  }) {
    this.loop = loop;
    this.muted = muted;
    this.autoplay = autoplay;
    configured = false;
    session.refreshOwner();
  }

  void release() {
    if (_released) return;
    _released = true;
    route.animation?.removeListener(session.refreshOwner);
    route.secondaryAnimation?.removeListener(session.refreshOwner);
    session._release(this);
  }
}
