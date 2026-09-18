# collapsing_header

Builds a [SliverPersistentHeader] whose child receives scroll-state variables.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box height. |
| `max_extent` | `size` (scaled by EngineMetrics) | — | `height ?? 56.0` | Yes | largest height of the persistent header. |
| `min_extent` | `size` (scaled by EngineMetrics) | — | `height ?? maxExtent` | Yes | smallest height of the persistent header. |
| `pinned` | `flag` | — | `false` | Yes | keeps the header visible at its minimum extent. |
| `floating` | `flag` | — | `false` | Yes | reveals the header as soon as scrolling reverses. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **sliver** layout protocol. It lazily builds its positional child, which must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: custom_scroll_view
_children:
  - _type: collapsing_header
    height: 1
    _child: { _type: text, value: progress }
```

```yaml
_type: custom_scroll_view
_children:
  - _type: collapsing_header
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
- A sliver cannot be mounted at the engine root or under a box parent; place it in `custom_scroll_view` or another sliver parent.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
