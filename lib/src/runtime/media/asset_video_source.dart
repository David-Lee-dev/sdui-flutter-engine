import '../../contract/video_source.dart';
import '../../impl/player_video_controller.dart';

/// Default [VideoSource] — bundled asset videos, the bare minimum.
///
/// Template `src` values are asset paths packaged with the app. A
/// network-backed source needs a base URL and belongs to the app — see the
/// starter kit's `AppVideoSource`.
class AssetVideoSource implements VideoSource {
  const AssetVideoSource();

  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) async =>
      PlayerVideoController.asset(request.src);
}
