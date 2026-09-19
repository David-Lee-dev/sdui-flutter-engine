# Media

The `image` and `video` widgets delegate source resolution to app-installed policies while retaining template-facing presentation behavior in the engine.

## Images

See the full [`image` widget reference](widgets/display/image.md). An `ImageRequest` carries `src`, dimensions, fit, tint/color blend, alignment, repeat, semantic label, cache dimensions, and the `loading`/`error` slots to `ImageSource.resolve`.

The result policy is:

- `NoImage` renders `SizedBox.shrink`; an empty/non-string `src` does this before source resolution.
- `ReadyImage` renders immediately. The default `AssetImageSource` treats `src` as a bundled asset path and applies the request properties.
- `PendingImage` uses the `loading` slot while pending, or an engine shimmer placeholder sized from width/height. Completion with null uses the `error` slot or an empty box. Loaded content and placeholder pass through the engine's loading-image transition/cross-fade.

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

Until initialization succeeds, and after initialization failure, video renders an empty box. `aspect_ratio` overrides the controller ratio; `fit` defaults to `cover`. `show_controls: true` adds an opaque tap target that toggles play/pause. When looping is false, reaching the end dispatches `on_end` once per source/playback reset. Changing `src` disposes and replaces the controller; changing `loop` or `muted` updates the existing controller.

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

