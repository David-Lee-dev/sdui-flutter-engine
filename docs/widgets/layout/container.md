# container

Builds Flutter's [Container] from resolved box props. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `decoration` | `boxDecoration` | — | `null` | Yes | paints the box or field decoration. |
| `width` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box width. |
| `height` | `size` (scaled by EngineMetrics) | — | `null` | Yes | sets the box height. |
| `padding` | `edge` | — | `null` | Yes | inner spacing. |
| `margin` | `edge` | — | `null` | Yes | outer spacing. |
| `alignment` | `alignment` | top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right | `null` | Yes | positions the child or children within the available space. Values: top_left \| top_center \| top_right \| center_left \| center \| center_right \| bottom_left \| bottom_center \| bottom_right. |
| `constraints` | `constraints` | — | `null` | Yes | minimum and maximum dimensions imposed on the child. |
| `color` | `color` | — | `null` | Yes | color or tint. |
| `foreground_decoration` | `boxDecoration` | — | `null` | Yes | paints a decoration in front of the child. |
| `transform` | `matrix4` | — | `null` | Yes | matrix applied before painting the container. |
| `transform_alignment` | `alignment` | top_left, top_center, top_right, center_left, center, center_right, bottom_left, bottom_center, bottom_right | `null` | Yes | origin alignment for the container transform. Values: top_left \| top_center \| top_right \| center_left \| center \| center_right \| bottom_left \| bottom_center \| bottom_right. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `none` | Yes | edge clipping behavior. Values: none \| hard_edge \| anti_alias \| anti_alias_with_save_layer. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: container
decoration: example
_child: { _type: text, value: hi }
```

```yaml
_type: container
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
