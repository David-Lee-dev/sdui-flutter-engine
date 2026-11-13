# Changelog

## 0.2.0

- Upgrade to `thermion_flutter` ^0.6.1 (Filament 1.77.2).
- Require Dart 3.12+ and Flutter 3.44+; iOS 13+ stays supported.
- Preserve the renderer API, loading, playback, camera and render-gate behavior.

## 0.1.0

- `FilamentModel3dSource` / `FilamentModel3dController`: a `Model3dSource` for the
  sdui_engine 0.21 `model_3d` widget rendering with Filament through
  `thermion_flutter` 0.5, with a transparent background, the bundled studio
  IBL, the engine-driven camera (`setCamera`), clip playback with crossfade,
  `progress` poses (`setPose` through `setGltfAnimationTime`, stopping that
  clip's playback first), and a measurement overlay (`debugOverlay`).
- Frames render only while a model changes or plays: the process-wide frame
  loop pauses 300 ms after the last camera move, pose or load and stays
  running while a clip plays. On a Galaxy S25 a still model went from ~126
  composited frames and ~80% of a core per second to ~2 frames and ~4–8%.
  Each view is also left out of the frames while it is still, so a moving
  model does not redraw the others on screen.
- Models download through the app's gateway client (`client`, required, no
  default) and only from `baseUrl`'s origin, and persist across launches
  (`diskCache`, default on): a model seen once opens from disk, revalidated in
  the background.
- Native calls on a viewer run one after another, so disposing a view while
  it loads or moves destroys the viewer only after the call in flight, and
  no later call reaches it. Each play takes a run number: a superseded play's
  late native work or end timer, or a late `stop`, never changes the newer
  playback.
- Clips keep their native animation index, so a clip after a repeated name
  plays and poses itself; a repeated name plays its first animation.
- `ModelLoadStats` is internal: it only feeds the debug overlay.
