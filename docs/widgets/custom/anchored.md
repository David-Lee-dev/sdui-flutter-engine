# anchored

Places its child against the anchor of the `anchored_overlay` it is in.

The child keeps its own size and sits at the anchor's current on-screen rect, scroll offset included: `over` it, or `above`, `below`, before (`start`) or after (`end`) it, `gap` away. `align` lines the child up with the anchor across that side (both axes for `over`). `start` and `end` follow the text direction. The anchor is measured after layout, and again after each frame, so the child follows it if it moves beneath the layer. While the anchor is not mounted the child is not drawn, hit or announced to screen readers. Outside an `anchored_overlay` the node draws nothing.

Since 0.22.0. Declare `_requires: [anchored_overlay_v1]`.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `placement` | `text` | over \| above \| below \| start \| end | `'over'` | Yes | side of the anchor the child sits on. |
| `align` | `text` | start \| center \| end | `'center'` | Yes | how the child lines up with the anchor across that side. |
| `gap` | `offset` | — | `0.0` | Yes | distance between the anchor and the child; unused for `over`. |
| `_child` | widget node | — | `null` | No | The placed content. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol and fills the overlay layer; its child is laid out loosely in it. See [Concepts](../../concepts.md#box-and-sliver-protocols).

## Examples

```yaml
_type: anchored
placement: below
align: start
gap: 8
_child: { _type: text, value: hi }
```

## Pitfalls & related

- Put `_motion` and `_on` on the child: the `anchored` node itself fills the layer, so a scale or tap on it applies to the whole layer.
- To highlight the anchor, draw it again with `placement: over`; the template decides what is drawn there.
- See [`anchored_overlay`](anchored_overlay.md) and [`anchor`](anchor.md).
- Return to the [widget catalog](../README.md).
