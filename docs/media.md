# Media

The `image`, `video`, and `model_3d` widgets delegate source resolution to app-installed policies while retaining template-facing presentation behavior in the engine.

## Images

See the full [`image` widget reference](widgets/display/image.md). An `ImageRequest` carries `src`, dimensions, fit, tint/color blend, alignment, repeat, semantic label, cache dimensions, and the `loading`/`error` slots to `ImageSource.resolve`.

The result policy is:

- `NoImage` renders `SizedBox.shrink`; an empty/non-string `src` does this before source resolution.
- `ReadyImage` renders immediately. The default `AssetImageSource` treats `src` as a bundled asset path and applies the request properties.
- `PendingImage` uses the `loading` slot while pending; without one it holds a transparent box sized from width/height, or an engine shimmer placeholder when the node sets `shimmer: true`. The app sets the default for nodes without `shimmer` through `SduiPresentation(imageShimmer: true)` (default `false`); a node's `shimmer: false` or `shimmer: true` still wins. Completion with null uses the `error` slot or an empty box. Loaded content and placeholder pass through the engine's loading-image transition/cross-fade, which passes the parent's constraints through unchanged, so a pending image lays out exactly like a ready one: in a fixed slot it takes the slot size and `fit` (e.g. `cover`) fills the slot rather than a box sized to the image's own aspect ratio.

The source owns asset/network/SVG selection. The built-in source supports bundled raster assets only; network and SVG behavior requires the app-installed `ImageSource`. A source that manages loading internally receives the same loading/error widgets in its request.

```yaml
_type: image
src: assets/profile.png
width: 96
height: 96
fit: cover
_slots:
  loading: { _type: skeleton, width: 96, height: 96, shape: circle }
  error: { _type: icon, name: broken_image }
```

## Video

See the full [`video` widget reference](widgets/custom/video.md). `VideoSource.controllerFor(VideoRequest(src))` returns an uninitialized `SduiVideoController` — a plugin-free contract; the package's `PlayerVideoController` wraps `video_player` for sources that don't bring their own player. The widget initializes it, applies `loop` (default true), volume from `muted` (default false), and `autoplay` (default true).

Until initialization succeeds, and after initialization failure, video renders an empty box. `aspect_ratio` overrides the controller ratio; `fit` defaults to `cover`. `show_controls: true` adds an opaque tap target that toggles play/pause. When looping is false, reaching the end dispatches `on_end` once per source/playback reset. `on_ready` dispatches once the slot first becomes renderable for the current `src`, and `on_error` dispatches once if initialization fails for the current `src`; a `src` change resets both. Changing `src` disposes and replaces the controller; changing `loop` or `muted` updates the existing controller.

The default `AssetVideoSource` treats `src` as a bundled asset. Network policy belongs to the app-installed `VideoSource`.

```yaml
_type: video
src: assets/intro.mp4
autoplay: false
loop: false
show_controls: true
fit: contain
on_end: finished
```

## 3D models

See the full [`model_3d` widget reference](widgets/custom/model_3d.md). `Model3dSource.controllerFor(Model3dRequest(src))` returns an unloaded `SduiModel3dController` — a renderer-free contract, so a webview `<model-viewer>`, Filament, or SceneKit implementation can back it. The package ships no renderer: `model3dSource` is optional, and without it `model_3d` renders its `poster` image only. `Model3dSource.warmUp()` runs once in the background after boot, for expensive first-time setup before the first `model_3d` mounts.

### Filament renderer (`sdui_model_filament`)

The renderer this repository provides is a separate package,
[`packages/sdui_model_filament`](../packages/sdui_model_filament/README.md). It
lives in this repository but is not part of `sdui_engine`: the engine does not
depend on it, it depends on the engine, and it is published on its own.

- **Apps without 3D need nothing.** Depend on `sdui_engine` alone; `model_3d`
  shows its `poster`.
- **Apps that render 3D models** add the package and pass the source:

  ```yaml
  dependencies:
    sdui_engine:
      hosted: http://100.115.77.18:28400/api/packages/david/pub
      version: 0.27.0
    sdui_model_filament:
      hosted: http://100.115.77.18:28400/api/packages/david/pub
      version: 0.1.0
  ```

  ```dart
  Sdui.initialize(
    // ...
    model3dSource: FilamentModel3dSource(
      client: gatewayHttpClient,     // the app's gateway client; required
      baseUrl: Uri.parse(apiUrl),    // origin that `/assets/...` srcs resolve against
    ),
  );
  ```

It is kept out of the engine because of its cost, which every app would carry
otherwise:

- Flutter `>=3.38.0` (the engine needs `>=3.24.0`) and iOS 13+.
- Filament's native libraries link into the app. The first build downloads
  them from thermion's R2 bucket — the Filament 1.69.1 release archives are
  21 MB for iOS and 51 MB for Android (all ABIs). The installed app grows by
  less, since the linker keeps only what is used; that growth is not measured
  yet.
- Filament runs in-process, so its memory counts toward the app's.

The widget mounts the controller's view under the poster at once, calls `initialize()`, reads `clips`, and drives `play(clip, loop:, crossfade:)` and `stop()` from the template's states. A non-looping clip holds its last frame and advances `Model3dPlayback.completions`; the engine detects a clip end by that counter. The engine owns gestures and the camera: it calls `setCamera(Model3dCamera(yaw, pitch, zoom))` right after creation and on every frame the camera moves, and the view never receives pointers, so every renderer moves the same way for the same template. For `progress` the engine also owns the playhead: it reads `clipDuration(clip)` and calls `setPose(clip, time)` on every frame the playhead moves. A failed `initialize()` is final — the widget disposes the controller and asks for a new one to retry — and `dispose()` may arrive while calls are still in flight; the contract's doc comments state the concurrency rules. Changing `src` disposes and replaces the controller; changing `state`, `camera`, `controls` or `auto_rotate` reuses it.

```yaml
_type: model_3d
src: /assets/character.glb
poster: /assets/character.png
height: 200
state: '${mood}'
states:
  idle: { clip: Idle, loop: true }
  jump: { clip: Jump, next: idle }
```
