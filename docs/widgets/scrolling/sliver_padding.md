# sliver_padding

Adds resolved padding around the node's first sliver child. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `padding` | `edge` | — | `EdgeInsets.zero` | Yes | inner spacing. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **sliver** layout protocol. Its positional children must produce sliver. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_padding
    padding: example
    _child: { _type: sliver_list, _children: [{ _type: text, value: hi }] }
```

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_padding
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
      _type: sliver_to_box_adapter
      _child: { _type: text, value: Tap target }
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.
- A sliver cannot be mounted at the engine root or under a box parent; place it in `custom_scroll_view` or another sliver parent.
- Every positional child must produce a sliver; adapt box content with `sliver_to_box_adapter`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
