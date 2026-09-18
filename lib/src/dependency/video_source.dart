import 'package:video_player/video_player.dart';

/// Defines the policy for creating video controllers.
abstract class VideoSource {
  /// Creates a controller for [request] without initializing playback.
  Future<VideoPlayerController> controllerFor(VideoRequest request);
}

/// Carries resolved video props to a [VideoSource].
final class VideoRequest {
  const VideoRequest({required this.src});

  final String src;
}
