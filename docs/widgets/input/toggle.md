# toggle

Builds a controlled Flutter [Switch] using the engine's truthiness rules. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `enabled` | `flag` | — | `true` | Yes | whether interaction is enabled. |
| `semantics_label` | `text` | — | `null` | Yes | accessibility label. |
| `active_color` | `color` | — | `null` | Yes | color used for the selected or active state. |
| `active_track_color` | `color` | — | `null` | Yes | track color while the switch is on. |
| `inactive_thumb_color` | `color` | — | `null` | Yes | thumb color while the switch is off. |
| `inactive_track_color` | `color` | — | `null` | Yes | track color while the switch is off. |
| `bind` | state key | Declared writable state key | `null` | No | Reads the controlled value and writes changes to the nearest scope declaring this key. |
| `_on` | event map | tap, double_tap, long_press, change, submit, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts no children. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: toggle
_scope:
  _state: { state_key: null }
  _action:
    change_action:
      _type: toast
      message: Input updated
    submit_action:
      _type: toast
      message: Input updated
enabled: true
bind: state_key
_on: { change: change_action, submit: submit_action }
```

```yaml
_type: toggle
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

- This is a bound input: children and slots are rejected, and a literal `bind` must name writable state declared by an enclosing `_scope` or root data.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
