# Interaction events

`_on` maps the engine's eight supported events to visible action names, optional timing, payload, and tap feedback settings.

## Events

| Event | Owner | `$event` payload |
| --- | --- | --- |
| `tap` | any widget node | Explicit `_on.tap.event`, or none. |
| `double_tap` | any widget node | Explicit event value, or none. |
| `long_press` | any widget node | Explicit event value, or none. |
| `change` | bound inputs only | Widget value unless an explicit event value is configured by compilation/wrapper behavior. |
| `submit` | bound inputs only | Submitted widget value. |
| `scroll` | nearest depth-0 descendant scrollable | Metrics map on every `ScrollUpdateNotification`. |
| `start_reached` | descendant scrollable | Metrics map on entry into the start threshold zone. |
| `end_reached` | descendant scrollable | Metrics map on entry into the end threshold zone. |

The scroll metrics map is `{offset, extent_after, extent_before, max_extent, progress}`. Progress is clamped to 0–1 and is zero when max extent is not positive. Start/end thresholds default to 300 logical pixels and edge events fire once per zone entry. Nested notifications (`depth != 0`) are ignored.

## Declaration forms

```yaml
_on:
  tap: open
  scroll:
    do: track_scroll
    throttle: 16
  submit:
    do: search
    debounce: 250
    event: { source: keyboard }
```

The short form is a non-empty action name. The object form allows exactly `do`, `throttle`, `debounce`, `ripple`, and `event`. `do` is required. `throttle` and `debounce` are mutually exclusive positive millisecond numbers (numeric strings are accepted): throttle is leading-edge and drops later events in the window; debounce is trailing-edge and keeps only the last event after a quiet period. Different event names time independently, and pending timers are cancelled when the wrapper disposes.

`event` is recursively expression-bindable and is exposed to the action as `$event`. For scroll events, runtime metrics are the emitted payload.

## Tap feedback

A configured `tap` uses button semantics and a combined press-inset/tint effect unless `ripple: false`. Despite the option name, the effect is not a Material ripple: it blends a tint with `srcATop` and scales toward a fixed logical-pixel inset, clamped to 0.94–0.985. Double-tap and long-press share the detector. Without a tap handler, other gestures use a plain opaque `GestureDetector` and no button semantics.

The app can inject the effect's look and timing once at initialization:

```dart
Sdui.initialize(
  // Required dependencies omitted.
  presentation: const SduiPresentation(
    tapEffect: TapEffectStyle(
      tint: Color(0xFF7C4DFF),
      tintOpacity: 0.12,
      inset: 4,
      inDuration: Duration(milliseconds: 90),
      outDuration: Duration(milliseconds: 200),
    ),
  ),
);
```

`TapEffectStyle` defaults preserve the original engine behavior:

| Field | Default | Purpose |
| --- | --- | --- |
| `tint` | `Color(0xFFEDEDED)` | Color blended over painted child pixels. |
| `tintOpacity` | `0.10` | Tint strength at full press. |
| `inset` | `3.5` | Target inset in logical pixels along the longest side. |
| `inDuration` | `110 ms` | Press-in duration and cancellation return duration. |
| `outDuration` | `240 ms` | Release duration. |

Input events are rejected on non-bound widget specifications. Every referenced action must exist in the enclosing lexical action chain. See [actions](actions.md) and [state](state.md).
