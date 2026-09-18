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

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
