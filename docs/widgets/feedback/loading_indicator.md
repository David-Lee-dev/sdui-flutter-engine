# loading_indicator

Shows a branded indeterminate spinner. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `variant` | `string` | — | `staggered_dots_wave` | Yes | animation style; an unknown value falls back to a plain ring so a typo degrades rather than throws. |
| `size` | `number` | — | `24` | Yes | width and height in logical pixels. |
| `color` | `color` | — | theme primary | Yes | primary animation color. |
| `secondary_color` | `color` | — | `color` | Yes | second color; only `flickr` and `twisting_dots` use two. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: loading_indicator
variant: staggered_dots_wave
size: 20
color: '#000000'
```

```yaml
_type: loading_indicator
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
