# Changelog

## 0.1.0

- `WebModel3dSource` / `WebModel3dController`: a `Model3dSource` for the
  sdui_engine 0.21 `model_3d` widget rendering through a transparent
  `<model-viewer>` webview, with a Dart-side model byte cache, prefetch and a
  headless warm-up.
- `ModelLoadStats` load timeline per view (logged on ready) and
  `ModelDebugOverlay` (`debugOverlay`, or `--dart-define=SDUI_MODEL_DEBUG=true`)
  painting it with app RSS and frame times for measurement.
- `ModelBytesCache` and the measurement types move to `sdui_model_support`
  (re-exported here).
- The page has no camera controls of its own: `setCamera` sets
  `<model-viewer>`'s `cameraOrbit`, and the engine handles gestures.
- `progress` poses: `setPose` pauses `<model-viewer>` on the clip and sets its
  `currentTime`; clip lengths come from the cached `.glb` through
  `gltfClipDurations`.
- Models persist across launches through `ModelDiskCache` (`diskCache`,
  default on): a model seen once opens from disk, revalidated in the
  background.
