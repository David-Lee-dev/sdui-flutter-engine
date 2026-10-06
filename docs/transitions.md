# Page transitions

Page transitions animate screens mounted through `Sdui.screenRoute`. They are separate from widget `_motion` and modal presentation.

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
| `fade` | Opacity 0 → 1 | none | 200 / 150 ms |
| `slide_up` | Bottom offset → 0, opacity 0 → 1 | `distance`: fraction of page height, default `0.08`, inclusive range `0..1` | 250 / 200 ms |
| `zoom` | Centered scale → 1, opacity 0 → 1 | `begin_scale`: default `0.94`, inclusive range `0.5..1` | 250 / 200 ms |
| `fade_through` | Outgoing opacity 1 → 0 before the threshold; incoming opacity 0 → 1 and scale 0.92 → 1 afterward | `threshold`: default `0.35`, inclusive range `0..1` | 300 / 250 ms |
| `shared_axis` | x/y: incoming +distance → 0, outgoing 0 → −distance with cross-fade; z: incoming scale 0.8 → 1, outgoing 1 → 1.1 with cross-fade | `axis`: `x`, `y`, or `z`, default `x`; `distance`: logical pixels for x/y, default `30`, inclusive range `0..200` | 300 / 250 ms |

`shared_axis` flips x offsets in RTL. Its pixel distance is independent of page dimensions. `fade_through` threshold endpoints are allowed: 0 makes the exit immediate after the start, and 1 makes the entrance immediate at the end.

Both effects animate the page below using the incoming route's specification, curve and secondary animation, including pop and iOS swipe. Route-pair animation applies only between engine transition routes. With legacy Material/Cupertino pages or app routes, the engine page plays its incoming half and the neighbour keeps its platform transition behaviour; the engine does not install an outgoing effect on that neighbour.

Numeric built-in parameters must be finite numbers within the listed bounds. Unknown parameter keys, invalid axis strings, wrong parameter types, nulls and out-of-range values are rejected. Custom effect names without a built-in schema accept arbitrary static JSON parameters; the custom implementation owns their interpretation.

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

The base custom-effect duration is 250 ms in both directions. Explicit template durations always override effect defaults.

Override `defaultReverseDuration` to choose a separate pop duration; otherwise it equals `defaultDuration`.

## Server compilation and compatibility

Server/build-time compilers must pass `Compile.build(template, state, screen: true)` for screen roots. The default compilation mode rejects `_transition`. A server compiling custom effect names must include those names in its `LanguageCatalog.transitions`; compilation does not import runtime implementations.

Version-gate templates containing `_transition` to app versions that support it. Older apps reject the reserved key rather than ignoring it, even if their presentation configuration disables transitions.

## Shared elements

Wrap the source and destination's box widget with [`shared_element`](widgets/custom/shared_element.md) and the same `tag`. The engine uses Flutter Hero to interpolate its rectangle and optional `radius` while the page's `_transition` runs. Push crossfades source and destination snapshots while their rectangle and radius interpolate; pop reverses the endpoints. Both images use aspect-preserving cover cropping inside the animated rounded rectangle. If destination capture is unavailable, the flight keeps the source snapshot. The live child and its GlobalKeys are never duplicated in the overlay. An empty placeholder keeps each slot at its original size without a faint second card beneath the flight.

```yaml
_type: shared_element
tag: "product-${id}"
radius: 12
_child:
  _type: image
  src: "${image}"
```

The destination must be present on the first frame. Preloaded screens are rendered synchronously, but elements inside `_skeleton` or data-dependent subtrees that appear later cannot fly. Removed/scrolled-away source slots simply have no matching pop flight.

Duplicate tags within a route disable every participant with that tag and emit a debug diagnostic; fixing duplicates restores participation. Modal surfaces, inactive tabs (`TickerMode: false`), zero-size/unpainted sources, platform views, and reduced motion (`respectReducedMotion` plus `disableAnimations`) do not fly. Navigation continues normally. A `video` flies only as pixels and initializes again at its destination; controller handoff is outside v1.

`content_timing: during_shared` drives destination content over the latter route interval (0.3–1.0), using the page effect once. On custom engine routes, `after_shared` keeps destination content transparent until the flight lands, then reveals it in a short 120 ms fade using the page curve. The page effect is held fully visible while waiting, so it does not dim the content a second time during the reveal. A missing match keeps the normal page effect. Platform/legacy routes retain their host transitions and concurrent content behavior.

v1 guarantees flights only inside the same Navigator. Tab-shell branch-to-root behavior is unverified; cross-Navigator tags are isolated. go_router 14.8.1 provides each Navigator's HeroControllerScope (`lib/src/builder.dart`).
