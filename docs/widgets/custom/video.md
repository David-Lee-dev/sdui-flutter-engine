# video

Builds a policy-backed video player with optional playback interaction.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `src` | `text` | — | `null` | Yes | media source path or URL. |
| `loop` | `flag` | — | `true` | Yes | true wraps past the last page back to the first. |
| `autoplay` | `flag` | — | `true` | Yes | starts playback automatically. |
| `muted` | `flag` | — | `false` | Yes | starts playback without audio. |
| `fit` | `boxFit` | fill, contain, cover, fit_width, fit_height, none, scale_down | `cover` | Yes | content fitting mode. Values: fill \| contain \| cover \| fit_width \| fit_height \| none \| scale_down. |
| `aspect_ratio` | `number` | — | `null` | Yes | width-to-height ratio of the rendered box. |
| `show_controls` | `flag` | — | `false` | Yes | shows playback controls over the video. |
| `on_end` | `text` | — | `null` | Yes | action dispatched when playback ends. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: video
src: example
```

```yaml
_type: video
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
```

## Continuous video across navigation

Wrap one `video` at each endpoint in a [`shared_element`](shared_element.md) with the same evaluated `tag` and exactly the same `src`. Within the same Navigator, the engine retains one controller and one initialization Future, preserving playback position through push, flight and pop. Untagged videos and differing `tag` or `src` values keep independent controllers, even when multiple cards use the same asset.

```yaml
_type: shared_element
tag: "video-${id}"
radius: 16
_child:
  _type: video
  src: assets/videos/counter.mp4
  autoplay: true
  loop: true
  muted: true
```

The destination owns controls, `on_end`, loop, volume and autoplay after push; pop returns ownership to the source. Only the active owner receives playback callbacks. Autoplay may resume a paused controller but never seeks or initializes it again. Each endpoint and the live shuttle builds its own view from the same controller; the flight uses cover cropping and keeps endpoint slots offstage. Views may overlap during handoff frames, but only one owner handles controls and events. The controller is disposed once when the last route/flight reference leaves.

Texture-backed `PlayerVideoController` is the supported continuous path. Custom platform-view controllers are unsupported for continuous handoff: remounting their view may flicker; platform views skip the Hero flight. Use one video per shared-element subtree, unique tags per route, and keep both endpoints mounted on the destination's first frame. Modal surfaces and initially inactive tabs do not participate; reduced motion disables the flight.

When displaying multiple videos at once, the app's `VideoSource` must allow concurrent playback. With `video_player`, create `VideoPlayerController` with `VideoPlayerOptions(mixWithOthers: true)` and wrap it in `PlayerVideoController`. On Android, the default audio-focus policy can pause another player even if its volume is zero; `muted` alone does not disable focus handling. The engine does not override the app's audio policy.

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
