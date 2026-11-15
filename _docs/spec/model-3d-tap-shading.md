# model_3d tap (0.29.0)

User decision 2026-11-15: remove `shading`, `outline` and `highlight_on_tap` before release because thermion 0.6.1 built-in materials cannot produce the required illustrated result perfectly. P2 is withdrawn; P1 tap remains. See [refactor requirements](model-3d-refactor.md).

Facts (thermion 0.6.1): `View.pick(x, y, handler)` has 2–3 frames latency; `PickResult` carries the entity and `asset.getChildEntityNames()` maps entities to authored names. Picking needs no accessible geometry buffers.

## Requirements
- P1 Tap (9): `on_tap_model` dispatches `{ node, material }` for a model hit; either name may be null, and misses dispatch nothing. Without the action prop, no picks are requested and taps still reach ancestors. The optional exported `Model3dTapController` declares `Future<Model3dHit?> hitTest(Offset localPosition)`; engine-internal capability dispatch returns null for unsupported controllers. `model_3d_tap_v1` is declare-only. Existing implements-based controllers remain compatible.

## Tests
Engine: hit dispatches node/material; miss dispatches nothing; absent action preserves ancestor taps without picking; removed props are ignored; the removed feature declaration is rejected. Drags, long presses, multiple pointers and cancellations do not pick.
Renderer: hitTest maps entities to node/material names and returns null on miss or after dispose, without accessible geometry buffers.
Device: tap-to-action latency under 150 ms on the Galaxy at 60 fps.
