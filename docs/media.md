# Media

The `image`, `video`, and `model` widgets delegate source resolution to app-installed policies while retaining template-facing presentation behavior in the engine.

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

See the full [`model` widget reference](widgets/custom/model.md). `ModelSource.controllerFor(ModelRequest(src))` returns an unloaded `SduiModelController` — a renderer-free contract (the engine owns gestures and drives the camera through `setCamera`, and owns the playhead of a `progress` clip, posing it through `setPose`), so a webview `<model-viewer>`, Filament, or SceneKit implementation can back it. The package ships no renderer: `modelSource` is optional, and without it `model` renders its `poster` image only.

The widget maps template states to clips (`states: { idle: { clip: Idle, loop: true }, jump: { clip: Jump, next: idle } }`), crossfades between them, follows `next` when a non-looping clip ends, and dispatches `on_state_end`. The poster shows until the model is ready and replaces it when loading fails. When the renderer is missing, fails, or lacks a clip, non-looping states end immediately so template flows never wait on rendering. `ModelSource.warmUp()` runs in the background after boot for renderer setup such as creating a webview.

```yaml
_type: model
src: /assets/character.glb
poster: /assets/character.png
height: 200
state: '${mood}'
states:
  idle: { clip: Idle, loop: true }
  jump: { clip: Jump, next: idle }
```
