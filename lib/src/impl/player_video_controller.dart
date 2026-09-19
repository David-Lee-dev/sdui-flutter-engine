import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../contract/video_source.dart';

/// Package default [SduiVideoController] — a thin `video_player` wrapper.
///
/// A custom [VideoSource] that is happy with `video_player` returns one of
/// these (asset/network/custom controller); a source with its own player
/// implements [SduiVideoController] directly instead.
class PlayerVideoController implements SduiVideoController {
  PlayerVideoController(this._inner);

  PlayerVideoController.asset(String path)
    : _inner = VideoPlayerController.asset(path);

  PlayerVideoController.network(Uri url)
    : _inner = VideoPlayerController.networkUrl(url);

  final VideoPlayerController _inner;

  @override
  Future<void> initialize() => _inner.initialize();

  @override
  Future<void> play() => _inner.play();

  @override
  Future<void> pause() => _inner.pause();

  @override
  Future<void> setLooping(bool looping) => _inner.setLooping(looping);

  @override
  Future<void> setVolume(double volume) => _inner.setVolume(volume);

  @override
  void addListener(VoidCallback listener) => _inner.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _inner.removeListener(listener);

  @override
  VideoPlayback get playback {
    final value = _inner.value;
    return VideoPlayback(
      width: value.size.width,
      height: value.size.height,
      duration: value.duration,
      position: value.position,
      isPlaying: value.isPlaying,
    );
  }

  @override
  Widget buildView() => VideoPlayer(_inner);

  @override
  Future<void> dispose() => _inner.dispose();
}
