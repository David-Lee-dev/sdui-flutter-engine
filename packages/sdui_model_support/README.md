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
- `ModelLoadStats` records one view's load timeline (`mark`, `served`,
  `fail`, `summary`). `ModelDebugOverlay` paints it over the view with the
  app process's RSS and Flutter frame times since ready, for measurement on
  device.
