# Changelog

## 0.25.0

- Bottom sheets no longer leave an empty strip above the home indicator. The
  sheet surface (background and top radius) now reaches the bottom edge and the
  frame lifts the body above the bottom inset inside it, so templates need no
  bottom `safe_area` (one they already have adds nothing). A `background: none`
  sheet paints its own card, so its template receives the bottom inset and owns
  it like a scaffold body. Left/right safe areas, keyboard positioning and
  dialogs are unchanged; the sheet height cap includes the inset area.

## 0.24.0

- `curve` (in `_motion`) and `_morph._curve` accept a list of segments
  `{until, to, curve}`: each segment runs its own curve from the previous
  segment's `to` (0 for the first) to its own over t from the previous
  `until` (0) to its own. `until` strictly increases in (0, 1] and ends at 1,
  `to` is within ±10, `curve` defaults to `linear` and takes any name or
  bezier but not another segment list. The curve ends at the last `to`, so a
  hop such as `[{until: 0.35, to: 1, curve: ease_out}, {until: 1, to: 0,
  curve: bounce_out}]` rises, lands with a bounce and ends at `begin`:
  `repeat` restarts without a jump and `repeat_delay` rests on the ground.
  A malformed list uses the fallback like an invalid bezier. New
  declare-only `_requires` feature `curve_segments_v1`; older engines use the
  default curve. See docs/motion.md#curves.
- `_motion` and `_morph` apply the curve to the controller value themselves
  instead of through a `CurvedAnimation`, which pins t = 1 to 1 (and turned
  the layer off in debug for a curve ending elsewhere). Existing curves draw
  the same values.
- `_morph` compares segment lists by content, so recompiling the same
  template keeps a running morph going.

## 0.23.0

- `box_shadow` entries take `inset: true` for a CSS-style inset shadow: the
  shadow paints inside the box, following `border_radius` and `shape: circle`,
  above the decoration's color and gradient and below its border and the
  child. `offset`, `blur_radius` and `spread_radius` work like CSS `inset`
  (positive spread thickens the shadow inward). Outer and inset entries can be
  mixed in one list. Works in `container` `decoration` and
  `foreground_decoration` and in `decorated_box`; `speech_balloon` draws no
  shadows. Only the boolean `true` counts. New declare-only `_requires`
  feature `box_shadow_inset_v1`.
- `box_shadow` entries take `blur_style: normal | solid | outer | inner`
  (Flutter `BlurStyle`), bindable like the other shadow keys. `outer` draws
  only the outer glow; `inner` keeps only the fuzzy part inside the shadow
  shape, which the decoration's fill still covers, so it is not an inset
  shadow (use `inset: true`). Ignored for inset entries. A missing or unknown
  value draws a normal shadow. New declare-only `_requires` feature
  `box_shadow_blur_style_v1`.
- Engines older than 0.23.0 ignore both keys and draw every entry as a normal
  outer shadow; the compiler does not require either feature. See
  docs/widgets/layout/container.md#box-shadow.

## 0.22.0

- New `anchored_overlay` widget: a highlight layer attached to an on-screen
  `anchor`. While it is in the tree (show it with `_if` and
  `_presence: true`) it dims the app in the nearest Overlay, above the app
  bar and a shell bar drawn beside the screen, blocks the page beneath, and
  lays its children over the dim. A tap on the dim or a system back
  dispatches `on_dismiss`. Its children read the screen's state and dispatch
  its actions. `barrier_color`, `barrier_duration` and `barrier_exit_delay`
  set the dim. See docs/widgets/custom/anchored_overlay.md.
- New `anchored` widget, for an `anchored_overlay`'s children: places its
  child `over`, `above`, `below`, before (`start`) or after (`end`) the
  anchor's current on-screen rect, scroll offset included, with `align` and
  `gap`. See docs/widgets/custom/anchored.md.
- `_motion` `exit_delay`: milliseconds an `on: exit|both` entry waits before
  its exit run, so exits can stagger (exit runs still ignore `delay`). The
  presence slot stays until the last delayed exit has finished.
