# Changelog

## 0.1.0

- `ModelBytesCache`: loads model files by template `src` (http(s), `/path`
  against a base URL, or a bundled asset) and keeps the most recent in memory.
- `gltfClipDurations`: every clip's length in a `.glb`, read from the JSON
  chunk alone (the animation input accessors' `max`).
- `ModelLoadStats`, `FrameStats` and `ModelDebugOverlay` for measuring model
  load timelines, app memory and frame times on device.

Extracted from `sdui_model_viewer` so every renderer shares them.
