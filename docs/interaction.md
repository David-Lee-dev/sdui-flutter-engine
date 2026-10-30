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

The short form is a non-empty action name. The object form allows exactly `do`, `throttle`, `debounce`, `ripple`, `event`, and `pressed_as`. `do` is required. `throttle` and `debounce` are mutually exclusive positive millisecond numbers (numeric strings are accepted): throttle is leading-edge and drops later events in the window; debounce is trailing-edge and keeps only the last event after a quiet period. Different event names time independently, and pending timers are cancelled when the wrapper disposes.

`event` is recursively expression-bindable and is exposed to the action as `$event`. For scroll events, runtime metrics are the emitted payload.

## Tap feedback

A configured `tap` uses button semantics and renders press feedback through the app's `TapFeedback` implementation unless `ripple: false`. Double-tap and long-press share the detector. Without a tap handler, other gestures use a plain opaque `GestureDetector` and no button semantics.

The engine owns *when* feedback applies (which nodes are tappable, the `ripple: false` opt-out, semantics); the app owns *how it looks*, through the [`TapFeedback`](../lib/src/contract/tap_feedback.dart) contract. The package default is `InkTapFeedback` — Flutter's stock ink ripple, wrapped in a transparent `Material` so it works without a Material ancestor. Replace it once at initialization:

```dart
Sdui.initialize(
  // Required dependencies omitted.
  presentation: const SduiPresentation(
    tapFeedback: MyTapFeedback(),
  ),
);
```

`MyTapFeedback` implements `TapFeedback.wrap(context, child, {onTap, onLongPress, onDoubleTap})`, invoking the callbacks and rendering whatever press effect the app wants — the starter kit ships an advanced tint + press-inset implementation as a reference.

## Press state

`tap: { do, pressed_as: <name> }` declares a bool variable that is `true` while the tap is held (since 0.9.0, `_requires: [press_v1]`). The node's own props and its descendants can read it; siblings cannot.

```yaml
_type: container
color: '${down ? "#FFE0E0E0" : "#FFFFFFFF"}'
_on:
  tap: { do: submit, pressed_as: down }
_child: { _type: text, value: '${down ? "Release to send" : "Send"}' }
```

- It turns `true` when the first pointer goes down on the node and `false` on pointer up or cancel, when that pointer moves past the touch slop (a scroll taking the gesture, a drag away), and when the node goes away while held. Further pointers are ignored.
- It works with `ripple: true` or `false` and does not change when the action fires; the tap still follows `throttle`/`debounce`.
- An unbindable name is a compile error; a non-string or empty value, or `pressed_as` on another event, is ignored.

Input events are rejected on non-bound widget specifications. Every referenced action must exist in the enclosing lexical action chain. See [actions](actions.md) and [state](state.md).
