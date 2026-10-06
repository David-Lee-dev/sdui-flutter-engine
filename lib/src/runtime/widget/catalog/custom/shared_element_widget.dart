import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../engine_presentation.dart';
import '../../../media/shared_video_session.dart';
import '../../../log/engine_log.dart';
import '../../../transition/shared_transition_scope.dart';
import '../../../telemetry/visit_observer.dart';

/// Wraps one box child in a same-Navigator Hero flight.
final class SharedElementWidget {
  const SharedElementWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? const SizedBox.shrink() : children.first;
    final tag = props['tag'];
    if (tag is! String || tag.isEmpty) return child;
    final radius = props['radius'];
    return SharedElement(
      tag: tag,
      radius: radius is num && radius.isFinite && radius >= 0
          ? radius.toDouble()
          : 0,
      child: child,
    );
  }
}

/// The mounted participant owns its snapshot; the shuttle owns a cloned image.
class SharedElement extends StatefulWidget {
  const SharedElement({
    super.key,
    required this.tag,
    this.radius = 0,
    required this.child,
  });

  final String tag;
  final double radius;
  final Widget child;

  @override
  State<SharedElement> createState() => _SharedElementState();
}

// Navigator identity also belongs to the Hero tag: Flutter can discover heroes
// in nested navigators, but v1 must never pair a branch hero with a root hero.
final _registries = Expando<_Participants>();

final class _Participants {
  final Map<ModalRoute<dynamic>, Map<String, Set<_SharedElementState>>> routes =
      {};
  final Set<(ModalRoute<dynamic>, String)> _reported = {};

  void register(ModalRoute<dynamic> route, _SharedElementState owner) {
    (routes
            .putIfAbsent(route, () => {})
            .putIfAbsent(owner.widget.tag, () => {}))
        .add(owner);
  }

  void unregister(
    ModalRoute<dynamic> route,
    String tag,
    _SharedElementState owner,
  ) {
    final tags = routes[route];
    final owners = tags?[tag];
    if (owners == null || !owners.remove(owner)) return;
    if (owners.isEmpty) tags!.remove(tag);
    if (tags!.isEmpty) routes.remove(route);
    if (owners.length < 2) _reported.remove((route, tag));
  }

  bool unique(ModalRoute<dynamic> route, String tag) {
    final owners = routes[route]?[tag];
    if (owners == null || owners.length != 1) {
      if (owners != null && _reported.add((route, tag))) {
        EngineLog.warn(
          'shared_element: duplicate tag "$tag" in one route; '
          'all participants disabled.',
          tag: 'widget',
        );
      }
      return false;
    }
    return true;
  }
}

