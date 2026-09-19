import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/video_source.dart';
import 'package:video_player/video_player.dart';

import '../../../util/props_resolver.dart';
import '../../contract/action_sink.dart';
import '../../../media/video_source_registry.dart';

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
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _endDispatched = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_createController());
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
    final controller = _controller;
    final onEnd = widget.onEnd;
    if (controller == null || widget.loop || onEnd == null || _endDispatched) {
      return;
    }
    final value = controller.value;
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
      unawaited(_createController());
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
    final controller = _controller;
    _controller = null;
    _initialized = false;
    if (controller == null) return;
    controller.removeListener(_onPlaybackChanged);
    unawaited(controller.dispose());
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
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
    final controller = _controller;
    if (!_initialized || controller == null) return const SizedBox.shrink();
    final size = controller.value.size;
    final video = AspectRatio(
      aspectRatio: widget.aspectRatio ?? controller.value.aspectRatio,
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
    if (!widget.showControls) return video;
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
