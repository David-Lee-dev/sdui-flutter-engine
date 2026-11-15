# model_3d frame rate (0.29.0)

User decisions 2026-11-14: playback targets 60 fps; structure approved 2026-11-14 ("추가하기로 한 기능들 다 추가할 때까지 작업 사이클 돌리고 …").

Device evidence (Galaxy Z Flip6, profile, Filament capped at 60 via thermion `setTargetFramerate`): a clip playing alone composites 60 Flutter frames/s (CPU ~67 %, GPU ~27 %). Auto-rotation, or any running Flutter `Ticker`, composites 120 Flutter frames/s while Filament still renders 60 (CPU ~95 %, GPU ~44 %). The extra cost is the engine's camera rig and progress playhead ticking at display rate.

## Requirements
- R1 `Model3dSource` gains `int? get frameRate => null`: frames per second its renderer draws; null means the display rate. Existing sources are unaffected.
- R2 When the installed source's `frameRate` is non-null, the `model_3d` camera rig (camera easing, auto-rotation, fling, return) and progress playhead advance on a clock at that rate instead of a vsync `Ticker`, so these motions schedule no Flutter frames of their own. With null they keep their `Ticker` exactly as today.
- R3 Motion stays time-based: each step uses the real elapsed time, so speeds (`auto_rotate` degrees per second, durations, progress `speed`) are unchanged. A view hidden by `TickerMode` stops advancing and, when shown again, continues from where it paused without replaying the hidden time (today's `resume` semantics).
- R4 Gesture drags keep moving the camera directly from pointer events.
- R5 `FilamentModel3dSource` takes `int? frameRate = 60` and reports it as `frameRate`. Filament renders at most that many frames per second from the first viewer on (thermion `setTargetFramerate`; null applies 0, the display rate).
- R6 Docs: the `model_3d` widget doc comment and `packages/sdui_model_filament/README.md` describe the rate. Engine `CHANGELOG.md` gains an unreleased `## 0.29.0` entry and the renderer `CHANGELOG.md` an unreleased `## 0.3.0` entry. Versions in pubspec files are bumped at release, not in this change. Do not publish.

## Tests
Engine, through a mounted `model_3d` with a fake `Model3dSource` (as in `test/src/runtime/widget/catalog/model_3d_widget_test.dart`):
- frameRate 30 + `auto_rotate`: over one second of fake time the controller receives about 30 `setCamera` calls whose yaw advances by `auto_rotate` degrees per second, and after the rotation starts no Flutter frame is left scheduled between clock steps.
- frameRate 30 + `progress` moving toward a target: `setPose` arrives at the clock rate and reaches the target after the same duration as with the ticker.
- frameRate null: behavior identical to today (existing tests stay green unchanged).
- Hidden by `TickerMode(enabled: false)` with frameRate set: no `setCamera`/`setPose` while hidden; shown again, the next step continues from the paused value without a jump.

Renderer (`packages/sdui_model_filament/test`, fake platform):
- default source: the platform receives target frame rate 60 when the first viewer is created; `frameRate: null` applies 0.
