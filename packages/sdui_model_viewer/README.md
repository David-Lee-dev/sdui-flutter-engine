# sdui_model_viewer

WebView renderer for the [sdui_engine](../../README.md) `model` widget, backed
by Google's [`<model-viewer>`](https://modelviewer.dev) 3.5.0 (bundled — no
CDN at runtime).

```dart
Sdui.initialize(
  modelSource: WebModelSource(
    baseUrl: Uri.parse(apiUrl),          // resolves `/assets/...` srcs
    prefetch: ['/assets/character.glb'], // loaded during warm-up
  ),
  // ...
);
```

- Model bytes load in Dart (`ModelBytesCache`, in memory, LRU) and reach the
  page through a same-origin scheme the webview hands back to Dart: a custom
  scheme (`sdui-model://`) on iOS, an intercepted reserved host on Android.
  The page never fetches the network itself, so there is no CORS setup.
- `src` resolution: `http(s)://` as is, `/path` against `baseUrl`, anything
  else a bundled asset key.
- `warmUp()` loads the viewer script in a throwaway headless webview so the
  first visible mount skips the web engine start-up.
- Each controller logs its load timeline when the model is ready
  (`[sdui_model_viewer] #1 warm-up 812ms /a.glb: webview 15ms, page 240ms,
  model 260ms, ready 900ms (7.6MB cache 3ms)`), and `warmUp()` logs how long
  it took.
- `debugOverlay: true`, or building with `--dart-define=SDUI_MODEL_DEBUG=true`,
  paints that timeline over each view once the poster fades, with the app
  process's RSS and Flutter frame times since ready. The RSS excludes the
  webview's own content process; measure the total with Instruments (iOS) or
  `adb shell dumpsys meminfo` (Android).

Status: runs on iOS (iPhone 13 mini, a static GLB with camera controls).
Animation clips have not run on a device yet. Android uses
`shouldInterceptRequest` and is untested.

`assets/model-viewer-umd.min.js` is `@google/model-viewer@3.5.0`
(`dist/model-viewer-umd.min.js`, Apache-2.0, see
`assets/MODEL_VIEWER_LICENSE`), which bundles three.js (MIT) and lit
(BSD-3-Clause).
