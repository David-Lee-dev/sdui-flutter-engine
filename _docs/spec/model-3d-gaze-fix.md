# model_3d look-at: no head flicker while the camera moves (renderer 0.3.0 bug fix)

User report 2026-11-15 on the Galaxy showcase: with `look_at: { target: camera }` and `auto_rotate` on, the head momentarily snaps to face front and then turns back toward the camera. Structure decisions delegated to main for this session.

Analysis (main, renderer source): (1) `setCamera` re-poses the model outside the request-frame hook (a pose on the native lane (now in `model_motion.dart` after the 2026-11-15 split)). Posing applies the base clip time first and the gaze rotation after; Filament's render thread does not wait for that work, so a frame can be rendered between the two writes, showing the base (front-facing) head. Auto-rotation moves the camera every clock step, so the flicker repeats; a still camera never triggers it. (2) When the camera passes behind the model the clamped gaze target jumps from +max_yaw to -max_yaw, and the fixed-duration easing restarted every frame swings the head across the front in `duration` (300 ms) — it reads as a snap.

## Requirements
- G1 Every pose write (base clip time, layer, morphs, gaze, bone matrices) happens only inside the renderer's request-frame hook, so no rendered frame can show a partially applied pose. A camera change only marks motion dirty and keeps the render gate active; the next frame hook applies the new gaze.
- G2 Gaze moves smoothly at a bounded angular speed: it follows a moving target without lag spikes (no per-frame restart of a fixed-duration ease), `duration` sets the response time, and a large target change (e.g. the target crossing behind the model) turns at most ~180°/s instead of within `duration`.
- G3 Behind-the-model hysteresis: while the target is outside the gaze cone (|yaw| > max_yaw), the head holds the clamp on the side it left from; it only turns to the other side once the target re-enters the cone there. Near ±180° the side never flip-flops frame to frame.
- G4 Existing look-at behaviour stays: camera/pointer/point targets, clamps, weight, easing back to rest on clear, hidden-view pause, frame release when idle.

- G5 Housekeeping: move the misplaced `// RF-R4` comment out of `test/filament_model_3d_motion_test.dart` (it belongs to the bounds byte-budget tests).

## Tests
Renderer (fake viewer/app): a camera change does not perform native pose writes outside the frame hook (pose calls only happen inside the registered hook); orbiting the camera 360° in small steps produces a gaze yaw sequence with no sign flip-flop and per-step change bounded by the speed limit; a target crossing behind holds the clamp until it re-enters the cone; a moving target is followed without the gaze resetting toward its start each step.
Device (Galaxy showcase / bench): RobotExpressive look_at camera + auto_rotate shows no front-facing frames (rapid screenshots) and a smooth crossover behind the model.
