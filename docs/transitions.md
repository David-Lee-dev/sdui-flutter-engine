# Page transitions

Page transitions animate engine screens served by the generic `/screens/:id` route of `Sdui.router` or by an app route built with `Sdui.page`. They are separate from widget `_motion` and modal presentation.

## Enable transitions

Configure app defaults and the screens to preload at initialization:

```dart
await Sdui.initialize(
  screenLoader: loader,
  networkClient: networkClient,
  imageSource: imageSource,
  videoSource: videoSource,
  appStorage: appStorage,
  secureStorage: secureStorage,
  preloadScreens: ['partner-detail'],
  presentation: const SduiPresentation(
    transitions: PageTransitionStyle(
      enabled: true,
      defaultType: 'slide',
      respectReducedMotion: true,
    ),
  ),
);
```

Transitions are disabled by default; `defaultType` defaults to `platform`.

`preloadScreens` lists screen ids the SDK loads through the configured `ScreenLoader` right after initialization and keeps in an SDK-owned in-memory cache. The returned future completes once every listed load has settled; a failed load is reported through the error observer (`screenLoad`) and leaves that id uncached. Only cached screens use their declared `_transition`; every other screen opens with `defaultType`.

App routes that serve engine screens build their page with `Sdui.page`, the same function the generic route uses:

```dart
GoRoute(
  path: '/:screenId',
  pageBuilder: (context, state) => Sdui.page(
    context,
    state,
    screenId: state.pathParameters['screenId']!,
    child: SduiScreenPage(
      screenId: state.pathParameters['screenId']!,
      loader: Sdui.screenLoader,
    ),
  ),
)
```

`go` keeps one page per path pattern, so `go('/detail')` then `go('/mission')` reuses the page. `Sdui.page` remounts `child` whenever the screen id changes, so content, `screen_view` and transition always belong to the new screen; `child` needs no key of its own.

## Choosing an effect

Available since engine `0.2.0`. Pick by the relationship between the two screens:

| Situation | Recommended | Template |
| --- | --- | --- |
| List/grid item → its detail page (the card becomes the page) | `container_transform` | wrap the card's growing part in `transition_source`; detail root `_transition: { type: container_transform }` |
| One element (image, thumbnail, video) continues into the detail page | `shared_element` + `fade` | same `tag` on both screens; detail root `_transition: { type: fade }` |
| Same element must keep playing video across the transition | `shared_element` with one `video` | same tag and identical `src` at both ends |
| Forward/backward step in a flow (wizard, onboarding) | `shared_axis` (`axis: x`) | `_transition: { type: shared_axis, params: { axis: x } }` |
| Parent → child level of a hierarchy | `shared_axis` (`axis: z`) or `zoom` | `_transition: { type: shared_axis, params: { axis: z } }` |
| Switching between unrelated screens | `fade_through` | `_transition: { type: fade_through }` |
| Sheet-like page (settings, compose, filters) over a context | `card_stack` | `_transition: { type: card_stack }` |
| Page opened from a button/FAB with no card to grow from | `tap_zoom` | `_transition: { type: tap_zoom }` |
| Vertical "present" without depth | `slide` | `_transition: { type: slide, params: { y: 0.08 } }` |
| Quiet default for everything else | `fade` | `defaultType: 'fade'` in `PageTransitionStyle` |
| No animation (e.g. replacing a splash or an auth gate) | `none` | `_transition: { type: none }` |

Rules of thumb:

1. Declare the effect on the destination screen; the source screen only marks what grows (`transition_source`) or what flies (`shared_element`).
2. Keep durations on defaults (150–260 ms) unless a design asks otherwise; longer transitions feel slow on device.
3. Use `container_transform` when the whole card should become the page, and `shared_element` when one element should continue while the rest of the page fades in.
4. Do not combine both on the same element: a `shared_element` inside a `transition_source` grows with the container snapshot instead of flying separately.
5. Effects run only when the app enables transitions and the page is built by `Sdui.page` (or the generic route). A screen's own `_transition` applies only when it is listed in `preloadScreens`; uncached screens use `defaultType`.

## Screen declaration

`_transition` is allowed only at a screen root, never on a child node or modal. All values must be static JSON literals; `${…}` expressions are rejected.

