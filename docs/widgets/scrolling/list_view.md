# list_view

Builds a non-lazy [ListView] from the node's already-built children. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `scroll_direction` | `axis` | horizontal, vertical | `vertical` | Yes | axis along which content scrolls. Values: horizontal \| vertical. |
| `reverse` | `flag` | — | `false` | Yes | reverses scroll/paging direction. |
| `primary` | `flag` | — | `null` | Yes | uses the route primary scroll controller when true. |
| `padding` | `edge` | — | `null` | Yes | inner spacing. |
| `physics` | `scrollPhysics` | never, bouncing, clamping, always | `null` | Yes | scroll physics. Values: never \| bouncing \| clamping \| always. |
| `keyboard_dismiss_behavior` | `keyboardDismissBehavior` | manual, on_drag | `null` | Yes | chooses whether dragging dismisses the keyboard. Values: manual \| on_drag. |
| `shrink_wrap` | `flag` | — | `false` | Yes | sizes the scroll view to its content along the scroll axis. |
| `item_extent` | `size` (scaled by EngineMetrics) | — | `null` | Yes | forces every list item to the same main-axis extent. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `hard_edge` | Yes | edge clipping behavior. Values: none \| hard_edge \| anti_alias \| anti_alias_with_save_layer. |
| `inset_end` | `flag` | — | `null` | Yes | adds the `MediaQuery` bottom padding the host passes in after the content of a vertical view: by default only when the view reaches the bottom inset of the screen; `true` always, `false` never. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: list_view
scroll_direction: horizontal
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: list_view
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
- A vertical list scrolls under the home indicator, system bar or floating tab bar and adds the host's `MediaQuery` bottom padding after its last item. Its children see no bottom padding. Without `padding` it no longer takes the top padding from the screen; the top inset is the host app's or a `safe_area`'s job. Horizontal lists are unchanged. By default it does this only while its bottom edge reaches the bottom inset of the screen, so a view above a fixed CTA, inside a centered dialog or above a bottom bar adds nothing; `inset_end: true` forces it on and `inset_end: false` off. See [Insets](../../concepts.md#insets).

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
