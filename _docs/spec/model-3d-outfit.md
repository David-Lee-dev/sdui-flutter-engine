# model_3d outfit (0.29.0)

User decisions: dress-up by showing/hiding clothing meshes that live in the character GLB and attaching rigid props (hats, weapons) from separate GLBs to sockets (2026-11-13, phase 1 approved); swaps animate (cut, dissolve, drop, pop); assets will be served from a CDN. Asset authoring contract: fixed bone names; one node per clothing variant; `socket_*` empty nodes parented to bones; a separate material per recolourable part; body split into segments that clothing hides; rigid props authored with their origin at the socket. Structure decisions delegated to main for this session (2026-11-14).

Facts (thermion 0.6.1): node visibility by `scene.addEntity`/`removeEntity` of the node's renderable entities (`asset.getChildEntities`/`getChildEntityNames`/`getChildEntity(name)`); `setParent` attaches a loaded prop asset under a node; `renderableManager.getMaterialInstanceAt` (the asset wrapper ignores its index argument) + `setParameterFloat4('baseColorFactor', …)` recolours; `asset.setTransform(Matrix4, entity:)` animates a node's local transform; `attachSkin` is not exposed in Dart, so skinned clothing cannot come from a separate GLB.

## Requirements
- O1 `model_3d` gains optional `outfit` map:
  - `show`: list of node names to make visible; `hide`: list to make invisible. Nodes not named keep their glTF visibility. A name in both lists is shown.
  - `colors`: `{ material_name: color }` recolours the base colour factor of every primitive using that material (textures are multiplied, as glTF does).
  - `attach`: `{ node_name: src }` loads `src` (GLB, through the same byte/disk cache) and parents it at that node (by convention `socket_*`, any node name works); `null` or removal detaches and destroys it. A changed `src` replaces the prop.
  - `transition`: `cut` | `pop` (default) | `drop` | `dissolve`; `transition_duration` milliseconds (default 300). Only parts whose state changed animate: shown/attached parts enter, hidden/detached parts leave. `pop` scales from 0 with a slight overshoot; `drop` falls in from above with a small bounce (leaving parts shrink out); `dissolve` fades materials whose alpha mode allows blending and otherwise behaves like `pop`; `cut` is immediate. Recolouring cross-fades the colour over the same duration (except `cut`).
- O2 Applying an outfit never reloads the character (no poster, clips keep playing). The first outfit after load applies without a transition. Unknown node/material names are ignored with a debug log.
- O3 Contract: the optional exported `Model3dOutfitController` declares `void setOutfit(Model3dOutfit outfit);`; engine-internal dispatch is a no-op for unsupported controllers, preserving existing implements-based hosts; immutable `Model3dOutfit` (show, hide, colors, attach, transition, duration) exported. Called after creation and on every change, before/after `initialize` (latest kept, applied when loaded), like `setCamera`.
- O4 Declare-only feature `model_3d_outfit_v1`.
- O5 The render gate stays held while a transition runs and settles after it. Attached props are destroyed with the viewer.
- O6 Docs: widget doc comment, `docs/widgets/custom/model_3d.md` (with the asset authoring contract), renderer README; unreleased CHANGELOG entries. Do not publish.

## Tests
Engine (fake controller): `outfit` parses (lists, colors with colour values, attach with null, transition names, invalid values dropped); a change calls `setOutfit` without reload; absent prop → no outfit calls beyond the default empty outfit.
Renderer (fake viewer/asset): show/hide add/remove the named node's entities; unknown names ignored; colors set baseColorFactor on the material's instances; attach loads once, parents to the node, detaches and destroys on removal, replaces on src change; first outfit applies without transition; later changes animate (transform/colour calls over time, gate held, final state exact); `cut` immediate; dispose destroys props.
Device: RobotExpressive with its part meshes hidden/shown and a generated hat GLB attached to `Head`, swapping every 2 s with `pop`/`drop`, at 60 fps; record CPU/GPU/PSS.
