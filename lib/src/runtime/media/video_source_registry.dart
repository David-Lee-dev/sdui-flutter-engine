import 'package:sdui_engine/src/contract/video_source.dart';

import '../../runtime/media/asset_video_source.dart';

/// Defines the process-wide policy for creating video controllers.
final class VideoSourceRegistry {
  const VideoSourceRegistry._();

  static VideoSource _current = const AssetVideoSource();

  /// Returns the currently installed video policy.
  static VideoSource get current => _current;

  static bool _frozen = false;

  /// Installs [source], or throws [StateError] after [freeze] has been called.
  static void install(VideoSource source) {
    if (_frozen) throw StateError('VideoSource is frozen');
    _current = source;
  }

  /// Prevents subsequent video-policy installation.
  static void freeze() => _frozen = true;

  /// Restores the network fallback and permits installation again.
  static void reset() {
    _current = const AssetVideoSource();
    _frozen = false;
  }
}
