# Changelog

## 0.1.0

- `ModelBytesCache`: loads model files by template `src` (http(s), `/path`
  against a base URL, or a bundled asset) and keeps the most recent in memory.
- `gltfClipDurations`: every clip's length in a `.glb`, read from the JSON
  chunk alone (the animation input accessors' `max`).
- `ModelLoadStats`, `FrameStats` and `ModelDebugOverlay` for measuring model
  load timelines, app memory and frame times on device.

- `ModelDiskCache`: fetched models persist in the app's cache directory
  (`ModelBytesCache(disk: ...)`). A stored copy serves at once, even offline,
  and is revalidated in the background with the server's ETag /
  Last-Modified, so a file replaced at the same URL shows from the next
  launch. Least recently used files go past `maxBytes` (64 MB).

Extracted from `sdui_model_viewer` so every renderer shares them.
