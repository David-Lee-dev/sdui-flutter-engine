# Changelog

## 0.14.0

**Behavior change (Android only):** a `sys_haptic` tap now picks its native
primitive by `intensity` instead of always scaling `PRIMITIVE_CLICK`. Tiers are
derived from the AOSP HAL targets (TICK 1 G, CLICK 2 G): `target G = intensity ×
2 / 0.75`; below 1 G (`intensity < 0.375`) plays `PRIMITIVE_TICK`, 1–2 G a
scaled `PRIMITIVE_CLICK`, and `intensity >= 0.75` the predefined
`EFFECT_HEAVY_CLICK` (the strongest crisp tap). This brings Android taps closer
to iOS's soft-to-strong range. Falls back to `PRIMITIVE_CLICK` on devices
missing `TICK` or `HEAVY_CLICK` support; a device without `PRIMITIVE_CLICK`
stays silent as before. iOS, continuous haptics and tap timing are unchanged.
See docs/haptic.md "Android tap intensity tiers".

## 0.13.0

- Added `_motion` scheduling param `start` (`'visible'` default, or `'mount'`):
  inside an ancestor `Scrollable`, `'mount'` skips the scroll-aware start gate
  and starts (counting `delay`) as soon as the layer mounts, so it can finish
  before the user scrolls to it. Declare `_requires: [motion_start_v1]`.

## 0.12.0

**Breaking change:** the page transition type `slide_up` is removed.
Migrate `_transition: { type: slide_up }` to
`_transition: { type: slide, params: { y: 0.08 } }`.

- Added page transition type `slide`: params `x` and `y` (fraction of page
  width/height, inclusive range `-1..1`, default `0`) set the start offset,
  and `fade` (default `true`) toggles the incoming opacity animation. Same
  200 / 160 ms push/pop defaults as the removed `slide_up`.
- `shared_axis`'s `distance` param now accepts `-200..200` (was `0..200`); a
  negative distance reverses the direction on both the incoming and outgoing
  pages for `axis: x` and `axis: y`.

## 0.11.0

