import 'package:video_player/video_player.dart';

import '../../dependency/video_source.dart';

/// Default [VideoSource] — bundled asset videos, the bare minimum.
///
/// Template `src` values are asset paths packaged with the app. A
/// network-backed source needs a base URL and belongs to the app — see the
/// starter kit's `NetworkVideoSource`.
class AssetVideoSource implements VideoSource {
  const AssetVideoSource();

  @override
  Future<VideoPlayerController> controllerFor(VideoRequest request) async =>
      VideoPlayerController.asset(request.src);
}
