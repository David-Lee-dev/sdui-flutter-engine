# Changelog

## 0.1.0

- `FilamentModelSource` / `FilamentModelController`: a `ModelSource` for the
  sdui_engine 0.21 `model` widget rendering with Filament through
  `thermion_flutter` 0.5, with a transparent background, the bundled studio
  IBL, the engine-driven camera (`setCamera`), clip playback with crossfade,
  `progress` poses (`setPose` through `setGltfAnimationTime`, stopping that
  clip's playback first), and the `sdui_model_support` byte cache and debug
  overlay.
- Frames render only while a model changes or plays: the process-wide frame
  loop pauses 300 ms after the last camera move, pose or load and stays
  running while a clip plays. On a Galaxy S25 a still model went from ~126
  composited frames and ~80% of a core per second to ~2 frames and ~4–8%.
