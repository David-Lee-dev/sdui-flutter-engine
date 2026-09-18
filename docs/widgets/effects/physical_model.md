# physical_model

Clips and elevates its child as a physical shape. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `color` | `color` | — | `transparent` | Yes | surface color. |
| `shadow_color` | `color` | — | `black` | Yes | elevation shadow color. |
| `elevation` | `number` | — | `0.0` | Yes | z elevation. |
| `border_radius` | `radius` | — | `zero` | Yes | rectangular corner radius. |
| `shape` | `boxShape` | rectangle, circle | `rectangle` | Yes | rectangle or circle. |
| `clip_behavior` | `clip` | none, hard_edge, anti_alias, anti_alias_with_save_layer | `none` | Yes | child clipping behavior. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: physical_model
color: '#ffffff'
elevation: 4
border_radius: 12
clip_behavior: anti_alias
_child: { _type: text, value: Card }
```

```yaml
_type: physical_model
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
