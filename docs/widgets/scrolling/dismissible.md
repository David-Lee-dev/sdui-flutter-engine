# dismissible

Builds a [Dismissible] that dispatches the configured dismissal action. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `on_dismissed` | `text` | — | `null` | Yes | action dispatched after dismissal. |
| `key` | `text` | — | `'_dismissible'` | Yes | stable identity used by the dismissible widget. |
| `direction` | `dismissDirection` | horizontal, vertical, end_to_start, start_to_end, up, down, none | `DismissDirection.horizontal` | Yes | selects the layout or dismissal axis. Values: horizontal \| vertical \| end_to_start \| start_to_end \| up \| down \| none. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. The name `dismissible` is also a recognized `_loop._wrap` strategy. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: dismissible
on_dismissed: example
_child: { _type: text, value: hi }
```

```yaml
_type: dismissible
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
_child:
  _type: text
  value: Tap target
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
