import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sdui_model_support/sdui_model_support.dart';

/// One response served to the viewer webview.
typedef ViewerResource = ({Uint8List data, String contentType});

/// Serves the viewer page, the bundled `<model-viewer>` script and model
/// bytes to the webview from Dart, under one origin.
///
/// Everything the page loads comes from [origin], so the webview never makes
/// a cross-origin request: model files reach it through [ModelBytesCache]
/// (and its prefetch) instead of the page fetching the network itself.
final class ViewerPage {
  ViewerPage({required this.origin, required this.models, AssetBundle? bundle})
    : _bundle = bundle;

  /// The page origin, e.g. `sdui-model://app/` (iOS custom scheme) or
  /// `https://sdui-model.invalid/` (intercepted on Android).
  final Uri origin;

  final ModelBytesCache models;
  final AssetBundle? _bundle;
  Future<Uint8List>? _script;

  static const scriptAsset =
      'packages/sdui_model_viewer/assets/model-viewer-umd.min.js';

  /// The page URL that renders [src].
  Uri pageUrl({required String src}) =>
      origin.resolve('index.html').replace(queryParameters: {'src': src});

  /// Loads the bundled viewer script once.
  Future<Uint8List> script() => _script ??= () async {
    final data = await (_bundle ?? rootBundle).load(scriptAsset);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }();

  /// The response for [url], or null when it is not a page resource or the
  /// model fails to load (the page then reports the error).
  Future<ViewerResource?> respond(Uri url) async {
    if (url.scheme != origin.scheme || url.host != origin.host) return null;
    try {
      return switch (url.path) {
        '/index.html' => (
          data: utf8.encode(viewerHtml),
          contentType: 'text/html',
        ),
        '/model-viewer.js' => (
          data: await script(),
          contentType: 'application/javascript',
        ),
        '/model' => (
          data: await models.load(url.queryParameters['src'] ?? ''),
          contentType: 'model/gltf-binary',
        ),
        _ => null,
      };
    } catch (error) {
      debugPrint('[sdui_model_viewer] ${url.path} failed: $error');
      return null;
    }
  }
}

/// The viewer page: one full-bleed transparent `<model-viewer>` configured
/// from the query string, bridged to Dart through `flutter_inappwebview`
/// handlers (`sduiReady`, `sduiError`, `sduiFinished`, `sduiPlaying`) and
/// driven by `sduiPlay(clip, loop, crossfadeMs)`, `sduiStop()`,
/// `sduiPose(clip, seconds)` and `sduiCamera(yaw, pitch, zoom)`. The page has no camera controls of its
/// own: the engine handles gestures and places the camera.
@visibleForTesting
const viewerHtml = '''<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<style>
  html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background: transparent; }
  model-viewer { width: 100%; height: 100%; background: transparent; --poster-color: transparent; --progress-bar-height: 0; }
</style>
<script src="model-viewer.js"></script>
</head>
<body>
<model-viewer id="m" interaction-prompt="none" shadow-intensity="1" exposure="1"
  min-camera-orbit="auto 0deg 1%" max-camera-orbit="auto 180deg 10000%"></model-viewer>
<script>
  const m = document.getElementById('m');
  const q = new URLSearchParams(location.search);
  const send = (name, ...args) => window.flutter_inappwebview.callHandler(name, ...args);
  m.addEventListener('load', () => send('sduiReady', m.availableAnimations));
  m.addEventListener('error', (e) => send('sduiError', String((e.detail && e.detail.type) || 'error')));
  m.addEventListener('finished', () => send('sduiFinished'));
  m.addEventListener('play', () => send('sduiPlaying', true));
  m.addEventListener('pause', () => send('sduiPlaying', false));
  window.sduiPlay = (clip, loop, crossfadeMs) => {
    m.animationCrossfadeDuration = crossfadeMs;
    m.animationName = clip;
    m.play({ repetitions: loop ? Infinity : 1, pingpong: false });
  };
  window.sduiStop = () => m.pause();
  // Holds a clip at a time: switch clips first (applied on the next update),
  // then seek while paused.
  window.sduiPose = async (clip, seconds) => {
    if (m.animationName !== clip) {
      m.animationName = clip;
      await m.updateComplete;
    }
    if (!m.paused) m.pause();
    m.currentTime = seconds;
  };
  // 105% is model-viewer's framed radius; zoom divides it.
  window.sduiCamera = (yaw, pitch, zoom) => {
    m.cameraOrbit = yaw + 'deg ' + (90 - pitch) + 'deg ' + (105 / zoom) + '%';
    m.jumpCameraToGoal();
  };
  const start = () => {
    const src = q.get('src');
    if (src) m.src = 'model?src=' + encodeURIComponent(src);
  };
  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) start();
  else window.addEventListener('flutterInAppWebViewPlatformReady', start, { once: true });
</script>
</body>
</html>
''';
