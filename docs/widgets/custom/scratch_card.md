# scratch_card

Reveals its first child as the user rubs the second away.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `reset_token` | any | — | `null` | Yes | changing it wipes the scratched area and re-arms `on_threshold`, for reusing one card across rounds. |
| `brush_size` | `size`, scaled | — | `40` | Yes | diameter erased around the touch point. |
| `threshold` | `integer` | — | `80` | Yes | percent cleared that fires `on_threshold`. |
| `haptic` | `flag` | — | `false` | Yes | light tick every 10% of progress. |
| `on_changed` | `text` | — | `null` | Yes | action dispatched with the integer percent, once per whole percent. |
| `on_threshold` | `text` | — | `null` | Yes | action dispatched once, when `threshold` is first reached. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: scratch_card
threshold: 80
on_changed: sync_percent
on_threshold: claim
_children:
  - { _type: text, value: 3등 }
  - { _type: container, decoration: { color: '#CBCBCB' } }
```

```yaml
_type: scratch_card
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_children:
  - _type: text
    value: Tap target
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
