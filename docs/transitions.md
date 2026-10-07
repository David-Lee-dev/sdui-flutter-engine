# Page transitions

Page transitions animate screens opened through the generic `/screens/:id` route of `Sdui.router` (the engine navigation handle used by `SduiScreenPage`). They are separate from widget `_motion` and modal presentation.

## Enable transitions

Configure app defaults at initialization:

```dart
Sdui.initialize(
  screenLoader: loader,
  networkClient: networkClient,
  imageSource: imageSource,
  videoSource: videoSource,
  appStorage: appStorage,
  secureStorage: secureStorage,
  presentation: const SduiPresentation(
    transitions: PageTransitionStyle(
      enabled: true,
      defaultType: 'slide_up',
      preloadTimeout: Duration(milliseconds: 300),
      respectReducedMotion: true,
    ),
  ),
);
```

Transitions are disabled by default; `defaultType` defaults to `platform`. `SduiScreenPage` supplies the engine navigation handle with its loader for preloading. App-owned navigation handles must provide their own integration.

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
| Vertical "present" without depth | `slide_up` | `_transition: { type: slide_up }` |
| Quiet default for everything else | `fade` | `defaultType: 'fade'` in `PageTransitionStyle` |
| No animation (e.g. replacing a splash or an auth gate) | `none` | `_transition: { type: none }` |

Rules of thumb:

1. Declare the effect on the destination screen; the source screen only marks what grows (`transition_source`) or what flies (`shared_element`).
2. Keep durations on defaults (150–260 ms) unless a design asks otherwise; longer transitions feel slow on device.
3. Use `container_transform` when the whole card should become the page, and `shared_element` when one element should continue while the rest of the page fades in.
4. Do not combine both on the same element: a `shared_element` inside a `transition_source` grows with the container snapshot instead of flying separately.
5. Effects run only when the app enables transitions and the screen is opened by an engine `navigate` push/go; deep links and direct router calls use the platform transition.

## Screen declaration

`_transition` is allowed only at a screen root, never on a child node or modal. All values must be static JSON literals; `${…}` expressions are rejected.

