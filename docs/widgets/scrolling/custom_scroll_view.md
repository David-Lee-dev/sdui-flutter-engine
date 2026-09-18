# custom_scroll_view

Builds a [CustomScrollView] from children that are already slivers. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `scroll_direction` | `axis` | horizontal, vertical | `vertical` | Yes | axis along which content scrolls. Values: horizontal \| vertical. |
| `reverse` | `flag` | — | `false` | Yes | reverses scroll/paging direction. |
| `primary` | `flag` | — | `null` | Yes | uses the route primary scroll controller when true. |
| `physics` | `scrollPhysics` | never, bouncing, clamping, always | `null` | Yes | scroll physics. Values: never \| bouncing \| clamping \| always. |
| `keyboard_dismiss_behavior` | `keyboardDismissBehavior` | manual, on_drag | `null` | Yes | chooses whether dragging dismisses the keyboard. Values: manual \| on_drag. |
| `shrink_wrap` | `flag` | — | `false` | Yes | sizes the scroll view to its content along the scroll axis. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `hard_edge` | Yes | edge clipping behavior. Values: none \| hard_edge \| anti_alias \| anti_alias_with_save_layer. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce sliver. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: custom_scroll_view
scroll_direction: horizontal
_children:
  - { _type: sliver_list, _children: [{ _type: text, value: a }] }
  - { _type: sliver_fill_remaining, _child: { _type: text, value: b } }
```

```yaml
_type: custom_scroll_view
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
  - _type: sliver_to_box_adapter
    _child: { _type: text, value: Tap target }
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.
- Every positional child must produce a sliver; adapt box content with `sliver_to_box_adapter`.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