- A `_motion`'s start gate now counts only the scrollables the motion is
  drawn inside, so motions in an overlay shown from inside a scroll view
  start instead of waiting on the page's viewport. Trees without overlays
  behave as before.
- The new names need `_requires: [anchored_overlay_v1]`; engines before
  0.22.0 reject the feature, so gate such templates by app version.

## 0.21.0

- **Behavior change:** presence transitions are now opt-in. A node without
  `_presence` builds its `_if`, `cond`, `switch`, eager loop and skeleton
  swap with presence off, as `_presence: false` did: inserted content
  appears at once, removed content leaves at once, with no size animation
  and no `on: exit` motions. Templates used `_presence: false` to opt out
  far more often than they relied on the default, and the default size
  growth along a row read as an unwanted left-to-right reveal.
  `_presence: true` and a `_presence` map turn presence on and behave as
  the old default; `_presence: false` stays valid. Engines 0.16–0.20 keep
  animating a node without `_presence`, so add `_presence: true` where an
  animation is wanted before shipping templates to 0.21.0 apps. See
  docs/control-flow.md.

## 0.20.4

- A `cond` with only an `_else` branch, the layer templates use to nest
  loops, no longer gets a presence box: it can never switch, so the box had
  nothing to animate. Under `serpentine` the box hid each `serpentine_row`,
  so every row was taken as one cell and the track ran the full width
  instead of following the cells.

## 0.20.3

- iOS `sys_haptic` presets: taps now play at their own intensity and
  sharpness. They used to share one Core Haptics pattern with the
  continuous rumble, whose intensity and sharpness curves scaled every
  event in it — a curve starting at 0 muted the first tap and weakened
  later ones. The taps now play from a separate pattern started at the
  same moment; the rumble keeps its curves. Android is unchanged.

## 0.20.2

- The app sets the default for the `image` loading shimmer:
  `SduiPresentation(imageShimmer: true)` makes a pending image without a
  `loading` slot show the shimmer placeholder when the node sets no
  `shimmer`. A node's `shimmer: false` or `shimmer: true` still wins. The
  default stays `false`, so apps that set nothing see no change. See
  docs/media.md.

## 0.20.1

- `_skeleton: merge` (and `{ merge: true, radius, shape, width }`) now
  works on a node inside another node's derived `_skeleton: true`: the
  node's bones become one merged box among the ancestor's bones. The
  ancestor's slot alone loads, swaps and applies the skeleton style; the
  merge errors (and `skeleton_merge_v1`) apply there too. Before, such a
  node failed to compile.

## 0.20.0

- Merged node skeleton: `_skeleton: merge` (or `{ merge: true, radius,
  shape, width }`, `_requires: [skeleton_merge_v1]`) derives the bones as
  `true` does and lays them out, but paints one rounded box of the node's
  size in place of them (radius 8 by default, `shape: pill` fully rounded,
  `width` lays the bones out at that width). The box takes the skeleton
  style like any bone; a positioned child overflowing a stack does not
  enlarge it. Not supported on a `_loop` node or inside another node's
  derived `_skeleton`. See docs/lifecycle.md.

## 0.19.1

- Fix: a swap (skeleton to content, if/else, switch case) whose content
  holds a `reveal_*` motion anywhere inside no longer jumps to the sum of
  the old and new sizes before settling. The reveal made the new content
  take its whole size at once while the old one still held its share; in a
  swap the slot now always goes from one size to the other. Outside swaps
  a reveal still owns the space in its phase.
- Fix: a `reveal_*` motion no longer changes its size on the other axis.
  Under a bounded constraint, `reveal_left`/`reveal_right` used to grow to
  the full available height and `reveal_up`/`reveal_down` to the full
  width.
- Behavior change: a `reveal_up`/`reveal_down` whose child is narrower
  than a bounded width now hugs the child's width instead of filling the
  width and centering the child; `reveal_left`/`reveal_right` likewise
  hug the child's height. Templates that relied on the old fill wrap the
  child in a sized box or use the parent's alignment.

## 0.19.0

