# Changelog

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
