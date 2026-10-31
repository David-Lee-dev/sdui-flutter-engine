# sdui_model_filament

Filament renderer for the [sdui_engine](../../README.md) `model` widget,
through [`thermion_flutter`](https://pub.dev/packages/thermion_flutter) 0.5
(Filament 1.69.1).

```dart
Sdui.initialize(
  modelSource: FilamentModelSource(
    baseUrl: Uri.parse(apiUrl),          // resolves `/assets/...` srcs
    prefetch: ['/assets/character.glb'], // loaded during warm-up
  ),
  // ...
);
```

- Renders natively into a Flutter `Texture` (Metal on iOS), so the view clips,
  transforms, fades and screenshots like any widget.
- The engine owns gestures and auto-rotation (`camera`, `controls`,
  `auto_rotate`); `setCamera` orbits Filament's camera around the model,
  collapsing per-frame calls while one is in flight.
- Model bytes come from `ModelBytesCache` (`sdui_model_support`): `src`
  resolution and prefetch match `sdui_model_viewer`.
- Clips play with `crossfade`; Filament reports no end event, so a
  non-looping clip completes after its duration.
- Lighting is Filament's neutral studio IBL (`assets/lightroom_ibl.ktx`,
  Apache-2.0, see `assets/FILAMENT_LICENSE`).
- `warmUp()` creates the Filament engine and render thread ahead of the first
  mount.
- `debugOverlay: true`, or `--dart-define=SDUI_MODEL_DEBUG=true`, paints each
  view's load timeline (`viewer → model → asset → ready`), app RSS (Filament
  runs in-process, so it is included) and frame times since ready.

Build: thermion uses Dart build hooks. The first build downloads prebuilt
Filament static libraries from thermion's Cloudflare R2 bucket and caches
them. iOS 13+.

Status: Dart surface covered by widget tests (view before load, gesture
arena, overlay, playback state). The native path has not yet run on a device.
