# Changelog

## 0.3.0

- Requires sdui_engine ^0.29.0 (Model3dSource.frameRate and the optional
  look/scene/outfit/motion/tap capabilities).
- Queue camera/pose/morph/configuration and reuse pose writes in the
  native frame hook. Look-at follows moving targets continuously with a 180°/s
  angular limit (including zero duration) and holds its exit side behind the
  model until cone reentry, avoiding auto-rotate head flicker. The effective yaw
  cone is capped at 170° so even `maxYaw: 180` preserves rear-side hysteresis.

- Split native sequencing, viewer reuse, GLB preparation, framing,
  look, outfit, motion and scene ownership into separate libraries. Reuse resets
  through the same look-default path; bounds decoding shares strict GLB parsing
  and rejects oversized zero-base accessors before allocation.

- Retain up to two disposed private viewers for 10 seconds
  (`keepAlive`, zero disables), restore authored state before same-source reuse,
  disable kept viewers' native rendering and release on expiry/memory pressure.
  Reuse warm-up's viewer and parse bounded prefetch assets before first mount;
  preserve warm handoff for non-matching sources. Concurrent views share cached
  bytes only because Thermion cannot isolate instance materials.

- Model-hit actions through the optional tap capability, with original
  node/material names, view DPR and bounded picking. `model_3d_tap_v1` is
  declare-only. Loading, warm-up and prefetch no longer request CPU geometry.

- Primary morph updates on every matching mesh and renderer-driven
  base/layer/look-at posing. Bone turns compose with fresh animated transforms;
  layers blend node TRS weights with entrance/exit envelopes and report ends.
  Base switches cut while look-at/layer is enabled. Native clip crossfades and
  general weighted morph-channel blending are unavailable in this mode. Weight-only
  layer changes retain the cursor and completion state and retarget the envelope.

- Model outfit show/hide, material recolouring and cached socket
  props with cut/pop/drop/dissolve swaps. Immutable optional outfit capability
  preserves existing controllers; changes keep the primary model and clips.
  `model_3d_outfit_v1` is declare-only. Skinned parts flash their isolated
  emissive factors with a whole-character pop; rigid drop respects ancestor
  transforms. Recolours use linear factors, and look changes reach prop shadows.
  Unreadable outfit metadata preserves the original bytes for native loading,
  including legacy NUL-padded JSON, unsupported headers and invalid JSON lengths.

- Independently cached scene extras with authored transforms,
  looping clips and native-frame-hook spin; per-slot reconciliation, hidden-scene
  pause, shared lighting/shadows and aggregate rendering holds. Point/node focus
  and pan use primary world space, with node updates during playback/pose.
- Frame the primary bounding sphere (half the world-extent diagonal)
  instead of the largest half-edge margin so wide/boxy models fit at zoom 1.

- Frame models using selected-scene initial-pose bounds, including
  node transforms, weighted skin joints, inverse binds and default morphs.
  Keep glTF transforms intact and frame the camera from the world-space
  centre and extent, with scale- and zoom-aware clipping. Compute bounds on a
  background isolate while the native model loads; reuse them for contact-shadow
  height and size. Unsupported geometry keeps native normalization with a log.

- Apply `Model3dLook` environment/rotation, directional key light,
  reusable textured contact shadow, cast/receive self-shadowing, AA/render
  quality/AO presets and exposure. Release look resources with the viewer.

- `FilamentModel3dSource(frameRate: 60)` caps rendering from every
  viewer's creation and reports the rate to the engine for camera and progress
  pacing. `frameRate: null` uses the display rate.

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
