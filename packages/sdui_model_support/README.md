# sdui_model_support

Renderer-agnostic helpers shared by the renderers of the
[sdui_engine](../../README.md) `model` widget
([`sdui_model_viewer`](../sdui_model_viewer), webview;
[`sdui_model_filament`](../sdui_model_filament), Filament). Apps install a
renderer, not this package.

- `ModelBytesCache` resolves a template `src` (`http(s)://` as is, `/path`
  against `baseUrl`, anything else a bundled asset key), loads it once and
  keeps the most recent models in memory (LRU), so prefetch and revisits skip
  the network.
- `ModelDiskCache` keeps fetched models in the app's cache directory across
  launches. `ModelBytesCache(disk: ...)` serves a stored copy at once (also
  offline) and revalidates it in the background with the server's ETag /
  Last-Modified, so replacing a file at the same URL reaches users from their
  next launch. Least recently used files go past `maxBytes`.
- `ModelLoadStats` records one view's load timeline (`mark`, `served`,
  `fail`, `summary`). `ModelDebugOverlay` paints it over the view with the
  app process's RSS and Flutter frame times since ready, for measurement on
  device.
