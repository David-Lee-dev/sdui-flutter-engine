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
| `content_timing` | string | `during_shared` | Accepts `during_shared` or `after_shared`; retained as metadata for shared-content integration. |
| `params` | map | `{}` | Effect-specific static parameters. |

Unknown declaration keys are rejected at compile time.

## Built-in effects

| Type | Visual | Params | Push / pop default |
| --- | --- | --- | --- |
| `platform` | Host Material/Cupertino route transition | none | Host route defaults |
| `none` | Immediate page change | none | 0 / 0 ms |
| `fade` | Opacity 0 → 1 | none | 300 / 300 ms |
| `slide_up` | Bottom offset → 0, opacity 0 → 1 | `distance`: fraction of page height, default `0.08`, inclusive range `0..1` | 280 / 220 ms |
| `zoom` | Centered scale → 1, opacity 0 → 1 | `begin_scale`: default `0.94`, inclusive range `0.5..1` | 280 / 220 ms |

Built-in parameters must be finite numbers within the listed bounds. Unknown parameter keys, strings, booleans, nulls and out-of-range values are rejected. Custom effect names without a built-in schema accept arbitrary static JSON parameters; the custom implementation owns their interpretation.

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

The primary animation already includes the declared curve. Effects should derive transforms from that animation so push, pop and swipe remain synchronized. Override `defaultReverseDuration` to choose a separate pop duration; otherwise it equals `defaultDuration`.

## Server compilation and compatibility

Server/build-time compilers must pass `Compile.build(template, state, screen: true)` for screen roots. The default compilation mode rejects `_transition`. A server compiling custom effect names must include those names in its `LanguageCatalog.transitions`; compilation does not import runtime implementations.

Version-gate templates containing `_transition` to app versions that support it. Older apps reject the reserved key rather than ignoring it, even if their presentation configuration disables transitions.