```yaml
_type: scaffold
_transition:
  type: slide_up
  duration: 280
  reverse_duration: 220
  curve: ease_out
  params:
    distance: 0.08
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
| `slide_up` | Bottom offset → 0, opacity 0 → 1 | `distance`: fraction of page height, default `0.08`, inclusive range `0..1` | 200 / 160 ms |
| `zoom` | Centered scale → 1, opacity 0 → 1 | `begin_scale`: default `0.94`, inclusive range `0.5..1` | 200 / 160 ms |
| `fade_through` | Outgoing opacity 1 → 0 before the threshold; incoming opacity 0 → 1 and scale 0.92 → 1 afterward | `threshold`: default `0.35`, inclusive range `0..1` | 220 / 180 ms |
| `shared_axis` | x/y: incoming +distance → 0, outgoing 0 → −distance with cross-fade; z: incoming scale 0.8 → 1, outgoing 1 → 1.1 with cross-fade | `axis`: `x`, `y`, or `z`, default `x`; `distance`: logical pixels for x/y, default `30`, inclusive range `0..200` | 220 / 180 ms |
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

Pointer-down inside the wrapper captures only its box pixels and global rectangle. The engine screen also records the last pointer-down position for `tap_zoom`; no app callback or new gesture recognizer is required. The preload push consumes both once, within one second and in the same Navigator. A later pointer-down clears an earlier armed source. An unmounted, stale, empty, unpainted or unsupported platform-view source falls back to `fade`; a missing/stale tap or a different Navigator uses screen center for `tap_zoom`. Keyboard/programmatic navigation has the same fallbacks when no fresh pointer origin exists. `_transition` remains static.

`container_transform` interpolates source rectangle → full page and source radius → `0`. Its snapshot uses aspect-preserving cover cropping and fades out over progress `0..0.35`; destination content fades in over `0.35..1`. The optional scrim defaults to zero to avoid imposing a backdrop on authored pages. Back and the existing iOS edge swipe retrace these values. At the start of a return, the engine re-reads a mounted source's global rectangle; if it has been removed, it uses the stored rectangle and original snapshot. The source keeps its layout and live widget state while its painting is hidden during motion, and is restored on push completion, pop, swipe cancellation/completion and route removal, including removal mid-drag.

A `shared_element` inside the captured source is part of that snapshot: its matching Hero tag is excluded from separate flights until the container route is removed, including on pop. Nested video therefore uses the container snapshot rather than continuous Hero handoff. Shared elements outside the wrapper still fly normally; container geometry remains on the original route progress even when shared-content timing is enabled. No live widget subtree or GlobalKey is duplicated.

`card_stack` applies its outgoing half only to another engine transition route; a legacy Material/Cupertino neighbour retains host behavior while the incoming page still slides up. `tap_zoom` maps the captured global tap into the destination route rectangle and clamps its alignment to the page edges; pop returns toward that same point. Reduced motion selects `none` for all three effects.

## Precedence and loading

1. When `enabled` is false, navigation uses the legacy host route path.
2. When transitions are enabled and `respectReducedMotion` is true, `MediaQuery.disableAnimations` selects `none` for a preloaded route.
3. A successfully preloaded screen's `_transition` overrides `defaultType`.
4. If the screen has no declaration or preload times out, `defaultType` is selected.

The engine navigation handle preloads an owned screen before pushing or replacing it, waiting up to `preloadTimeout` (default 300 ms). A completed load supplies the screen and declaration together. On timeout, navigation proceeds with the default effect and adopts the same pending load: it does not issue a second request or change the chosen effect when the late declaration arrives. Load failures use the screen's existing error surface. A newer navigation abandons the pending navigation so a late load cannot push a stale destination.

Direct router calls and deep links without engine preloading use the host platform route. `platform` uses the host route rather than a custom effect, including its gesture and timing behavior.

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

The destination must be present on the first frame. Preloaded screens are rendered synchronously, but elements inside `_skeleton` or data-dependent subtrees that appear later cannot fly. Removed/scrolled-away source slots simply have no matching pop flight.

Duplicate tags within a route disable every participant with that tag and emit a debug diagnostic; fixing duplicates restores participation. Modal surfaces, inactive tabs (`TickerMode: false`), zero-size/unpainted sources, platform views, and reduced motion (`respectReducedMotion` plus `disableAnimations`) do not fly. Navigation continues normally. A shared subtree with exactly one `video` at each endpoint and the same `src` instead flies a live video surface. Its internal session key is (Navigator identity, evaluated shared tag, exact src). One controller and initialization Future retain position through push/pop; each endpoint and shuttle builds its own view of that controller, allowing handoff-frame overlap while only one owner handles controls and events. The destination owns playback controls, callbacks and configuration after push, and pop returns ownership to the source. The last participant/flight lease disposes the controller. Different sources or duplicate tags do not hand off. Texture-backed `PlayerVideoController` is supported; custom platform views are unsupported for continuous handoff, may flicker when remounted and skip flights. Untagged videos retain their independent lifecycle. See [continuous video](widgets/custom/video.md#continuous-video-across-navigation).

`content_timing: during_shared` drives destination content over the latter route interval (0.3–1.0), using the page effect once. On custom engine routes, `after_shared` keeps destination content transparent until the flight lands, then reveals it in a short 120 ms fade using the page curve. The page effect is held fully visible while waiting, so it does not dim the content a second time during the reveal. A missing match keeps the normal page effect. Platform/legacy routes retain their host transitions and concurrent content behavior.

Flights follow the iOS edge swipe: the element shrinks back under the finger, returns on cancel, and the source is restored on both outcomes.

When a screen shows several videos at once, the app's `VideoSource` should create players with `PlayerVideoController.asset/network(..., options: VideoPlayerOptions(mixWithOthers: true))`; otherwise Android audio focus pauses all but one, even muted.

Known limitation: if code removes the destination route (`navigate go`, deep link, redirect) while an iOS edge swipe is still being dragged, that flight is not resolved and the source element can stay hidden until the screen rebuilds. Completed and cancelled swipes and Back are unaffected.

v1 guarantees flights only inside the same Navigator. Tab-shell branch-to-root behavior is unverified; cross-Navigator tags are isolated. go_router 14.8.1 provides each Navigator's HeroControllerScope (`lib/src/builder.dart`).
