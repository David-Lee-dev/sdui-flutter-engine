# model_3d framing uses the model's real extent (renderer 0.3.0 bug fix)

Found 2026-11-14 on the Galaxy Z Flip6 with screenshots: since the thermion 0.6.1 upgrade (renderer 0.2.0, published), `Fox.glb` renders but `Xbot.glb`, `RobotExpressive.glb` and `AnimatedMorphCube.glb` are invisible even at `camera.zoom: 0.1`; only the contact-shadow quad shows. Structure decisions delegated to main for this session.

Cause (thermion_dart 0.6.1 source): `FFIAsset.getBoundingBox` hulls `RenderableManager.getBoundingBox(entity)` of each renderable, which is that renderable's local-space AABB, without applying node transforms (`lib/src/filament/src/implementation/ffi_asset.dart:426`). `transformToUnitCube` then scales the root by that box. Models whose nodes carry scale/rotation (Mixamo-style armature scale 0.01, glTF node scales) get a box in the wrong units and end up far too small (or misplaced). The renderer's contact-shadow placement also reads this box.

## Requirements
- B1 The renderer frames every model by its real rendered extent: the hull of all renderables in the asset's world space, including node transforms, and for skinned meshes the extent of the posed/bind-posed mesh (skinning ignores the mesh node's transform in glTF; joints carry the armature transform). Framing is done by the camera, not by transforming the model (2026-11-14 device finding: a root `setTransform` does not reliably scale single-root assets such as RobotExpressive): the model keeps its glTF transforms, the orbit target is the extent's centre, and the zoom-1 distance is proportional to the extent so that `zoom: 1` gives the same picture as before for models whose old framing was right (Fox). Camera near/far planes follow the extent. Assets whose bounds cannot be computed (unsupported encodings) keep the old `transformToUnitCube` path.
- B2 The contact-shadow ground quad (look `shadow: contact|cast`) uses the same corrected extent for its height and size.
- B3 The computation happens once per load (not per frame) and does not delay `ready` perceptibly (< 20 ms on the Galaxy for Xbot). Measured with the first implementation: Xbot 30–37 ms on the UI isolate, so it must move off the critical path (e.g. computed while the native asset loads, or on a background isolate).
- B4 Renderer `CHANGELOG.md` `## 0.3.0` (unreleased) notes the fix. Do not publish.

## Tests
Renderer (fake viewer/asset): no root transform is set for computed bounds; the camera looks at the extent centre from a distance proportional to the extent (a 0.01-scaled/rotated fixture and its unscaled twin give camera positions scaled accordingly), and a fixture without node transforms gets the same picture as before; a skinned fixture uses the joint-driven extent; the contact quad position follows the corrected extent.
Device (Galaxy, bench screenshots): Fox, RobotExpressive, Xbot and AnimatedMorphCube are all visible and similarly framed at `zoom: 1`; RobotExpressive/Xbot contact shadows sit at their feet.
