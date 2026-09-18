# radio

Builds one controlled radio option from the bound engine value. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `value` | `scalar` | — | `null` | Yes | this option's value. |
| `enabled` | `flag` | — | `true` | Yes | whether interaction is enabled. |
| `active_color` | `color` | — | `null` | Yes | selected radio color. |
| `bind` | state key | Declared writable state key | `null` | No | Reads the controlled value and writes changes to the nearest scope declaring this key. |
| `_on` | event map | tap, double_tap, long_press, change, submit, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts no children. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: radio
_scope:
  _state: { plan: null }
  _action:
    select_plan:
      _type: toast
      message: Input updated
bind: plan
value: pro
enabled: true
active_color: '#336699'
_on: { change: select_plan }
```

```yaml
_type: radio
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
