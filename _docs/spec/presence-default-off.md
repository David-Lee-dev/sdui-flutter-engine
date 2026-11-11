# Presence default off (0.21.0)

User decision 2026-11-07: structural presence transitions become opt-in. Templates showed 12 `_presence: false` opt-outs and 0 opt-ins; the default size growth along a row looks like an unwanted left-to-right reveal.

## Requirements
- P1 A node without `_presence` compiles its structural directives (cond, `_if`, switch, eager loop, scope `_skeleton` swap) with presence OFF: inserted content appears at once, removed content leaves at once, no size animation — the same as today's `_presence: false`.
- P2 `_presence: true` and `_presence: { space, order, duration, curve }` enable presence exactly as the current default does (behavior unchanged for opt-in).
- P3 `_presence: false` stays valid and means off (no error).
- P4 `_motion` `on: exit|both` entries keep working where presence is enabled; under the new default (off) they behave as `_presence: false` does today.
- P5 Runtime/programmatic defaults agree with the compiler: wherever a `PresenceConfig` default is used without a template value (directive constructors, Scope, SkeletonScope), the default is off, unless a caller passes a config explicitly.
- P6 Existing tests that exercise presence animation opt in with `_presence: true` (or an explicit enabled config) instead of relying on the default; do not delete, skip or weaken their assertions. Add tests for P1–P3 at the compiler boundary and at least one runtime check that an `_if` toggle without `_presence` swaps instantly.
- P7 Docs (`docs/*.md`, README if it mentions the default, `lib` doc comments such as presence_config.dart) describe the new default. CHANGELOG gets a `## 0.21.0` entry marked **Behavior change**, and pubspec version becomes 0.21.0. Do not publish.
