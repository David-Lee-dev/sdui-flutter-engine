# dropdown

Builds a controlled dropdown from scalar value/label options. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `options` | `list<{value, label}>` | — | `[]` | Yes | available scalar options. |
| `enabled` | `flag` | — | `true` | Yes | whether interaction is enabled. |
| `hint` | `text` | — | `null` | Yes | placeholder shown without a selection. |
| `is_expanded` | `flag` | — | `false` | Yes | expands to available width. |
| `bind` | state key | Declared writable state key | `null` | No | Reads the controlled value and writes changes to the nearest scope declaring this key. |
| `_on` | event map | tap, double_tap, long_press, change, submit, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts no children. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: dropdown
_scope:
  _state: { country: null }
  _action:
    select_country:
      _type: toast
      message: Input updated
bind: country
options: [{ value: kr, label: Korea }, { value: us, label: USA }]
hint: Choose a country
is_expanded: true
_on: { change: select_country }
```

```yaml
_type: dropdown
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
