# swipe_pane

A swipe area bound to its `swipe_layout`'s [SwipeController].

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `controller` | `text` | — | `null` | Yes | optional `swipe_layout` id; omit it to use the nearest layout. |
| `scroll_direction` | `axis` | horizontal, vertical | `horizontal` | Yes | axis along which content scrolls. Values: horizontal \| vertical. |
| `viewport_fraction` | `number` | — | `1.0` | Yes | fraction of the viewport each page occupies (1.0 = full width). |
| `reverse` | `flag` | — | `false` | Yes | reverses scroll/paging direction. |
| `physics` | `scrollPhysics` | never, bouncing, clamping, always | `null` | Yes | scroll physics. Values: never \| bouncing \| clamping \| always. |
| `page_snapping` | `flag` | — | `true` | Yes | snaps scrolling to whole-page boundaries. |
| `pad_ends` | `flag` | — | `true` | Yes | centers the first and last page when pages are narrower than the viewport. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: swipe_pane
controller: example
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: swipe_pane
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
