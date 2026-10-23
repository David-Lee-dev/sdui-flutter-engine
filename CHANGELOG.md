# Changelog

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