- Skeleton style: bones are painted with one of three effects — `tint`
  (still), `breathe` (base ↔ highlight) or `shimmer` (the sweep) — each
  skeleton animating on its own. Apps set the default with
  `SduiPresentation(skeleton: SkeletonStyle(effect:, base:, highlight:,
  duration:))` (`SkeletonPaint.color` or `.gradient`); templates override
  it per scope with `_scope._skeleton_style` (`_requires:
  [skeleton_style_v1]`), key by key over the nearest outer scope. Reduced
  motion paints the base. See docs/lifecycle.md.
- Behavior change: the default skeleton paint is now a still `#2C2C2C`
  tint instead of the shimmer sweep, and no ticker runs for it. Apps that
  want the old look set `SkeletonStyle(effect: SkeletonEffect.shimmer)`,
  whose default colors and 1500 ms period match the previous sweep.

## 0.18.0

- Fix: a template number that is `NaN` or infinite (for example
  `10.0 ** 400`) no longer crashes the node where a count, index, width
  or precision is expected. Functions (`int`, `floor`, `ceil`, `round`,
  `format`, `percent`, `substring`, `pad_start`, `pad_end`, `repeat`)
  return `null`; `update_at`/`set_path` return the input; a list index
  reads `null`; slice bounds fall back to the default and a slice step
  gives `[]`; `*` repetition and `//` raise the usual expression error.
  `font_weight` and the `scroll` command's `duration` ignore it.
- Fix: a fractional slice step that truncates to 0 (`[::0.5]`) returns
  `[]` instead of hanging; other fractional steps still truncate. A very
  large step no longer overflows.
- Fix: repeating an empty string or list returns it at once for any
  count, the repetition cap can no longer be bypassed by overflow, and
  `pad_start`/`pad_end` are held to the same cap (an expression error
  past it).
- Fix: `format`/`percent` with a precision outside 0..20 return `null`
  instead of crashing the node.
- Fix: `//` between two integers is exact (`9007199254740993 // 1` keeps
  its last digit) and still floors negative quotients; with a decimal
  operand it works as before.
- Fix: replacing the template of a mounted runner now updates a running
  `_morph`. It moves from its current value to the new `_to`, follows
  bindings the new `_to` reads, and uses the new `_duration`/`_curve`
  (tween) or `_spring` physics, carrying the current velocity unless the
  new spring is an effect spring. Recompiling unchanged content leaves a
  running morph alone.
- Fix: `app_storage` `due` counts calendar days across a daylight-saving
  change. A stamp at 23:50 on the day clocks spring forward is due with
  `days: 1` at 00:10 the next day.
- Fix: a `serpentine` board reports its intrinsic height (the rows'
  heights plus `spacing`), so it keeps its full height inside an
  `intrinsic_height` or any parent that measures it first.
- Fix: `cross_axis_alignment: baseline` on a `row`, `column` or `flex`
  without `text_baseline`, and `cross_alignment: baseline` on a
  `serpentine_row`, no longer fail layout. They align on the alphabetic
  baseline; `text_baseline` still picks another one.
- Fix: a `shape` on an unbounded axis takes that axis's minimum constraint
  (usually 0) instead of 0, so a minimum from its parent is kept.
- Fix: `nested_scroll_view` children are now checked by position at
  compile time. A box header (anything but the last child) or a sliver
  body (the last child) is a compile error instead of a render failure on
  the device. Sliver headers followed by a box body, a body alone, and no
  children still compile.
- New: `WidgetSpec` and `WidgetSchema` take an optional
  `lastChildProtocol`, the protocol of the last positional child; earlier
  children keep `childProtocol`. An app widget with header/body roles can
  declare it. A null `childProtocol` still skips the check. This adds a
  public field, so the next release is a minor version (0.18.0).
- Fix: a `serpentine` board under RTL draws its track through the cells in
  order. The track is physical: it starts at the top-left cell and runs the
  first row left to right whatever the text direction, so `progress.index`
  0 is the first row's last child in RTL. Mirroring the track for RTL is
  not supported.
