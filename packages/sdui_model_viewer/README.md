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
- Each controller logs `[sdui_model_viewer] <src> ready in <ms>ms, clips: [...]`
  for first-load measurement.

Status: verified by unit tests only (page resources and the byte cache); the
webview bridge has not yet run on a device. Android uses
`shouldInterceptRequest` and is untested.

`assets/model-viewer-umd.min.js` is `@google/model-viewer@3.5.0`
(`dist/model-viewer-umd.min.js`, Apache-2.0, see
`assets/MODEL_VIEWER_LICENSE`), which bundles three.js (MIT) and lit
(BSD-3-Clause).
