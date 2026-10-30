# layout_builder

Builds its child with the space its parent offers. Since 0.9.0 (`_requires: [layout_builder_v1]`).

The child is built lazily with two variables, declared with `_provides`:

| Variable | Value |
| --- | --- |
| `max_width` | The parent's maximum width in template units (logical pixels divided by the `EngineMetrics` scale), or `null` when the width is unbounded. |
| `max_height` | The same for the height. |

Template units match every other size in the template: at scale 1.2 a 360px-wide parent gives `max_width: 300`. The child is rebuilt whenever the constraints change.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `_provides` | list of names | `max_width`, `max_height` | none | No | Declares the variables the child reads; reading one without declaring it fails compilation. |
| `_child` | widget node | — | `null` | No | The lazily built child. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

## Protocol

This widget produces the **box** layout protocol and lazily builds one box child. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: layout_builder
_provides: [max_width, max_height]
_child:
  _type: text
  value: '${max_width > 400 ? "wide" : "narrow"}'
```

Five equal tab slots whose centers a `shape` places with `at` need no measurement; use `layout_builder` when the child needs the pixel width itself:

```yaml
_type: layout_builder
_provides: [max_width]
_child:
  _type: sizedbox
  width: '${max_width / 5}'
  height: 4
  _child: { _type: container, color: '#FFFFFFFF' }
```

## Pitfalls & related

- `layout_builder` cannot report an intrinsic size. Inside `intrinsic_width` or `intrinsic_height` (at any depth in the same template) the template fails to compile. Under an app-side parent that asks for intrinsic sizes it answers `0` and logs one warning instead of failing.
- Use only the documented positional child form; `_slots` are rejected for this specification kind.
- See [collapsing_header](collapsing_header.md) for the other builder widget and `_provides`.
- Return to the [widget catalog](../README.md).
