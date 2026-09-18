# list_tile

Arranges leading, title, subtitle, and trailing named slots. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `dense` | `flag` | — | `null` | Yes | uses a compact vertical layout. |
| `selected` | `flag` | — | `false` | Yes | paints the selected state. |
| `enabled` | `flag` | — | `true` | Yes | paints the enabled state. |
| `content_padding` | `edge` | — | `null` | Yes | interior padding. |
| `three_line` | `flag` | — | `false` | Yes | reserves three text lines. |
| `_slots` | map of widget nodes | leading, title, subtitle, trailing | `{}` | No | Named children consumed by this slot widget; positional children are rejected. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts named slots (`_slots: { leading, title, subtitle, trailing }`); each slot must produce a box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: list_tile
dense: true
selected: false
content_padding: [16, 8]
_slots:
  leading: { _type: icon, name: person }
  title: { _type: text, value: Account }
  subtitle: { _type: text, value: Profile settings }
  trailing: { _type: icon, name: chevron_right }
```

```yaml
_type: list_tile
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
  leading:
    _type: text
    value: Tap target
```

## Pitfalls & related

- Use `_slots` only; the validator rejects `_child` and `_children`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
