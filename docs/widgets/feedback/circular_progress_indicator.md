# circular_progress_indicator

Shows determinate or indeterminate circular progress. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `value` | `number` | — | `null` | Yes | progress value; null is indeterminate. |
| `color` | `color` | — | `null` | Yes | indicator color. |
| `background_color` | `color` | — | `null` | Yes | track color. |
| `stroke_width` | `number` | — | `4.0` | Yes | ring stroke width. |
| `stroke_cap` | `string` | `butt`, `round`, `square` | `null` | Yes | Line ends for determinate and indeterminate progress. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

Missing, null, unknown, or non-string `stroke_cap` uses Flutter's default
without reporting an error. Optional `_requires: [progress_stroke_cap_v1]`
rejects engines before 0.26.0; without it, older engines ignore the property.
The feature is declare-only, so using the property without `_requires` compiles.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: circular_progress_indicator
value: 0.6
color: '#336699'
background_color: '#eeeeee'
stroke_width: 4
stroke_cap: round
```

```yaml
_type: circular_progress_indicator
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