**Behavior change:** the SDK applies no safe-area policy of its own. Safe
area is the host app's job (top, bottom, platform differences); a template
adds more only by wrapping its content in `safe_area`, which pads only the
edges the host has not consumed. See [Insets](docs/concepts.md#insets).

- The `scaffold` body is no longer wrapped in a `SafeArea`. Without an
  `app_bar` the body now starts at the very top, under the status bar, and
  spans the full width in landscape (under side cut-outs); the whole
  `MediaQuery` padding is left to its content. Templates that relied on the
  scaffold clearing the status bar wrap their top in a `safe_area` with
  `bottom: false`.
- With an `app_bar` nothing changes vertically: the bar is still
  `app_bar_height` tall below the status-bar inset and the body starts under
  it. The body no longer clears left/right cut-outs in landscape.
- The Android bottom strip from 0.10.0 is removed: content scrolled under the
  system bar shows through it again, unless the host covers or consumes the
  inset.
- `inset_bottom` and `cover_bottom_inset` are no-ops. They are still accepted
  without an `ignored prop(s)` warning. For the old `inset_bottom: true`
  layout wrap the body in a `safe_area` with `top: false`.
- Unchanged: vertical scroll views add the `MediaQuery` bottom padding the
  host passes in after their content (`inset_end`, default only when the view
  reaches the screen bottom); `extend_body` and `extend_body_behind_app_bar`
  keep their Flutter meaning; `safe_area` is unchanged.

## 0.10.1

### Fixed

- A repeating `_morph`, a spring `_morph` or a repeating `_motion` on a
  sliver node (`sliver_to_box_adapter`, `sliver_list`, ... inside
  `custom_scroll_view`) no longer gets the 0.9.0 `RepaintBoundary`, which
  broke the viewport's sliver protocol. Box nodes keep it. A `_motion` start
  gate on a sliver node now reads the sliver's visibility instead of failing
  on a box cast.
- A spring `_morph` now reacts when reduced motion
  (`MediaQuery.disableAnimations`) turns on mid-flight or during `_delay`: it
  cancels the pending start and the simulation and rests on the target at
  velocity `0`, as a tween does. Turning it off again does not replay.
- The `shape` shader warm-up moved from `Sdui.initialize` to
  `Engine.initialize`, so apps that boot with `Engine.initialize` and
  `EngineRunner` get smooth shapes too. It still starts once and never
  blocks boot.
- Valid props of vertical `list_view`, `grid_view`, `single_child_scroll_view`
  and `custom_scroll_view` no longer show a debug `ignored prop(s)` warning:
  they are read during the widget build again, before the prop audit.

## 0.10.0

**Behavior change (Android):** `scaffold` covers the system bottom inset over
its body with an opaque strip of its background (`background_color`, else the
theme's scaffold background), so content scrolled under the Android system
bar is hidden there. Scroll views still end above the inset as in 0.8.0. See
[scaffold](docs/widgets/navigation/scaffold.md#pitfalls--related).

- The strip is as tall as the device's real bottom inset (read from the view,
  minus the keyboard), capped by the body's `MediaQuery` bottom padding. A
  floating tab bar an app shell adds to the padding is not covered, and a
  scaffold whose bottom padding was already consumed above it gets no strip.
- No strip with a `bottom_navigation_bar` slot, with `inset_bottom: true`, or
  while the keyboard is up. The strip takes no taps and does not change the
  body's layout or state.
- New flag `cover_bottom_inset`: absent means Android only, `true` covers on
  every platform (e.g. the iOS home indicator area), `false` turns it off for
  bodies that should show through the system bar.

## 0.9.0

Motion, morph, interaction and expression additions. Templates that use any
of them should declare the matching `_requires` feature (see
[Concepts](docs/concepts.md#reserved-keys)); old templates render as before,
except for the reduced-motion and numeric-`repeat` notes below.

- `_morph._velocity: <name>` exposes the value's velocity (`_to` units per
  second; spring velocity or curve slope for tweens), `0` at rest and under
  reduced motion, clamped to ±10,000 (`spring_v2`).
- `curve` / `_curve` accept `[x1, y1, x2, y2]` cubic beziers, Material 3
  names (`emphasized`, `emphasized_decelerate`, `emphasized_accelerate`,
  `standard`, `standard_decelerate`, `standard_accelerate`) and spring curves
  (`spatial_fast`, `spatial_default`, `spatial_slow`, `effect_default`) whose
  settle time is the default duration (`curve_v2`). Page transitions accept
  the new names too. Unknown names keep their old fallback.
- `_motion` `repeat` takes a leg count 1–1000 and `repeat_delay` pauses
  between legs (`motion_repeat_v1`). A numeric `repeat` used to mean "no
  repeat"; `1`–`1000` now repeat that many legs. `MotionPlan` gains
  `repeatCount`, and `MotionPlan.from` a `repeat` default.
- Reduced motion (`MediaQuery.disableAnimations`): `_motion` layers draw
  their end state without running, and tween `_morph` jumps to its target
  (spring morphs already did). **Behavior change** for devices with that
  setting on.
- `_motion` and `_on` work on `positioned`, `positioned_fill`, `expanded`,
  `flexible` and `spacer`: the layers go inside the parent-data widget
  (`parent_data_motion_v1`). Other nodes keep their wrapper order.
- `_on.tap.pressed_as: <name>` gives the node and its descendants a bool that
  is true while the tap is held (`press_v1`).
- Expression functions `smoothstep(e0, e1, x)` and `sign(x)` (`math_v2`).
- `transform` / container `transform` take `offset: [x, y]`, scaled by
  `EngineMetrics` (`transform_offset_v1`); `translate` is unchanged.
- Repeating `_motion` layers, and the direct widget of spring or repeating
  `_morph`s, sit in a `RepaintBoundary`. One-shot motions and morphs add
  nothing to the tree.
- `shape` items take `op` (`union` | `subtract` | `intersect`, folded left
  in list order), their own `smooth`, and `at: [fx, fy]` (center as box
  fractions, wins over `align`). `fill` and `rim.gradient` take gradient
  maps; `shadow: { color, blur, offset }` and `backdrop: { blur }` paint
  under the shape. Stages paint shadow → backdrop → fill → rim and fail
  independently. The backdrop blur is clipped by the hard outline (about
  8 px outside a `smooth: 24` dip, 20 px at `smooth: 64`). Without the
  shader, subtract and intersect use hard `Path` operations (`shape_v2`).
  A literal unknown `op`, or an unknown key in a literal `shapes` item,
  `shadow` or `backdrop`, now fails compilation; **old templates with a
  typo key inside a `shapes` item no longer compile**.
- `shape` now always sits in its own `RepaintBoundary`.
- New `semantics` widget: `label`, `button`, `selected`, `hidden`
  (`semantics_v1`).
- New `layout_builder` builder widget: its child reads `max_width` and
  `max_height` in template units (`null` when unbounded) via `_provides`.
  Inside `intrinsic_width`/`intrinsic_height` it fails compilation; under an
  app-side intrinsic parent it answers 0 and logs once
  (`layout_builder_v1`).
- `ShapeGeometry.unionDistance`/`unionPath` are now `combineDistance`/
  `hardPath` (internal API).

## 0.8.0

**Behavior change:** screens now draw under the bottom system inset (home
indicator, Android system bar, a floating tab bar added to the padding), and
vertical scroll views end above it. See
[Bottom inset](docs/concepts.md#bottom-inset).

- `scaffold` no longer clears the bottom inset around its body. Top, left and
  right are unchanged, and the body keeps the bottom padding in its
  `MediaQuery`. New flag `inset_bottom` (default `false`) restores the old
  behavior.
- Vertical `single_child_scroll_view`, `list_view`, `grid_view` and
  `custom_scroll_view` add the bottom padding after their content, on top of
  the template `padding` (`custom_scroll_view` ends with a sliver of that
  height; for `reverse` views the space stays on the bottom edge). Their
  content sees a bottom padding of 0, so an inner `safe_area` or nested scroll
  view does not add it again: the `{safe_area top:false, sizedbox 8}` pattern
  inside a scroll view now leaves only the 8. Horizontal views, `page_view`
  and `tab_bar_view` are unchanged.
- This applies automatically only to a view whose bottom edge reaches the
  bottom inset of the screen (full-height screens, bottom sheets). A view
  above a fixed CTA or bottom bar, or inside a centered dialog, adds nothing,
  so templates need no opt-out. New flag `inset_end` forces it: `true` always,
  `false` never. The first frame assumes the view reaches the bottom; when it
  does not, the next frame changes only the end spacing (a `reverse` view's
  content shifts by the inset once).
- A vertical `list_view` or `grid_view` without `padding` no longer takes the
  top padding from the screen. The scaffold body already cleared it, so
  screens inside a `scaffold` look the same.
- With the keyboard up the end spacing shrinks to the template `padding`,
  because Flutter reports a bottom padding of 0.
- Templates to check: fixed bottom content outside a scroll view (a CTA)
  needs the `bottom_navigation_bar` slot or a `safe_area` with `top: false`;
  a `safe_area` with `bottom: true` around a whole scroll view still stops the
  content above the inset; a `custom_scroll_view` ending with
  `sliver_fill_remaining` now scrolls by the inset.

## 0.7.0

- New `_morph._spring`: a preset name (`spatial_fast`, `spatial_default`,
  `spatial_slow`, `effect_default`) or a literal
  `{stiffness, damping_ratio, mass}` map (stiffness 1–5000, damping_ratio
  0.2–2, mass 0.1–10, default 1) replaces the tween with a spring. A target
  change continues from the current value and velocity (`effect_default`
  restarts at rest); an unsettled spring snaps to its target after 5 s, and
  reduced motion jumps to the target. A target that is not a finite number,
  or whose expression fails to evaluate, keeps the previous target. Unknown
  presets or keys are compile errors; other misuse (expressions, out-of-range
  values, combining `_spring` with `_duration`, `_curve`, `_repeat` or
  `_reverse`) gives a morph without animation, as below.
- **Motion and morph never fail the template or the app** (debug and
  release). Typos stay compile errors: unregistered `_motion` names, unknown
  `_morph` keys, unbindable `_as` names, unknown `_spring` presets or keys.
  Everything else degrades silently, with one debug `animation off` log line
  per node and reason, and is never reported to `SduiErrorObserver` or
  caught by `NodeGuard`:
  - `_motion` values or entries of the wrong shape (`5`, `null`, `[]`, `''`,
    a map without a string `type`) drop that entry instead of failing
    compilation; other layers stay.
  - A `_motion` layer whose parameters, `plan()` or `frame()` throw —
    including app-registered atoms — or whose repeating plan has no duration
    is off for the node's lifetime; the widget is drawn at rest and other
    layers keep running. Motion numbers, offsets and durations beyond
    ±1,000,000 fall back to the atom default.
  - A `_morph` that is not a map or has no string `_as` is dropped. Other
    malformed values (no `_to`, non-scalar `_to`/`_from`/`_trigger`, invalid
    `_duration`/`_delay`/`_curve`/`_repeat`/`_reverse`, `_repeat` with
    `_duration: 0`) give a morph without animation: the variable equals
    `_to` immediately. Previously these were compile errors or, for some
    tween values, a silent fallback to the 400 ms default.
  - At runtime, a `_to`, `_from` or `_trigger` that throws (any error type,
    tween and spring alike) keeps the last good value, then a valid `_from`,
    then `null`. Before, a tween expression error escaped the morph, and a
    target that never evaluated read as `0`.
- New `shape` widget: a decorative smooth union of up to 8 circles, capsules
  and rounded rects (`shapes`, `smooth`, `fill`, `rim`), painted by an engine
  fragment shader that `Sdui.initialize` loads in the background. Until it is
  loaded, or where it cannot load, the hard union of the same primitives is
  painted. Invalid runtime values keep each primitive's last valid form, and a
  paint failure is reported once and then paints nothing.
- New expression functions `sin`, `cos`, `pow` and `remap`. They return
  `null` for wrong arity, non-finite input, or a non-finite result (`pow`
  also outside the real domain; `remap` when its source range is empty).
- Alignments accept `[x, y]` (two finite numbers, each clamped to −4…4) in
  addition to the nine names. **This applies to every property decoded as an
  alignment**, including gradient `begin`/`end`/`center` and motion
  parameters, not only `align`.
- New root key `_requires: [spring_v1, shape_v1, math_v1, align_xy_v1]`
  declares the engine features a template needs. Unknown names are compile
  errors; older engines reject the key itself, so such templates fail to
  mount there instead of rendering partially.

## 0.6.1

- iOS podspec version now matches the package version (it stayed at 0.4.0)
  and its summary covers continuous haptics. No behavior change.

## 0.6.0

- New `sys_haptic` parameter `continuous`: a custom continuous vibration with
  an `intensity` curve, an optional `sharpness` curve (flat 0.5 when absent)
  and optional `taps` in the `pattern` item format. Curve points are
  `[ms, value]` with times rounded, ≥ 0 and non-decreasing, and values
  clamped to 0–1. It plays before `pattern` and `variant` on devices with
  continuous haptics (iOS Core Haptics, Android 16+ with envelope effects).
  An invalid `continuous` or an unsupported device falls through to
  `pattern`, then `variant`. Older engines ignore `continuous`.

## 0.5.1

- Internal: the Pulsar presets are split into a basic (45 tap-only) table and
  a continuous (106) table; preset values and `sys_haptic` behavior are
  unchanged.
- Docs: `sys_haptic` lists basic and continuous presets separately and notes
  that most Android devices are silent for continuous presets (e.g. a Galaxy
  Z Flip6 on Android 16 reports no envelope effects).

## 0.5.0

- New `sys_haptic` `variant` presets: all 151 presets of Software Mansion's
  Pulsar (MIT), in snake_case (e.g. `crescendo`, `bass_drop`, `heartbeat`).
  A valid `pattern` still takes precedence.
  - The 45 tap presets play as native taps on devices that support them
    (Android plays click primitives; sharpness is iOS only) and play nothing
    on devices without native taps.
  - The 106 continuous presets play a continuous vibration shaped by
    intensity and sharpness curves, with taps on top, on devices with
    continuous haptics: iOS Core Haptics, or Android 16+ with envelope effects
    (`VibrationEffect.BasicEnvelopeBuilder`). Elsewhere they play nothing,
    even where taps are supported. Android never falls back to waveform,
    amplitude or one-shot vibration. Cancelling the command stops the
    vibration.
- **Changed:** on devices with native taps, `sys_haptic` `variant` `light`,
  `success`, `warning` and `error` now play native taps (light 0.5; success
  0.5 then 0.7 after 70 ms; warning two 0.7 taps 130 ms apart; error three 1.0
  taps 130 ms apart) instead of platform impulses, so Android `error` no
  longer uses vibrate there. `intensity` does not change these taps. Devices
  without native taps play the same impulses as before, and `medium`,
  `heavy`, `strong`, `selection` and `vibrate` are unchanged everywhere.

## 0.4.0

- New `sys_haptic` parameter `pattern`: a list of short native taps, each with
  `intensity` and `sharpness` (0–1, sharpness iOS only) and `delay` (ms after
  the previous tap). It plays on devices with native taps (iOS Core Haptics;
  Android 11+ with the click composition primitive) and overrides `variant`
  there; elsewhere `variant` plays as before. A tap with intensity 0 is
  skipped but keeps its delay.
- **Changed:** a `sys_haptic` with a missing or unknown `variant` (and no
  playable `pattern`) now plays nothing instead of a light impact. Write
  `variant: light` for a light impact.
- The package is now a Flutter plugin (Android and iOS native code; Android
  declares `android.permission.VIBRATE`). Apps must do a full rebuild after
  upgrading.

## 0.3.4

- Fix: inside nested scrollables (e.g. a list in a `tab_bar_view` under a
  scrolling header) the start gate added each viewport's offset on top of the
  previous one, so items in the lower part of the screen counted as off-screen
  and started only once scrolled near the top. The slot is now mapped into each
  ancestor viewport on its own. The wait-until-visible-and-settled rule is
  unchanged.

## 0.3.3

- Fix: the scroll-aware start gate decides visibility from the slot the
  motion occupies. When a motion's first frame collapses its own box (a
  `reveal_*` at width or height 0, also inside another motion such as `fade`),
  the slot keeps the motion's position and takes the size of the first sized
  box beneath it. Every motion with a non-empty box is measured exactly as in
  0.3.1, so 0.3.2's regression (an off-screen `move` never starting) and its
  child key are gone.

## 0.3.2

- Fix: a `_motion` inside a scrollable whose first frame shrinks its own box
  to zero (`reveal_*` starting at width or height 0 inside a loose parent such
  as `align`) never started, because the start gate measured the motion frame.
  The gate now measures the child's laid-out box.

## 0.3.1

- New expression function `url_encode(value)`: encodes one URL query value
  (`Uri.encodeComponent` of its text) so the reader's `queryParameters`
  returns the original text; `null` gives an empty string.

## 0.3.0

- **Breaking:** navigation-time preload is replaced by an init-time screen
  cache. `Sdui.initialize(preloadScreens: [...])` loads the listed screens
  through the `ScreenLoader` and now returns a `Future<void>` that completes
  when those loads settle (failures are reported as `screenLoad` and leave the
  id uncached). A cached screen renders on its first frame, applies its root
  `_transition`, and is refreshed in the background for the next open; any
  other screen loads as before and uses `defaultType`.
- New `Sdui.page(context, state, screenId:, child:)` builds the page for an
  engine screen; the generic `/screens/:id` route uses it and app routes can
  too. The page decision is frozen per page and released when it leaves;
  when `go` reuses a page for another screen id, the child is remounted.
- Removed: `PageTransitionStyle.preloadTimeout`, `SduiScreenPage.preloaded`,
  and the navigation handle's preload wait, timeout and abandonment. Push and
  go now navigate immediately; push still settles with the pop result or
  `null`. Tap origins (`container_transform`, `tap_zoom`) are consumed by the
  destination route from its own Navigator.
- **Breaking:** a pending `image` without a `loading` slot now holds a
  transparent box sized from width/height; the shimmer placeholder is opt-in
  with `shimmer: true`.

## 0.2.3

- Fix: an `image` that is still loading (the pending path) now receives its
  parent's constraints unchanged. Previously the load cross-fade loosened them,
  so in a fixed slot the image sized to its own aspect ratio and `fit` (e.g.
  `cover`) could not fill the slot. Pending and ready images now lay out alike.

## 0.2.2

- `video` widget: `on_ready` and `on_error` props. `on_ready` dispatches once a
  slot first becomes renderable for the current `src` (direct and
  `SharedVideoScope`-leased paths); `on_error` dispatches once if initialization
  fails. A `src` change resets both guards.

## 0.2.1

- Fix: motions inside a `Scrollable` ancestor (any depth, including `swipe_pane`
  followers moved by `jumpTo`) no longer start on mount. They wait until the
  widget is actually visible in every ancestor viewport and scrolling has
  settled, then run their `delay` from that point. Motions outside any
  scrollable are unaffected. A `trigger` change still restarts immediately,
  bypassing the wait; once a motion has started, scrolling it away and back
  never restarts it.

## 0.2.0

- Page transitions: `_transition` decoder and effect registry with `slide_up`, `zoom`,
  `fade_through`, `shared_axis`, `container_transform`, `card_stack`, `tap_zoom`, and `none`.
- `shared_element` widget: snapshot Hero flight for any widget, follows iOS swipe-back,
  continuous video across the flight.
- Destination preload; push uses the destination's declared transition.
- `PlayerVideoController.asset/network` accept `VideoPlayerOptions`.
- Fix: `navigate` push settles when the pushed page leaves without a pop.

## 0.1.0

- Initial release: JSON template compiler into a reactive widget tree with actions,
  drivers, motion, transport-blind `NetworkClient`, language catalog, and replaceable
  error/presentation surfaces.