- Fix: an app `ExternalCommand` receives the event that started the action
  in `CommandInvocation.event`, including inside `_then`, `_error`,
  `_dismiss`, `_always` and background commands and when the action is
  found on a parent scope. It was always `null`. Overlapping runs each keep
  their own event, and a scope state key named `event` is not mistaken for
  it.
- Fix: a measured command (`net`, or an `ExternalCommand` with `measured`)
  whose scope is disposed while its telemetry span is being reserved no
  longer runs. The span completes once as `cancelled`, and no `_then`,
  `_error`, `_dismiss` or `_always` runs. This applies to background
  commands too.
- Fix: a `haptic` command cancelled while the engine asks the device what
  it supports no longer plays anything (neither the platform fallback nor a
  `continuous` pattern). A legacy rhythm such as `success` cancelled during
  the gap between pulses no longer plays the next pulse.
- Fix: a `NaN` or infinite haptic `pattern` pulse `delay` plays with no
  delay, and a `continuous` curve with a `NaN` or infinite time is rejected
  like any other invalid curve. Both used to crash.
- Fix: a `NaN`, infinite or overflowing `_on` `throttle`/`debounce` is a
  compile error like any other invalid value instead of a crash.
- Fix: an engine `push` whose page sits in a `StatefulShellRoute` branch
  that is switched away from stays pending. It completes with the pop
  result when the page is popped later, and with `null` only when the page
  is actually removed.
- Fix: an engine page in an inactive branch keeps its frozen transition. A
  rebuild after returning to the branch no longer picks up a transition
  from a background cache refresh while the content stays the original.
- Fix: preloaded screens are used only by the loader that preloaded them.
  A route with a loader override (`Sdui.router(loader:)` or its own
  `SduiScreenPage(loader:)`) loads its screen itself and uses
  `defaultType`, instead of showing the preloaded content and transition.
  It no longer refreshes the preload cache either.
- New: `Sdui.page` takes an optional `loader`, the loader its child uses
  (defaults to `Sdui.screenLoader`), so a custom route with an override
  gets a transition from the same source as its content. The generic
  route passes its loader automatically. This adds a public parameter.
- Fix: a `ScreenLoader.load` that throws synchronously is reported as
  `screenLoad` and shows the error surface with retry, like a failed
  future, instead of escaping the page.

## 0.17.5

- Fix: a modal closed before its first frame (a `_background` open followed
  by `close` in the same action) now closes. The open completes with the
  first close's `return` value, and telemetry records the surface's
  `screen_view` and `screen_leave` (reason `closed`).
- Fix: removing the `swipe_pane` being dragged (an `_if` or
  `_presence: false` around it) ends that drag. The other panes settle on
  the nearest page, `on_changed` fires if the index changed, other panes
  can be dragged again, and autoplay resumes after `autoplay_resume_delay`.
- Fix: removing a `video` or changing its `src` while it is still setting up
  stops the setup. The released player gets no further looping, volume or
  play calls.
- Fix: an `_if` or `switch` that shows or hides (a fold) now grows and
  shrinks only along the main axis of the layout it sits in, and keeps its
  size across. In a `column` the height animates and the width stays full,
  so a full-width card no longer narrows while it folds. In a `row` the width
  animates, in a `wrap` or a scroll view its direction does. The slot looks
  through single-child wrappers (`container`, `padding`, `align`, `center`,
  `layout_builder`, another `_if`) for that layout. A `stack` or a layout
  with no direction folds vertically. A swap between two outputs (a
  `_skeleton` load, `_if`/`_else`) still sizes both axes. A run keeps the
  sizing it started with until it settles, so a fold that interrupts a swap,
  or the other way round, does not jump. `_loop` item slots are unchanged
  (they keep their container's axis). Inside a wrapper with a fixed main-axis size (a `sizedbox` with
  a `width` in a `row`) the fold shows no size change, only its motions and
  crossfade.

## 0.17.4

- Fix: during a presence run (a `_skeleton` swap, an `_if` that shows or
  hides, a list insert or removal) content painted above or beside the slot
  (a balloon at `top: -24`, a shadow) and the overflow of a child that
  already fits stay painted. Only a child larger than its moving slot is
  cut, on the side it grows from (the bottom; across, the trailing side).
