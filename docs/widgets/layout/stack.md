# stack

Builds Flutter's [Stack] from the node's children. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `alignment` | `alignment` | top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right | `AlignmentDirectional.topStart` | Yes | positions the child or children within the available space. Values: top_left \| top_center \| top_right \| center_left \| center \| center_right \| bottom_left \| bottom_center \| bottom_right. |
| `text_direction` | `textDirection` | ltr, rtl | `null` | Yes | resolves start/end ordering and alignment. Values: ltr \| rtl. |
| `fit` | `stackFit` | loose, expand, passthrough | `loose` | Yes | content fitting mode. Values: loose \| expand \| passthrough. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `hard_edge` | Yes | edge clipping behavior. Values: none \| hard_edge \| anti_alias \| anti_alias_with_save_layer. |
| `_children` | list of widget nodes | — | `[]` | No | Positional children; cannot be combined with `_child` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: stack
alignment: top_left
_children:
  - { _type: text, value: a }
  - { _type: text, value: b }
```

```yaml
_type: stack
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
