import 'package:flutter/widgets.dart';

/// Defines the policy for creating video controllers.
///
/// The contract carries no player-plugin types: implementations decide the
/// backing engine, source resolution (asset vs network), formats, caching —
/// everything beyond the playback surface the engine's `video` widget needs.
/// The package default wraps `video_player` (`PlayerVideoController`).
abstract class VideoSource {
  /// Creates a controller for [request] without initializing playback.
  Future<SduiVideoController> controllerFor(VideoRequest request);
}

/// Carries resolved video props to a [VideoSource].
final class VideoRequest {
  const VideoRequest({required this.src});

  final String src;
}

/// The playback surface the engine's `video` widget drives — the whole
/// coupling between the engine and whatever player the app installs.
abstract class SduiVideoController {
  /// Prepares the media; must complete before [buildView] renders frames.
  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> setLooping(bool looping);

  /// [volume] is 0.0 (muted) to 1.0.
  Future<void> setVolume(double volume);

  /// [listener] fires on any playback-state change ([playback]).
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  /// The current playback snapshot.
  VideoPlayback get playback;

  /// The raw video surface, unsized — the engine applies fit and ratio.
  Widget buildView();

  Future<void> dispose();
}

/// One immutable snapshot of playback state.
final class VideoPlayback {
  const VideoPlayback({
    required this.width,
    required this.height,
    required this.duration,
    required this.position,
    required this.isPlaying,
  });

  /// Intrinsic frame size in logical pixels (0 until initialized).
  final double width;

  final double height;

  /// Media length ([Duration.zero] until known).
  final Duration duration;

  final Duration position;

  final bool isPlaying;

  /// Width-to-height ratio; 1 while the size is unknown.
  double get aspectRatio => height <= 0 || width <= 0 ? 1 : width / height;
}