- Fix: a sliver `_if` or `switch` that shows nothing, and a sliver node that
  fails to build, no longer break the scroll view: they leave an empty
  sliver (the failure diagnostic sits in one).
- Fix: `container(_scope._lifecycle)` or a repeating `_morph` on a bare
  `container` around `expanded` / `flexible` / `positioned` lays out instead
  of failing with "Incorrect use of ParentDataWidget".
- Fix: a `_scope._skeleton` on a bare `container` around parent data is
  skipped with a warning (tag `scope`) and shows the content.
- **Behavior change:** whether a node or scope `_skeleton` can hold a node
  follows the node's declared output only: an app widget not declared as
  parent data, alone or inside a bare `container`, now keeps its bones (a
  node `_skeleton` on it used to be skipped with a warning).
- Fix: a skeleton follows a load notifier its scope replaces, and a keyed
  node `_skeleton` moved to another loading scope follows that scope's load
  and shimmer; the old scope stops its shimmer. The shimmer runs while bones
  paint it, through their exit, and a settled node moved into a loading
  scope starts none.
- Fix: when the mount hooks are replaced while a load is pending, the
  skeleton waits for the new hooks, not the replaced ones.
- Fix: a leaving slot gives its focus nodes back their focus and traversal
  flags when its exit ends or it goes away mid-exit, so a reused focus node
  can take focus again. A moved group settles at once under a muted ticker,
  and a moved `_motion` exit plays with the slot it moved into.
- Loop strategies decide their own layout protocol: an app widget
  registered as `sliver_list` or `sliver_grid` no longer changes how such
  a loop is placed.
- `WidgetSpec.parentData` (a `ParentDataKind`, default `none`): an app
  widget whose output is parent data declares which kind, `flex`
  (`Expanded`, `Flexible`, `Spacer`) or `stack` (`Positioned`), so the
  engine places it in place and wraps nothing around it. The built-in
  `expanded`, `flexible` and `spacer` declare `flex`, `positioned` and
  `positioned_fill` declare `stack`. Only these built-in builders let
  `_motion` and `_on` go on their child; an app widget registered in their
  place (under the same name) does not.
- `WidgetSpec.childParentData` (a `ParentDataKind`, default `none`): the
  parent data a widget takes on its children. The built-in `column`, `row`,
  `flex` and `serpentine_row` take `flex`; `stack` takes `stack`; every
  other widget takes none (`indexed_stack` included: Flutter's
  `IndexedStack` puts a widget between itself and each child). A `_loop`
  item takes what the widget its `_wrap` names (`column`, `row`, `wrap`,
  `serpentine`, `serpentine_row`, `auto_scroll`) takes; the other
  strategies take none.
- Only the built-in `container` and `visibility` hand a single child's
  parent data to their parent: `container` only when it is bare (none of
  `decoration`, `width`, `height`, `padding`, `margin`, `alignment`,
  `constraints`, `color`, `foreground_decoration` or `transform` is set
  and `clip_behavior` is absent or `none`; a bound value counts as set),
  `visibility` only when `maintain_state` and `maintain_size` are absent or
  literal `false` (a bound value counts as on). An app widget registered
  under either name is an ordinary node of its declared kind: `_motion`,
  `_on` and `_skeleton` on it are checked against its own declaration, not
  its child's.
- **New compile errors:** `_motion` or `_on` on an app widget declared as
  parent data (a replaced built-in included), or on a bare `container`
  around parent data, at any depth (put it on a node inside); `_skeleton` on
  such an app widget; a node `_skeleton` whose bones' root is parent data,
  a bare `container` around it included; `_scope._skeleton` in a sliver
  position, on a parent-data node, or with bones that misplace a box,
  sliver or parent-data node anywhere inside; a `cond` or `switch` whose
  branches build both box and sliver nodes. `_scope._skeleton` bones are
  now checked like other nodes except for bindings and action names.
