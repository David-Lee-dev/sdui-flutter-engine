# Anchored highlight overlay (engine feature)

User decision 2026-11-07: add an engine feature so a template can open a highlight overlay attached to an on-screen element (mission screen "고보상" badge). Must not break the existing SDK structure (existing widgets, commands, modal driver, anchoring driver, presence, motion keep their behavior and contracts). Purely additive and opt-in via a new `_requires` capability.

Target UX (reference: mission screen capture): tapping the badge dims the whole app (including the app bar and the shell's bottom navigation bar) like a modal barrier, blocks page scrolling and other input, keeps the badge visually highlighted above the dim at its exact on-screen position, and shows a column of 4 pill cards next to it. Cards appear one by one top-to-bottom in a fast stagger. Tapping anywhere outside the cards closes it: cards disappear in reverse order (bottom-to-top stagger), then the dim fades out and the screen returns to normal. Cards have no tap action for now; amounts are fixed text; no connector lines.

## Requirements
- A1 Anchoring: overlay content is positioned relative to the measured rect of an existing anchor (`anchor` widget id) in the same screen, at the anchor's current on-screen position (scroll offset included), without re-rendering unrelated sections to fake the position.
- A2 Above the shell: the dim and the overlay content paint above everything the app shows for that tab/route, including the app bar and the app shell's bottom navigation bar (tuk app: bar is drawn in TabRoot's Stack, modals already cover it because they use the tab branch Navigator overlay).
- A3 Highlight: the anchored target is visible above the dim (re-rendered at the anchor rect or a cut-out); the template decides what is drawn there.
- A4 Scope: overlay content is a template subtree that reads the screen's state and dispatches the screen's actions (unlike modals, which only get params).
- A5 Dismiss: a tap on the dim (outside overlay content) dispatches a template-named action; system back should also dismiss (dispatch the same action) while open.
- A6 Enter stagger: existing `_motion` enter with `delay` expressions works for the cards.
- A7 Exit stagger: closing plays per-card exit motions in reverse order with per-item delays, and the overlay stays painted until those exits (and the dim fade) finish. Today exit runs ignore `delay` (docs/motion.md:79) — provide a non-breaking way (e.g. an opt-in exit delay key) so templates do not need interval-timer hacks.
- A8 Non-breaking: no behavior change for templates that do not use the new feature; new names gated by a new `_requires` capability; old engines reject the capability so the server can gate by app version.
- A9 Tests at the public boundary (compiler + widget tests) for A1–A8, docs page(s) under docs/, CHANGELOG entry, minor version bump (0.22.0 on top of the unreleased 0.21.0 work in the tree; keep 0.21.0 entry). Do not publish.
