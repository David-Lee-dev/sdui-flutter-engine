import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/video_source.dart';

import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';
import '../../../media/video_source_registry.dart';
import '../../../media/shared_video_session.dart';

/// `video` — Builds a policy-backed video player with optional playback interaction.
///
/// ```yaml
/// _type: video
/// src: example
/// ```
///
/// Props:
/// - `src` (`text`, default `null`) — media source path or URL.
/// - `loop` (`flag`, default `true`) — true wraps past the last page back to the first.
/// - `autoplay` (`flag`, default `true`) — starts playback automatically.
/// - `muted` (`flag`, default `false`) — starts playback without audio.
/// - `fit` (`boxFit`, default `cover`) — content fitting mode. Values: fill | contain | cover | fit_width | fit_height | none | scale_down.
/// - `aspect_ratio` (`number`, default `null`) — width-to-height ratio of the rendered box.
/// - `show_controls` (`flag`, default `false`) — shows playback controls over the video.
/// - `on_end` (`text`, default `null`) — action dispatched when playback ends.
///
/// Child: none.
///
/// Rendering delegates to the app-installed video policy; `loop`, `autoplay`,
/// and `on_end` control repetition, startup, and completion dispatch.
final class VideoWidget {
  const VideoWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final src = PropsResolver.text(props['src']);
    if (src == null || src.isEmpty) return const SizedBox.shrink();
    return _VideoView(
      src: src,
      loop: PropsResolver.flag(props['loop']) ?? true,
      autoplay: PropsResolver.flag(props['autoplay']) ?? true,
      muted: PropsResolver.flag(props['muted']) ?? false,
      fit: PropsResolver.boxFit(props['fit']) ?? BoxFit.cover,
      aspectRatio: PropsResolver.number(props['aspect_ratio']),
      showControls: PropsResolver.flag(props['show_controls']) ?? false,
      onEnd: PropsResolver.text(props['on_end']),
      dispatch: dispatch,
    );
  }
}

class _VideoView extends StatefulWidget {
  const _VideoView({
    required this.src,
    required this.loop,
    required this.autoplay,
    required this.muted,
    required this.fit,
    required this.aspectRatio,
    required this.showControls,
    required this.onEnd,
    required this.dispatch,
  });

  final String src;
  final bool loop;
  final bool autoplay;
  final bool muted;
  final BoxFit fit;
  final double? aspectRatio;
  final bool showControls;
  final String? onEnd;
  final ActionSink? dispatch;

  @override
  State<_VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  SduiVideoController? _controller;
  bool _initialized = false;
  bool _endDispatched = false;
  int _generation = 0;

  SharedVideoLease? _lease;
  SharedVideoScope? _scope;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = SharedVideoScope.of(context);
    if (_started &&
        identical(scope?.leases, _scope?.leases) &&
        scope?.tag == _scope?.tag &&
        scope?.navigator == _scope?.navigator) {
      return;
    }
    if (_started) _disposeController();
    _scope = scope;
    _started = true;
    final route = ModalRoute.of(context);
    if (scope == null || route == null) {
      unawaited(_createController());
      return;
    }
    _createLease(scope, route);
  }

  void _createLease(SharedVideoScope scope, ModalRoute<dynamic> route) {
    _endDispatched = false;
    final lease = SharedVideoSession.acquire(
      scope,
      widget.src,
      route,
      loop: widget.loop,
      muted: widget.muted,
      autoplay: widget.autoplay,
      onPlayback: _onPlaybackChanged,
    );
    _lease = lease;
    lease.session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (!mounted) return;
    final lease = _lease;
    final scope = _scope;
    if (lease != null &&
        scope != null &&
        !lease.canShare() &&
        lease.session.hasMultipleLeases) {
      final route = lease.route;
      _disposeController();
      _createLease(scope, route);
    }
    setState(() {});
  }

  Future<void> _createController() async {
    final generation = ++_generation;
    _initialized = false;
    _endDispatched = false;
    try {
      final controller = await VideoSourceRegistry.current.controllerFor(
        VideoRequest(src: widget.src),
      );
      if (!mounted || generation != _generation) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      controller.addListener(_onPlaybackChanged);
      await controller.initialize();
      if (!mounted || generation != _generation) return;
      await controller.setLooping(widget.loop);
      await controller.setVolume(widget.muted ? 0 : 1);
      if (widget.autoplay) await controller.play();
      if (!mounted || generation != _generation) return;
      setState(() => _initialized = true);
    } catch (_) {
      if (!mounted || generation != _generation) return;
      final controller = _controller;
      _controller = null;
      if (controller != null) {
        controller.removeListener(_onPlaybackChanged);
        await controller.dispose();
      }
      if (mounted && generation == _generation) {
        setState(() => _initialized = false);
      }
    }
  }

  void _onPlaybackChanged() {
    final controller = _lease?.session.controller ?? _controller;
    final onEnd = widget.onEnd;
    if (controller == null || widget.loop || onEnd == null || _endDispatched) {
      return;
    }
    final value = controller.playback;
    if (value.duration > Duration.zero &&
        value.position >= value.duration &&
        !value.isPlaying) {
      _endDispatched = true;
      widget.dispatch?.handle(onEnd);
    }
  }

  @override
  void didUpdateWidget(_VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _disposeController();
      final scope = _scope;
      final route = ModalRoute.of(context);
      if (scope != null && route != null) {
        _createLease(scope, route);
      } else {
        unawaited(_createController());
      }
      return;
    }
    final lease = _lease;
    if (lease != null) {
      if (oldWidget.loop != widget.loop) _endDispatched = false;
      lease.configure(
        loop: widget.loop,
        muted: widget.muted,
        autoplay: widget.autoplay,
      );
      return;
    }
    final controller = _controller;
    if (controller == null) return;
    if (oldWidget.loop != widget.loop) {
      _endDispatched = false;
      unawaited(controller.setLooping(widget.loop));
    }
    if (oldWidget.muted != widget.muted) {
      unawaited(controller.setVolume(widget.muted ? 0 : 1));
    }
  }

  void _disposeController() {
    _generation++;
    final lease = _lease;
    _lease = null;
    if (lease != null) {
      lease.session.removeListener(_onSessionChanged);
      _scope?.leases.remove(lease);
      lease.release();
    }
    final controller = _controller;
    _controller = null;
    _initialized = false;
    if (controller == null) return;
    controller.removeListener(_onPlaybackChanged);
    unawaited(controller.dispose());
  }

  void _togglePlayback() {
    final lease = _lease;
    if (lease != null && !lease.session.ownsPlayback(lease)) return;
    final controller = lease?.session.controller ?? _controller;
    if (controller == null) return;
    if (controller.playback.isPlaying) {
      unawaited(controller.pause());
    } else {
      unawaited(controller.play());
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lease = _lease;
    final session = lease?.session;
    final controller = session?.controller ?? _controller;
    final initialized = session?.initialized ?? _initialized;
    if (!initialized || controller == null) return const SizedBox.shrink();
    final playback = controller.playback;
    final video = AspectRatio(
      aspectRatio: widget.aspectRatio ?? playback.aspectRatio,
      child:
          session?.buildView(fit: widget.fit) ??
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: playback.width,
              height: playback.height,
              child: controller.buildView(),
            ),
          ),
    );
    if (!widget.showControls ||
        (lease != null && !session!.ownsPlayback(lease))) {
      return video;
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        video,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayback,
          ),
        ),
      ],
    );
  }
}