- **New compile errors:** a parent-data node whose parent does not take its
  kind: `expanded` / `flexible` / `spacer` outside a flex, `positioned` /
  `positioned_fill` outside a stack (`indexed_stack` included), at the
  template root or in a slot, under a styled `container` (`padding`,
  `color`, ...) or a `visibility` that maintains state or size, and in a
  `_loop` whose `_wrap` takes none (`list`, ...). These crashed at mount
  time with "Incorrect use of ParentDataWidget". A `cond` or `switch` is
  checked per branch, and a scope, morph or skeleton is transparent.
- **Behavior change:** an app widget that declares no `childParentData`
  takes none, so an `expanded`, `positioned`, ... child under it is now a
  compile error, also when the app widget replaces a built-in such as
  `container`. Migration: an app widget that lays its children in a flex
  or stack declares it, e.g. `EagerSpec(build, childParentData:
  ParentDataKind.flex)` for one that builds a `Row` or `Column`,
  `ParentDataKind.stack` for one that builds a `Stack`. `ParentDataKind`
  is exported from `package:sdui_engine/sdui_engine.dart`.

## 0.17.3

- Fix: a presence exit (a `_skeleton` swap, an `_if` that turns false, ...)
  in the same frame as a focus node elsewhere going away no longer fails
  with "Looking up a deactivated widget's ancestor is unsafe" (seen on hot
  restart). Leaving content now gives up focus at the end of the frame its
  exit starts in.

## 0.17.2