```yaml
_type: scaffold
_transition:
  type: slide
  duration: 280
  reverse_duration: 220
  curve: ease_out
  params:
    y: 0.08
_slots:
  body:
    _type: text
    value: Ready
```

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | non-empty string | required | Registered effect name. |
| `duration` | finite number ≥ 0 | effect default | Push duration in milliseconds, rounded to an integer. |
| `reverse_duration` | finite number ≥ 0 | effect default | Pop duration in milliseconds, rounded to an integer. |
| `curve` | EngineCurve name | `linear` | Maps the route animation for both push and reverse playback. |
| `content_timing` | string | `during_shared` | Reveals non-shared page content over route progress 0.3–1.0 (`during_shared`), or hides it until snapshot flights land and then fades it in (`after_shared`). Without a matching flight, the normal page effect applies. |
| `params` | map | `{}` | Effect-specific static parameters. |

Unknown declaration keys are rejected at compile time.

## Built-in effects

| Type | Visual | Params | Push / pop default |
| --- | --- | --- | --- |
| `platform` | Host Material/Cupertino route transition | none | Host route defaults |
| `none` | Immediate page change | none | 0 / 0 ms |
| `fade` | Opacity 0 → 1 | none | 150 / 120 ms |
| `slide` | Offset → 0, optional opacity 0 → 1 | `x`: fraction of page width, default `0`, inclusive range `-1..1`; `y`: fraction of page height, default `0`, inclusive range `-1..1`; `fade`: default `true` | 200 / 160 ms |
| `zoom` | Centered scale → 1, opacity 0 → 1 | `begin_scale`: default `0.94`, inclusive range `0.5..1` | 200 / 160 ms |
| `fade_through` | Outgoing opacity 1 → 0 before the threshold; incoming opacity 0 → 1 and scale 0.92 → 1 afterward | `threshold`: default `0.35`, inclusive range `0..1` | 220 / 180 ms |
| `shared_axis` | x/y: incoming +distance → 0, outgoing 0 → −distance with cross-fade; z: incoming scale 0.8 → 1, outgoing 1 → 1.1 with cross-fade | `axis`: `x`, `y`, or `z`, default `x`; `distance`: logical pixels for x/y, default `30`, inclusive range `-200..200` (negative reverses direction) | 220 / 180 ms |
| `container_transform` | Captured source box grows into the full page, rounding to square with a fade-through snapshot | `scrim`: default `0`, inclusive range `0..1`; dims the previous engine page | 250 / 200 ms |
| `card_stack` | Incoming page rises a full page height; previous engine page scales down, rounds and dims | `scale`: default `0.94`, `0.8..1`; `radius`: default `12`, `0..40`; `dim`: default `0.2`, `0..0.6` | 260 / 220 ms |
| `tap_zoom` | Incoming page grows from the latest pointer-down position with a fade | `begin_scale`: default `0.1`, inclusive range `0.05..1` | 220 / 180 ms |

`none` swaps pages instantly in both directions, so shared elements do not fly; omit `duration` for it (a duration only delays an invisible change). An iOS swipe on a `none` page has no visual scrub and pops when released.

`shared_axis` flips x offsets in RTL. Its pixel distance is independent of page dimensions. `fade_through` threshold endpoints are allowed: 0 makes the exit immediate after the start, and 1 makes the entrance immediate at the end.

Both effects animate the page below using the incoming route's specification, curve and secondary animation, including pop and iOS swipe. Route-pair animation applies only between engine transition routes. With legacy Material/Cupertino pages or app routes, the engine page plays its incoming half and the neighbour keeps its platform transition behaviour; the engine does not install an outgoing effect on that neighbour.

Numeric built-in parameters must be finite numbers within the listed bounds. Unknown parameter keys, invalid axis strings, wrong parameter types, nulls and out-of-range values are rejected. Custom effect names without a built-in schema accept arbitrary static JSON parameters; the custom implementation owns their interpretation.

## Source wrapper and tap origins

Wrap precisely the part of a card that should grow in [`transition_source`](widgets/custom/transition_source.md). Put labels or controls that should stay behind outside that wrapper. Its optional `radius` is the source's actual corner radius (default `0`). Declare `container_transform` on the destination screen:

```yaml
# Source card
_type: column
_children:
  - _type: transition_source
    radius: 16
    _child:
      _type: image
      src: "${image}"
      width: 160
      height: 100
  - _type: text
    value: "${title}"

# Destination screen root
_type: scaffold
_transition: { type: container_transform }
_slots:
  body: { _type: text, value: Detail }
```