class _SharedElementState extends State<SharedElement> {
  final _boundary = GlobalKey();
  final _videoLeases = <SharedVideoLease>{};
  VoidCallback? _flightRelease;
  _Participants? _registry;
  PageRoute<dynamic>? _route;
  NavigatorState? _navigator;
  SharedTransitionController? _transition;
  bool _active = false;
  bool _tickerEnabled = false;
  ui.Image? _snapshot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unregister(widget.tag);
    final route = ModalRoute.of(context);
    _route = route is PageRoute ? route : null;
    _navigator = Navigator.maybeOf(context);
    _tickerEnabled = TickerMode.of(context);
    // Route-level ticker suppression must not disable a returning participant,
    // but an inactive tab inside the route still must not register its tags.
    var contentEnabled = true;
    if (!_tickerEnabled) {
      context.visitAncestorElements((element) {
        if (identical(element, _route?.subtreeContext)) return false;
        if (element.widget case TickerMode(enabled: false)) {
          contentEnabled = false;
          return false;
        }
        return true;
      });
    }
    _active =
        contentEnabled &&
        context.findAncestorWidgetOfExactType<VisitObserver>()?.surfaceType !=
            'modal' &&
        !(EnginePresentation.value.transitions.respectReducedMotion &&
            MediaQuery.maybeOf(context)?.disableAnimations == true);
    _transition = SharedTransitionScope.of(context);
    final navigator = _navigator;
    _registry = navigator == null
        ? null
        : (_registries[navigator] ??= _Participants());
    _register();
  }

  void _register() {
    if ((_active || _videoLeases.isNotEmpty) && _route != null) {
      _registry?.register(_route!, this);
    }
  }

  void _unregister(String tag) {
    if (_route != null) _registry?.unregister(_route!, tag, this);
  }

  @override
  void didUpdateWidget(SharedElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tag != widget.tag) {
      _unregister(oldWidget.tag);
      _register();
    }
  }

  @override
  void deactivate() {
    _unregister(widget.tag);
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _register();
  }

  @override
  void dispose() {
    _unregister(widget.tag);
    _snapshot?.dispose();
    _flightRelease?.call();
    super.dispose();
  }

  // HeroController evaluates HeroMode during its post-layout discovery. Reading
  // the complete registry here avoids a one-frame duplicate race during rebuild
  // or reorder, without rebuilding siblings while the tree is being built.
  bool get _canFly {
    final route = _route;
    final gesture = _navigator?.userGestureInProgress ?? false;
    // A maintained route below the top route has disabled tickers when Hero
    // discovery runs synchronously at the start of an edge swipe.
    if (!_active ||
        (!_tickerEnabled && !gesture) ||
        route == null ||
        !(_registry?.unique(route, widget.tag) ?? false)) {
      return false;
    }
    final boundary = _boundary.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary ||
        !boundary.hasSize ||
        boundary.size.isEmpty ||
        !boundary.size.isFinite) {
      return false;
    }
    // A kept-alive list item may still have painted pixels after scrolling out
    // of its viewport. It must not fly from an invisible departure slot.
    final destination =
        route.offstage ||
        route.animation?.status == AnimationStatus.forward ||
        ((route.isCurrent || gesture) &&
            route.animation?.status == AnimationStatus.completed);
    RenderObject? ancestor = boundary.parent;
    while (ancestor != null) {
      if (ancestor is RenderAbstractViewport || ancestor is RenderClipRect) {
        final rect = MatrixUtils.transformRect(
          boundary.getTransformTo(ancestor),
          Offset.zero & boundary.size,
        );
        if (!rect.overlaps(ancestor.paintBounds)) return false;
      }
      ancestor = ancestor.parent;
    }
    var platformView = false;
    void inspect(RenderObject object) {
      if (object is PlatformViewRenderBox ||
          object is RenderDarwinPlatformView) {
        platformView = true;
      }
      object.visitChildren(inspect);
    }

    inspect(boundary);
    if (platformView) return false;

    _snapshot?.dispose();
    _snapshot = null;
    // debugNeedsPaint itself throws in release; a missing release layer is
    // handled by toImageSync's failure path instead.
    var painted = true;
    assert(() {
      painted = !boundary.debugNeedsPaint;
      return true;
    }());
    try {
      if (painted) _snapshot = boundary.toImageSync();
    } catch (_) {
      // An offstage destination may not have a composited layer yet.
    }
    if (_snapshot == null && destination) {
      // Paint the laid-out destination into an isolated parent layer before
      // Hero hides it. No live child or GlobalKey is copied into the overlay.
      final layer = LayerHandle<OffsetLayer>(OffsetLayer());
      try {
        PaintingContext(
          layer.layer!,
          boundary.paintBounds,
        ).paintChild(boundary, Offset.zero);
        _snapshot = boundary.toImageSync();
      } catch (_) {
        // Unsupported rasterization is decorative: navigation must continue.
      } finally {
        layer.layer!.removeAllChildren();
        layer.layer = null;
      }
    }
    return _snapshot != null || destination;
  }

  Widget _shuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext from,
    BuildContext to,
  ) {
    final source = from.findAncestorStateOfType<_SharedElementState>()!;
    final destination = to.findAncestorStateOfType<_SharedElementState>()!;
    final sourceVideos = source._videoLeases;
    final destinationVideos = destination._videoLeases;
    if (sourceVideos.length == 1 && destinationVideos.length == 1) {
      final session = sourceVideos.single.session;
      if (identical(session, destinationVideos.single.session) &&
          session.initialized) {
        return _LiveVideoFlight(
          session: session,
          release: destination._flightRelease ?? session.retainFlight(),
          animation: animation,
          direction: direction,
          fromRadius: source.widget.radius,
          toRadius: destination.widget.radius,
        );
      }
    }
    final image = source._snapshot;
    if (image == null) return const SizedBox.shrink();
    return _SnapshotFlight(
      image: image.clone(),
      destinationImage: destination._snapshot?.clone(),
      animation: animation,
      direction: direction,
      fromRadius: source.widget.radius,
      toRadius: destination.widget.radius,
    );
  }

  @override
  Widget build(BuildContext context) => _ParticipantMode(
    participant: this,
    child: Hero(
      tag: (_navigator, widget.tag),
      transitionOnUserGestures: true,
      createRectTween: (begin, end) {
        if (_videoLeases.length == 1) {
          final session = _videoLeases.single.session;
          if (session.hasMultipleLeases &&
              session.initialized &&
              _flightRelease == null) {
            final release = session.retainFlight();
            _flightRelease = () {
              release();
              _flightRelease = null;
            };
          }
        }
        if (_route?.animation?.status == AnimationStatus.forward) {
          _transition?.flightStarted();
        }
        return RectTween(begin: begin, end: end);
      },
      flightShuttleBuilder: _shuttle,
      // Keep the slot and live keys mounted without a second visible copy.
      placeholderBuilder: (_, size, child) => SizedBox(
        width: size.width,
        height: size.height,
        child: Offstage(child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        clipBehavior: widget.radius > 0 ? Clip.antiAlias : Clip.none,
        // Capture pixels without endpoint rounding; the shuttle applies its
        // interpolated clip once, including when the destination is square.
        child: RepaintBoundary(
          key: _boundary,
          child:
              (_active || _videoLeases.isNotEmpty) &&
                  _route != null &&
                  _navigator != null
              ? SharedVideoScope(
                  navigator: _navigator!,
                  tag: widget.tag,
                  leases: _videoLeases,
                  canShare: () =>
                      _registry?.unique(_route!, widget.tag) ?? false,
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
    ),
  );
}

class _ParticipantMode extends HeroMode {
  const _ParticipantMode({required this.participant, required super.child});
  final _SharedElementState participant;

  @override
  bool get enabled => participant._canFly;
}

class _SnapshotFlight extends StatefulWidget {
  const _SnapshotFlight({
    required this.image,
    required this.destinationImage,
    required this.animation,
    required this.direction,
    required this.fromRadius,
    required this.toRadius,
  });
  final ui.Image image;
  final ui.Image? destinationImage;
  final Animation<double> animation;
  final HeroFlightDirection direction;
  final double fromRadius;
  final double toRadius;

  @override
  State<_SnapshotFlight> createState() => _SnapshotFlightState();
}

class _SnapshotFlightState extends State<_SnapshotFlight> {
  @override
  void didUpdateWidget(_SnapshotFlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.image, widget.image)) {
      oldWidget.image.dispose();
    }
    if (!identical(oldWidget.destinationImage, widget.destinationImage)) {
      oldWidget.destinationImage?.dispose();
    }
  }

  @override
  void dispose() {
    widget.image.dispose();
    widget.destinationImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.animation,
    builder: (_, _) {
      final t = widget.direction == HeroFlightDirection.push
          ? widget.animation.value
          : 1 - widget.animation.value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          ui.lerpDouble(widget.fromRadius, widget.toRadius, t)!,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: widget.destinationImage == null ? 1 : 1 - t,
              child: RawImage(image: widget.image, fit: BoxFit.cover),
            ),
            if (widget.destinationImage != null)
              Opacity(
                opacity: t,
                child: RawImage(
                  image: widget.destinationImage,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _LiveVideoFlight extends StatefulWidget {
  const _LiveVideoFlight({
    required this.session,
    required this.release,
    required this.animation,
    required this.direction,
    required this.fromRadius,
    required this.toRadius,
  });

  final SharedVideoSession session;
  final VoidCallback release;
  final Animation<double> animation;
  final HeroFlightDirection direction;
  final double fromRadius;
  final double toRadius;

  @override
  State<_LiveVideoFlight> createState() => _LiveVideoFlightState();
}

class _LiveVideoFlightState extends State<_LiveVideoFlight> {
  late VoidCallback _release;
  bool _flying = true;

  @override
  void initState() {
    super.initState();
    _release = widget.release;
    widget.animation.addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(_LiveVideoFlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_onStatus);
      widget.animation.addStatusListener(_onStatus);
    }
    if (oldWidget.release != widget.release) {
      _release();
      _release = widget.release;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _flying = false;
      _release();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatus);
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.animation,
    builder: (_, _) {
      if (!_flying) return const SizedBox.shrink();
      final t = widget.direction == HeroFlightDirection.push
          ? widget.animation.value
          : 1 - widget.animation.value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          ui.lerpDouble(widget.fromRadius, widget.toRadius, t)!,
        ),
        child: widget.session.buildView(),
      );
    },
  );
}
