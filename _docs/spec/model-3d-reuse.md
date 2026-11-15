# model_3d renderer reuse and first display (renderer 0.3.0)

User decisions 2026-11-14: tap reactions on model parts (9), a non-photoreal look matching illustrated apps (4; no Filament material compiler available, so only thermion's built-in materials), sharing/reusing renderers when several views or revisits occur (14) and a faster first display (15). Structure decisions delegated to main for this session. Measure on the Galaxy only; 60 fps target.

Facts (thermion 0.6.1): `asset.createInstance()` shares one loaded asset's resources. Concurrent views need isolated mutable material state; keep-alive reuse transfers a single viewer/asset lease.


Device baseline (Galaxy Z Flip6, 2026-11-14): one model view adds ~90 MB PSS (Filament engine + IBL) and Xbot ~130 MB; four Xbot views add ~195 MB and drop the frame rate from 120 to ~75 fps before the 60 fps cap (60 fps after it). First-ready after warm-up: viewer ~20-170 ms, asset ~30-230 ms.

## Requirements
- P3 Reuse (14): several `model_3d` views of the same `src` share one loaded asset's resources (`createInstance`) where the renderer can; a view disposed and remounted with the same `src` within a short keep-alive window (renderer option, default 10 s, at most 2 viewers kept) reattaches the kept viewer/asset instead of loading again, so navigating back shows the model without the poster. Kept viewers render nothing and are released when the window ends or memory pressure is signalled (`didHaveMemoryPressure`). Decision 2026-11-14 (main, delegated): thermion 0.6.1 cannot duplicate or isolate material instances (material.dart has no duplication; createInstance with supplied materials maps entity index to primitive index), so views that recolour materials would leak changes into each other. Concurrent views therefore do NOT share assets; each view owns a private asset and only the byte/disk cache is shared. Keep-alive reuse of a single disposed view's viewer+asset (same src) still applies, with authored materials, morph weights and transforms restored before reuse.
- P4 First display (15): `warmUp` keeps its first viewer for the first mount instead of destroying it; prefetched models are parsed into assets ahead of the first mount when `prefetch` lists them (bounded by `cachedModels`). Measure first-ready time before/after (load stats `ready` mark).
- P6 Renderer CHANGELOG/README entries (unreleased 0.3.0). No engine contract change unless unavoidable. Do not publish.

## Tests
Renderer (fake platform/viewer): two controllers of the same src load bytes/assets once and the second uses an instance; dispose + remount within the keep-alive window reuses the kept viewer (no second createViewer) and after the window it is released; memory pressure releases kept viewers; kept viewers render nothing; warm-up's viewer is handed to the first controller (no second createViewer for it); prefetch with cachedModels parses ahead.
Device: back-navigation re-show without poster (screenshot sequence), first-ready time with prefetch before/after, x4 Xbot views CPU/GPU/PSS before/after sharing.
