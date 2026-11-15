# sdui_model_filament

Filament renderer for the [sdui_engine](../../README.md) `model_3d` widget,
through [`thermion_flutter`](https://pub.dev/packages/thermion_flutter) 0.6
(Filament 1.77.2).

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
- `frameRate` defaults to 60 fps and is applied immediately after each viewer
  is created, including warm-up. The engine paces camera and progress motion
  to the same rate without requesting Flutter frames. `frameRate: null` uses
  the display rate. Speeds and durations are unchanged; hidden views pause
  their motion clocks and resume from the paused value.
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
them. Requires Dart 3.12+, Flutter 3.44+ and iOS 16+ (sdui_engine's minimum).

Android: thermion_flutter 0.6.1 compiles against SDK 33, below what its AndroidX
dependencies require, so the app's `android/build.gradle.kts` raises it:

```kotlin
subprojects {
    if (name == "thermion_flutter") {
        afterEvaluate {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 36
            }
        }
    }
}
```

Put this block before `project.evaluationDependsOn(":app")`.

Status: Dart surface covered by widget tests (view before load, overlay,
playback state, byte and disk caches, render gate). The native path runs on a
Galaxy S25, a Galaxy A32 and an iPhone 13 mini.

## Framing

Models keep their glTF transforms. The camera orbits the centre of the selected
GLB scene's initial pose and frames its bounding sphere at zoom 1 (radius is
half the world-extent diagonal), so wide and boxy models fit as well. Near/far clipping follows model
size, and far clipping also covers zoom-out. Bounds include ancestor matrix/TRS transforms, skin joint
weights and inverse binds, and the node's or mesh's default morph weights.
The renderer computes bounds once on a background isolate while the native
model loads; look and animation updates do not recalculate them. The contact
quad uses the same world-space extent and lowest height. The load log reports
initial-bounds elapsed time, including isolate scheduling.

The decoder handles interleaved and sparse accessors. Draco, Meshopt, external
accessor buffers, or malformed geometry log a bounds fallback and keep
Thermion's previous normalization. They may retain the earlier framing limits.
Bounds fit the initial pose; animation can extend outside that box.

## Model look

The engine's [`model_3d` look props](../../docs/widgets/custom/model_3d.md#lighting-and-shadows)
apply on the existing native lane without a model reload. Omitted props preserve
the studio IBL at `iblIntensity`, FXAA, medium render quality, no direct light,
no shadow and no new color grading. `lighting.environment` multiplies IBL;
rotation is reapplied after each IBL reload. An optional `light` defaults to
45° yaw/pitch, intensity 1 (100,000 lux), white; setting it to false removes it.

`shadow: contact` draws an unlit, blended radial-gradient ground quad.
`shadow: cast` also enables key-light casting and model cast/receive, while
without a light it behaves as contact. The ellipse opacity defaults to 0.5.
The quad, material and texture are allocated once and reused on look changes.
Partial allocation failures and disposal release their resources.

`quality: low` uses FXAA / low quality / AO off; medium uses FXAA / medium /
AO off; high uses MSAA + FXAA / high / AO on / PCSS. MSAA is a boolean in
Thermion; the effective sample count has not been measured on device for this
change. `exposure` is in stops (default 0); returning to 0 detaches grading.
Look changes wake the render gate. Lights, contact resources and grading are
released before the viewer; grading is detached before destruction.

The bundled 64×64 RGBA contact texture is generated using only Python's standard
library. Run this from the package directory to reproduce it (no generator
script is installed):

```sh
python3 - <<'PY'
import math, struct, zlib
n = 64
rows = b''.join(b'\0' + b''.join(
    bytes((0, 0, 0, round(255 * max(0, 1 - math.hypot(
        (x + .5) / n * 2 - 1, (y + .5) / n * 2 - 1)) ** 2)))
    for x in range(n)) for y in range(n))
def chunk(kind, data):
    return (struct.pack('!I', len(data)) + kind + data
            + struct.pack('!I', zlib.crc32(kind + data)))
png = (b'\x89PNG\r\n\x1a\n'
       + chunk(b'IHDR', struct.pack('!2I5B', n, n, 8, 6, 0, 0, 0))
       + chunk(b'IDAT', zlib.compress(rows)) + chunk(b'IEND', b''))
open('assets/contact_shadow.png', 'wb').write(png)
PY
```

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


## Scene and focus

[`scene`, `camera.target` and `controls.pan`](../../docs/widgets/custom/model_3d.md#scene)
share the primary viewer. Extras load independently through the same cache;
primary initialization never awaits them. List index identifies each slot;
transform/clip/spin edits reuse its asset, while source replacement and removal
release only that slot. Duplicate sources are independent native instances.
Controller-owned placement entities retain all authored glTF transforms, with
position in primary world units, yaw(Y)/pitch(X)/roll(Z) in degrees, uniform
scale and own-origin local spin applied in that order. Optional extra clips loop.
All models share lighting and receive current cast/receive settings.

A single native request-frame hook advances active spins by elapsed time and
updates primary node focus during playback. There is no Flutter ticker or
per-extra timer. Hidden scenes keep assets and phase, stop extra clips and
release their rendering hold. Primary playback, extra loops and extra spins
share one aggregate render-gate decision. Hook registration is outside the
native lane to avoid waiting on a hook that needs that lane.

Point targets are in primary glTF world units; node targets use the primary's
current node world position, with extent-centre fallback when absent. Easing
resolves flattened weighted leaves. Pan moves eye and focus together by the
primary extent diagonal in the camera plane; x is right and y is down. Extras
never affect framing or primary readiness. Failed extras are logged and skipped;
stale loads cannot replace current slots, and disposal releases extras,
placement entities and the frame hook before the viewer.


## Outfit

The engine's [`outfit`](../../docs/widgets/custom/model_3d.md#outfit) updates
primary node visibility, every primitive of a named material, and cached rigid
props attached to named primary nodes without reloading the character.
`FilamentModel3dController` implements the optional `Model3dOutfitController`.
The first snapshot cuts; later changed rigid parts use placement parents for
pop/drop so glTF animation keeps owning local transforms. Drop offsets stay in
primary world units under scaled/rotated sockets. Skinned parts use an isolated
emissive flash and a subtle whole-character pop (1 → 1.04 → 1) for pop/drop and
opaque/masked dissolve; the root placement includes the joints. BLEND primitives
use isolated material instances for dissolve. Skin flashes restore authored
emissive factors and leave unchanged parts' materials alone.
Recolouring converts template sRGB to linear baseColorFactor and cross-fades in
linear space. Look changes also update attached and exiting props' shadows. Transitions share the
native frame hook and aggregate render hold, settle deterministically when
superseded, and release their parents and props when the viewer is disposed.
Follow the widget's asset authoring contract; separate skinned clothing is not
supported by Thermion's Dart API.

## Expressions and motion

`Model3dMotionController` applies named morph weights on every matching primary
mesh. The engine supplies eased expressions/blink and view-normalized pointer
targets. Look-at/layers switch the primary out of Thermion component playback:
the native request-frame hook evaluates base, outgoing/incoming layer, manual
morphs, then clamped/weighted local look-at, and updates bone matrices. This avoids
Thermion's later animation update overwriting a hook-applied bone rotation.
Camera, pose, morph and motion configuration changes queue work for the next
request-frame hook, including initial and reused poses. Gaze follows the current
pose continuously: `duration` controls its response, with a combined yaw/pitch
speed limit of 180 degrees per second even when duration is zero. Outside the
yaw cone, it holds the clamp on the side it left until the target re-enters the
cone; crossing directly behind the model does not flip the head.
Static poses do not accumulate look-at rotations; hidden views stop motion holds.
Layer completion increments `layerCompletions` and notifies playback listeners.
Weight-only updates preserve the cursor and completion state while retargeting
the envelope from its current effective weight; clip or loop changes restart.

Base clip switches cut in this mode; layer entrance/exit envelopes interpolate
local node TRS from successive poses, rather than native clip crossfade or a
general weighted animation mixer. Outside this mode, clip-animated morph targets
can overwrite manual expressions. See the engine's [asset and template contract](../../docs/widgets/custom/model_3d.md#expressions-and-motion).

## Model taps

The controller implements optional `Model3dTapController`. `View.pick` submission
uses the native lane, but waiting for the callback does not; an aggregate render
hold stays active until the result or a 150 ms bound. Hits expose original node
names and unambiguous material names on the primary model. Logical tap positions
are scaled by the view's current device pixel ratio before native picking.
No accessible geometry buffers are requested during loading, warm-up or reuse.
See the engine's [template contract](../../docs/widgets/custom/model_3d.md#model-taps).

## Renderer reuse

Disposed views retain their private viewer and primary asset for `keepAlive`
(default 10 seconds, at most two viewers). Remounting the same `src` takes that
viewer without another download or native model parse, even if the byte cache
has since evicted it. Transforms, morph defaults (node weights, then mesh
weights, then zero), visibility, materials and viewer look settings are restored
before the new template applies. Extras, props, contact shadows, lights and
custom grading are released on disposal. Set `keepAlive: Duration.zero` to
release immediately. Kept viewers have native rendering disabled; expiry and
Flutter memory pressure release them through the platform, including textures.

`warmUp()` retains its viewer for the first mount. The first `cachedModels`
distinct `prefetch` entries (default four) are also parsed into private native
assets ahead of mounting. Matching mounts take those viewers; a non-matching
first mount reuses the warm-up viewer after destroying its prefetched asset.
Unused warm-up and prefetched viewers are also released on memory pressure.
A failed warm-up reports its error but later mounts can still load normally.

Concurrent views share the byte/disk cache only. Thermion 0.6.1 cannot isolate
material mutations across `createInstance()` instances, so each active view
loads its own private asset. Measure
first-display timing using the existing `ready` load mark; no device timing
improvement is claimed by the Dart tests.
