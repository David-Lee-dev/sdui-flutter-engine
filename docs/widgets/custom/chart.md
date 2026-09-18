# chart

A data-driven line, area, or bar chart.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `data` | `list` | — | `[]` | Yes | rows to plot; non-map entries are skipped. |
| `type` | `text` | area, line, bar | `area` | Yes | `area` \| `line` \| `bar`. |
| `value_key` | `text` | — | `value` | Yes | row key holding the y value. |
| `label_key` | `text` | — | `label` | Yes | row key holding the x label. |
| `height` | `size` (scaled by EngineMetrics) | — | `140` | Yes | chart height. |
| `line_color` | `color` | — | theme accent | Yes | line/bar colour. |
| `fill_color` | `color` | — | `line_color` | Yes | area gradient top colour. |
| `curved` | `flag` | — | `true` | Yes | smooths the line (`area`/`line` only). |
| `bar_width` | `number` | — | `2.5` | Yes | line thickness, or bar width in `bar`. |
| `show_dots` | `flag` | — | `false` | Yes | draws a dot on every point. |
| `selected_label` | any | — | `null` | Yes | highlights the row whose label equals this, with a filled dot and a vertical rule. |
| `show_x_labels` | `flag` | — | `true` | Yes | draws the bottom axis labels. |
| `x_label_interval` | `number` | — | auto | Yes | label every Nth row. |
| `x_label_style` | `textStyle` | — | 10pt muted | Yes | bottom axis label style. |
| `show_y_grid` | `flag` | — | `true` | Yes | draws horizontal grid lines. |
| `grid_color` | `color` | — | 10% white | Yes | grid line colour. |
| `min_y` | `number` | — | auto (`0`) | Yes | lower y bound. |
| `max_y` | `number` | — | auto | Yes | upper y bound; auto uses 115% of the positive peak, or `1` when the series is empty/non-positive. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: chart
type: area
data: '${chart_days}'
value_key: amount
label_key: day
height: 140
line_color: { .token: color.primary }
selected_label: '${selected_day}'
```

```yaml
_type: chart
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
```

## Pitfalls & related

- Use only the documented positional child form; `_slots` are rejected for this specification kind.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