- Fix: a bare `container` around a parent-data node (`expanded`,
  `flexible`, `positioned`, ...) as an `_if` / `cond` body or an eager loop
  item is placed in place like the parent-data node itself. It was put in a
  presence box, so the parent data failed ("Incorrect use of
  ParentDataWidget ... _PresenceParentData") and the frames after it broke.

## 0.17.1

- **Behavior change (`_scope._skeleton` too):** a load that finishes inside
  the 300 ms grace fades the content in again (as in 0.16): the presence swap
  runs from the never-painted skeleton, whose size the slot leaves for the
  content's, and the skeleton stays unpainted. `_presence: false` still swaps
  at once. This reverts the 0.17.0 instant show.
- **Behavior change:** derived bones (`_skeleton: true`) turn every text,
  `rich_text`, image and icon into a bone, literal ones included (a static
  label is a text bone, a static icon a square of its `size`, a static image
  a box of its literal `width` and `height`). Frames keep their literal
  props as before. An image without a literal `width` and `height` now fails
  to compile even when its `src` is literal.
- A derived input or action box keeps the widget's literal `radius` and
  `shape`.

## 0.17.0

- Node `_skeleton` (`_requires: [skeleton_v2]`): a node shows bones while the
  nearest enclosing scope with a `mount` hook loads, and the frames around it
  show at once. The value is a bone tree (`_type`), `true` (bones derived at
  compile time: frames keep literal props, each bound text, image or icon
  becomes one bone, bound paint props are dropped, anything else bound fails
  to compile), `{width}` for one derived leaf, or `true` / `{count, tree}` on a
  `_loop` node (3 rows by default, in a copy of the loop's `_wrap`; lazy and
  sliver wraps fail). The bones sit outside the node's `_if`, so an `_if` that
  is false after the load collapses them. Only scopes with a skeleton below
  wait for their mount actions; every other scope dispatches them as before.
  The bones of one scope share one shimmer phase. A scope with both
  `_scope._skeleton` and node skeletons below fails to compile.
- `skeleton` `of: text` with `style` and `max_lines`: a bone as tall as the
  text it stands for, one bar per line, the last of several at 60 % width.
- **Behavior change (`_scope._skeleton` too):** a load that finishes inside
  the 300 ms grace now shows the content at once instead of animating from the
  reserved skeleton size.
- **Behavior change (`_scope._skeleton` too):** mount actions hold a skeleton
  for at most 8 s. Then the content shows in its current state and a warning
  is logged (tag `scope`); requests are not cancelled and a late response
  updates the content in place.
- Bones are inert (`_scope._skeleton` too): while held or shown they take no
  taps, drags or focus and expose no semantics.
- Derived bones turn an input or action widget (`toggle`, `checkbox`,
  `text_field`, `page_view`, `refresh_indicator`, `dismissible`, …) into one
  box of its literal `width` and `height`; without them compilation fails.
  Loop bones lay an interactive `_wrap` (`reorderable`, `dismissible`,
  `swipe`, `spin_grid`, `auto_scroll`) out as a plain column (a row when it
  scrolls horizontally) keeping only `spacing`, the alignments and `padding`.
- Replacing a scope's hook table while its skeleton waits no longer keeps the
  skeleton: a table without mount hooks settles it, and the 8 s bound holds.
- The shared shimmer runs only while some node skeleton shows bones.

## 0.16.1

- Fix: a binding inside a `_scope` under a presence slot no longer stops
  updating after the content that watched it was removed and shown again
  (the slot's relay was disposed while the scope still cached it).

## 0.16.0

**Behavior change:** structural changes animate by default. `_if`, `cond` and
`switch` grow inserted content into its space and collapse removed content
(enter 300 ms `emphasized_decelerate`, exit 250 ms `emphasized_accelerate`, a
branch swap 300 ms `emphasized` from A's size to B's). Eager `column`, `row`
and `wrap` loops do the same per item, and a `_scope` `_skeleton` swaps to its
content the same way (a load inside the grace also swaps, without bones). The
first build, reduced motion, muted tickers, route changes, reseeds and hot
reload stay instant. Turn it off per node with `_presence: false`.

- `_presence: false | { space, order: parallel|sequential, duration, curve }`
  on any node tunes the transitions of its structural directives.
- `_motion` entries take `on: enter|exit|both` (default `enter`). An exit entry
  plays its motion backwards when the directive removes the content.
- Leaving content keeps its last values, takes no input or semantics, sees
  no action host and pauses its `_scope` lifecycle hooks. It gives up
  keyboard focus and cannot take it again (by tap or Tab) until it comes
  back.
- `SduiPresentation.presence` (`PresenceStyle`) sets the app-wide durations and
  curves. `Motion.affectsLayout` (default `false`, `reveal` true) lets a
  custom motion own the space. It is a new concrete getter on `Motion`: an
  app class that `implements Motion` (instead of extending it) must add it.
- Lazy and sliver loops, `swipe`, `spin_grid`, `auto_scroll`, `serpentine*`,
  `reorderable`, `dismissible` (wrap and body), loop reorders and sliver
  bodies of `cond`/`switch` stay instant. Parent-data bodies (`expanded`,
  `flexible`, `positioned*`, `spacer`) play exits in place without a size
  animation; while leaving they still receive taps, which dispatch nothing
  (no action host), and they cannot take keyboard focus while they exit.
  App-registered widgets are placed in place the same way (no space
  animation) under structural directives: if any branch of a `cond` or
  `switch`, or an eager loop body, is an app-registered type, that whole
  directive is placed in place (no space or swap animation; exit motions
  still play).
- Declare `_requires: [presence_v1]` for `_presence` and `on:`. Older engines
  play `on: exit` entries as entrances; gate by app version on the server.

Performance only (the items below); what is shown, padded and dispatched is unchanged.

- Reduced-motion reads (engine page transition decision, `shared_element`,
  spring `_morph`) now depend only on `MediaQuery` `disableAnimations`, so
  keyboard inset, padding and rotation changes no longer rebuild the
  navigator's page list or re-run their setup.
- The background refresh after a cache hit now starts once the page's entrance
  transition has completed (after the first frame when there is none), so its
  decode never lands inside the transition. A page popped mid-transition
  starts it when it leaves, and one whose tab is switched away mid-transition
  starts it then; every open still refreshes once.
- `single_child_scroll_view` puts its content in a repaint boundary, and the
  box node under each `_scope` with `_lifecycle` hooks (a section that loads
  or ticks) gets one (never on slivers; inside parent-data widgets). A state
  change or scroll repaints only the affected section instead of the whole
  page; scopes without hooks (e.g. a per-row `_action`) add no layer.
- Debug logging: per-frame `scroll` event actions run silently like interval
  ticks (`start_reached`/`end_reached` still log). Silent work still logs
  warnings and errors, so a failing tick or scroll action stays visible.
  Release builds were already silent.

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
