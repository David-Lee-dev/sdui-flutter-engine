import 'package:thermion_flutter/thermion_flutter.dart';

/// The plugin calls `FilamentModel3dSource` makes outside a viewer: creating
/// and releasing viewers and pausing the shared frame loop. Tests replace it
/// to drive the controller without a native engine.
class FilamentPlatform {
  const FilamentPlatform();

  Future<ThermionViewer> createViewer() => ThermionFlutterPlugin.createViewer();

  /// Destroys [viewer] together with the texture it renders into.
  Future<void> releaseViewer(ThermionViewer viewer) async {
    try {
      // The texture's render target refers to the view; release it before
      // the viewer destroys the view.
      await ThermionFlutterPlugin.instance.destroyTextureForView(viewer.view);
    } finally {
      await viewer.dispose();
      await ThermionFlutterPlugin.instance.onViewerDisposed(viewer.view);
    }
  }

  void resumeFrames() => ThermionFlutterPlugin.instance.resumeFrameScheduler();

  void pauseFrames() => ThermionFlutterPlugin.instance.pauseFrameScheduler();
}