Pointer-down inside the wrapper captures only its box pixels and global rectangle. The engine screen also records the last pointer-down position for `tap_zoom`; no app callback or new gesture recognizer is required. The destination engine route consumes both once from its own Navigator when it is installed, within one second of the pointer-down. A later pointer-down clears an earlier armed source. An unmounted, stale, empty, unpainted or unsupported platform-view source falls back to `fade`; a missing/stale tap or a different Navigator uses screen center for `tap_zoom`. Keyboard/programmatic navigation has the same fallbacks when no fresh pointer origin exists. `_transition` remains static.

`container_transform` interpolates source rectangle → full page and source radius → `0`. Its snapshot uses aspect-preserving cover cropping and fades out over progress `0..0.35`; destination content fades in over `0.35..1`. The optional scrim defaults to zero to avoid imposing a backdrop on authored pages. Back and the existing iOS edge swipe retrace these values. At the start of a return, the engine re-reads a mounted source's global rectangle; if it has been removed, it uses the stored rectangle and original snapshot. The source keeps its layout and live widget state while its painting is hidden during motion, and is restored on push completion, pop, swipe cancellation/completion and route removal, including removal mid-drag.

A `shared_element` inside the captured source is part of that snapshot: its matching Hero tag is excluded from separate flights until the container route is removed, including on pop. Nested video therefore uses the container snapshot rather than continuous Hero handoff. Shared elements outside the wrapper still fly normally; container geometry remains on the original route progress even when shared-content timing is enabled. No live widget subtree or GlobalKey is duplicated.

`card_stack` applies its outgoing half only to another engine transition route; a legacy Material/Cupertino neighbour retains host behavior while the incoming page still slides up. `tap_zoom` maps the captured global tap into the destination route rectangle and clamps its alignment to the page edges; pop returns toward that same point. Reduced motion selects `none` for all three effects.

## Precedence and loading

1. When `enabled` is false, every page uses the legacy host route path.
2. When transitions are enabled and `respectReducedMotion` is true, `MediaQuery.disableAnimations` selects `none`.
3. A cached screen's `_transition` overrides `defaultType`. The declaration is validated once per load; an invalid one is reported (`templateCompile`) and the default is used.
4. A screen that is not cached, or has no declaration, uses `defaultType`.

Navigation never waits on a load: the engine navigation handle pushes or replaces immediately. A cached screen renders on the destination's first frame; an uncached one shows the loading surface and loads as before. After a cache hit the SDK reloads that screen in the background and replaces the cache entry for the next open — the page already shown is not changed. The reload starts once the page's entrance transition has completed (right after the first frame when there is none), so decoding the response never lands inside the transition; a page popped before its transition completes starts it when it leaves.

The decision (page type, effect and the cache entry it was made from) is frozen per page for its lifetime, so pageBuilder rebuilds and background refreshes never change an open page, and pop reverses the same effect. It is released when the page leaves the router configuration; reopening decides again from the current cache. Deep links and direct router calls follow the same rules. `platform` uses the host route rather than a custom effect, including its gesture and timing behavior.

Navigation-time preloading (with its wait, preload timeout setting on `PageTransitionStyle`, and abandonment) and the `SduiScreenPage.preloaded` parameter were removed; list screens in `preloadScreens` instead.

## Back navigation

Back plays the selected effect in reverse using `reverse_duration`. The same curve maps the route value in both directions, so reverse playback retraces the push geometry. On iOS, an eligible leading-edge swipe scrubs that same animation; cancel restores the page and completion pops it. This applies to custom effects as well as built-ins.

## Custom effects

Implement `PageTransitionEffect` and register it before initialization freezes the factory:

```dart
class AppFade extends PageTransitionEffect {
  const AppFade();

  @override
  String get type => 'app_fade';

  @override
  Duration get defaultDuration => const Duration(milliseconds: 240);

  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => FadeTransition(opacity: animation, child: child);
}

Sdui.initialize(
  screenLoader: loader,
  networkClient: networkClient,
  imageSource: imageSource,
  videoSource: videoSource,
  appStorage: appStorage,
  secureStorage: secureStorage,
  transitions: const [AppFade()],
  presentation: const SduiPresentation(
    transitions: PageTransitionStyle(enabled: true, defaultType: 'app_fade'),
  ),
);
```

