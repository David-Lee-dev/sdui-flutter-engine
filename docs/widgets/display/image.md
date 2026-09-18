# image

Resolves an `image` node through the installed [ImageSource]. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `src` | `text` | — | `null` | Yes | media source path or URL. |
| `width` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box width. |
| `height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box height. |
| `fit` | `boxFit` | fill, contain, cover, fit_width, fit_height, none, scale_down | `null` | Yes | content fitting mode. Values: fill \| contain \| cover \| fit_width \| fit_height \| none \| scale_down. |
| `color` | `color` | — | `null` | Yes | color or tint. |
| `alignment` | `alignment` | top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right | `null` | Yes | positions the child or children within the available space. Values: top_left \| top_center \| top_right \| center_left \| center \| center_right \| bottom_left \| bottom_center \| bottom_right. |
| `color_blend_mode` | `blendMode` | src_over, src_atop, src_in, dst_in, modulate, multiply, screen, overlay, darken, lighten, color, hue, saturation, luminosity, difference, exclusion, plus, clear | `null` | Yes | operation used to blend the tint with image pixels. Values: src_over \| src_atop \| src_in \| dst_in \| modulate \| multiply \| screen \| overlay \| darken \| lighten \| color \| hue \| saturation \| luminosity \| difference \| exclusion \| plus \| clear. |
| `repeat` | `imageRepeat` | no_repeat, repeat, repeat_x, repeat_y | `null` | Yes | tiles the image along the selected axes. Values: no_repeat \| repeat \| repeat_x \| repeat_y. |
| `semantic_label` | `text` | — | `null` | Yes | accessibility label. |
| `cache_width` | `integer` | — | `null` | Yes | target decoded image width in physical pixels. |
| `cache_height` | `integer` | — | `null` | Yes | target decoded image height in physical pixels. |
| `_slots` | map of widget nodes | error, loading | `{}` | No | Named children consumed by this slot widget; positional children are rejected. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts named slots (`_slots: { error, loading }`); each slot must produce a box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: image
src: example
_slots: { error: { _type: text, value: error }, loading: { _type: text, value: loading } }
```

```yaml
_type: image
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_slots:
  error:
    _type: text
    value: Tap target
```

## Pitfalls & related

- Use `_slots` only; the validator rejects `_child` and `_children`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
