# sdui_model_filament

Filament renderer for the [sdui_engine](../../README.md) `model_3d` widget,
through [`thermion_flutter`](https://pub.dev/packages/thermion_flutter) 0.5
(Filament 1.69.1).

```dart
Sdui.initialize(
  model3dSource: FilamentModel3dSource(
    client: gateway.httpClient,          // the app's gateway client (NemoClient)
    baseUrl: Uri.parse(apiUrl),          // the gateway origin for `/assets/...`
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
- Models download through `client`, the app's gateway client, so they take the
  same pinned, authenticated route as the app's other requests. It is required:
  there is no default client. `/path` srcs resolve against `baseUrl`; a full
  URL loads only on `baseUrl`'s origin, so gateway credentials never reach
  another host. Fetched models persist across launches in the app's cache
  directory (64 MB, least recently used first), revalidated in the background
  by ETag; `diskCache: false` keeps them in memory only.
- Models are glTF binary (`.glb`). The clip names a template's `states` and
  `progress` use are the GLB's animation names, matched exactly; when names
  repeat, the first animation with the name plays.
- Clips play with `crossfade`; Filament reports no end event, so a
  non-looping clip completes after its duration.
- Lighting is Filament's neutral studio IBL (`assets/lightroom_ibl.ktx`,
  Apache-2.0, see `assets/FILAMENT_LICENSE`).
- `warmUp()` creates the Filament engine and render thread ahead of the first
  mount.
- Frames render only while a model changes: Filament's frame loop runs while
  the camera moves, a pose changes or a clip plays, and pauses 300 ms after the
  last change (`RenderGate`). A still model keeps its last frame on screen and
  costs no frames. Each model renders on its own: with several on screen, only
  the ones that change or play are drawn in a frame.
- `debugOverlay: true`, or `--dart-define=SDUI_MODEL_DEBUG=true`, paints each
  view's load timeline (`viewer → model → asset → ready`), app RSS (Filament
  runs in-process, so it is included) and frame times since ready.

Build: thermion uses Dart build hooks. The first build downloads prebuilt
Filament static libraries from thermion's Cloudflare R2 bucket and caches
them. iOS 13+.

Status: Dart surface covered by widget tests (view before load, overlay,
playback state, byte and disk caches, render gate). The native path runs on a
Galaxy S25, a Galaxy A32 and an iPhone 13 mini.

## Publishing

Publish from a copy outside the repository. The repository root's `.pubignore`
excludes `packages/` so that `sdui_engine` does not ship this package, and pub
applies that rule here too: `dart pub publish` in this directory builds an
empty archive.

1. Commit and push; bump `version` and `CHANGELOG.md` first, since a published
   version cannot be overwritten.
2. Export the committed package and publish from the copy:

   ```sh
   out=$(mktemp -d)
   git archive HEAD packages/sdui_model_filament | tar -x -C "$out"
   cd "$out/packages/sdui_model_filament"
   dart pub publish --dry-run   # expect ~68 KB, not <1 KB
   dart pub publish --force
   ```

3. Remove the copy: `rm -rf "$out"`.