The primary animation already includes the declared curve. Effects should derive transforms from that animation so push, pop and swipe remain synchronized. Optionally override `buildOutgoing(context, animation, child, spec)` to animate the previous engine page. That animation includes the incoming route's curve and follows its secondary progress. The default returns `null`, preserving existing custom effects. A supplied outgoing widget replaces the previous effect's secondary transition to avoid double animation; its primary transition remains active.

The base custom-effect duration is 200 ms in both directions. Explicit template durations always override effect defaults.

Override `defaultReverseDuration` to choose a separate pop duration; otherwise it equals `defaultDuration`.

## Server compilation and compatibility

Server/build-time compilers must pass `Compile.build(template, state, screen: true)` for screen roots. The default compilation mode rejects `_transition`. A server compiling custom effect names must include those names in its `LanguageCatalog.transitions`; compilation does not import runtime implementations.

Version-gate templates containing `_transition` to app versions that support it. Older apps reject the reserved key rather than ignoring it, even if their presentation configuration disables transitions.

## Shared elements

Wrap the source and destination's box widget with [`shared_element`](widgets/custom/shared_element.md) and the same `tag`. The engine uses Flutter Hero to interpolate its rectangle while the page's `_transition` runs. `radius` is the element's real corner radius: the wrapper clips its child at rest, and the flight interpolates from the source radius to the destination radius (for example a card at `16` and a full-width header at `0`), so corners never snap on landing. Push crossfades source and destination snapshots while their rectangle and radius interpolate; pop reverses the endpoints. Both images use aspect-preserving cover cropping inside the animated rounded rectangle. If destination capture is unavailable, the flight keeps the source snapshot. The live child and its GlobalKeys are never duplicated in the overlay. An empty placeholder keeps each slot at its original size without a faint second card beneath the flight.

```yaml
_type: shared_element
tag: "product-${id}"
radius: 12
_child:
  _type: image
  src: "${image}"
```

The destination must be present on the first frame. Cached screens (`preloadScreens`) are rendered synchronously, but elements inside `_skeleton` or data-dependent subtrees that appear later cannot fly. Removed/scrolled-away source slots simply have no matching pop flight.

Duplicate tags within a route disable every participant with that tag and emit a debug diagnostic; fixing duplicates restores participation. Modal surfaces, inactive tabs (`TickerMode: false`), zero-size/unpainted sources, platform views, and reduced motion (`respectReducedMotion` plus `disableAnimations`) do not fly. Navigation continues normally. A shared subtree with exactly one `video` at each endpoint and the same `src` instead flies a live video surface. Its internal session key is (Navigator identity, evaluated shared tag, exact src). One controller and initialization Future retain position through push/pop; each endpoint and shuttle builds its own view of that controller, allowing handoff-frame overlap while only one owner handles controls and events. The destination owns playback controls, callbacks and configuration after push, and pop returns ownership to the source. The last participant/flight lease disposes the controller. Different sources or duplicate tags do not hand off. Texture-backed `PlayerVideoController` is supported; custom platform views are unsupported for continuous handoff, may flicker when remounted and skip flights. Untagged videos retain their independent lifecycle. See [continuous video](widgets/custom/video.md#continuous-video-across-navigation).

`content_timing: during_shared` drives destination content over the latter route interval (0.3–1.0), using the page effect once. On custom engine routes, `after_shared` keeps destination content transparent until the flight lands, then reveals it in a short 120 ms fade using the page curve. The page effect is held fully visible while waiting, so it does not dim the content a second time during the reveal. A missing match keeps the normal page effect. Platform/legacy routes retain their host transitions and concurrent content behavior.

Flights follow the iOS edge swipe: the element shrinks back under the finger, returns on cancel, and the source is restored on both outcomes.

When a screen shows several videos at once, the app's `VideoSource` should create players with `PlayerVideoController.asset/network(..., options: VideoPlayerOptions(mixWithOthers: true))`; otherwise Android audio focus pauses all but one, even muted.

Known limitation: if code removes the destination route (`navigate go`, deep link, redirect) while an iOS edge swipe is still being dragged, that flight is not resolved and the source element can stay hidden until the screen rebuilds. Completed and cancelled swipes and Back are unaffected.

v1 guarantees flights only inside the same Navigator. Tab-shell branch-to-root behavior is unverified; cross-Navigator tags are isolated. go_router 14.8.1 provides each Navigator's HeroControllerScope (`lib/src/builder.dart`).
