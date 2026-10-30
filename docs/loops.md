# Loops

`_loop` repeats one widget node over a list, creates readable item/index frames, and packages the results with one of 14 fixed wrapper strategies.

## Schema

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `_in` | expression or recursively bindable literal | none | Non-list values produce no items. Strings in this position must be a whole `${…}` expression. |
| `_as` | identifier | `item` | Read-only item binding. |
| `_index` | identifier | `index` | Read-only zero-based index binding. |
| `_key` | non-empty whole expression string | required | Must evaluate per item to a unique string or finite number. |
| `_wrap` | strategy string or `{_type: strategy, ...params}` | `column` | Wrapper and bindable wrapper parameters. |

```yaml
_type: text
value: '${product.name}'
_loop:
  _in: '${products}'
  _as: product
  _index: position
  _key: '${product.id}'
  _wrap:
    _type: list
    padding: 16
    shrink_wrap: true
```

`_loop` is a widget-node directive, not a standalone node. Keys are used for `ValueKey` reconciliation and lazy child-index lookup; duplicates and non-scalar keys fail at runtime rather than silently losing identity.

## Wrapper strategies

| Strategy | Build mode | Protocol | Parameters/behavior |
| --- | --- | --- | --- |
| `column` | eager | box | Catalog `column`; forces `main_axis_size: min` unless overridden. |
| `row` | eager | box | Catalog `row`; also defaults `main_axis_size: min`. |
| `wrap` | eager | box | Catalog `wrap`; forwards wrapper params. |
| `serpentine` | eager | box | Catalog custom widget; forwards all documented serpentine params. |
| `serpentine_row` | eager | box | Catalog custom row. |
| `spin_grid` | eager/action-aware | box | Catalog spin grid, with action host for `on_finish`. |
| `auto_scroll` | eager | box | Catalog auto-scroll widget. |
| `swipe` | eager/action-aware | box | Builds `swipe_layout` + `swipe_pane`; length is resolved item count and params configure both. |
| `list` | lazy builder | box | `scroll_direction`, `reverse`, `padding`, `physics`, `shrink_wrap`. |
| `sliver_list` | lazy builder | sliver | Sliver child delegate with stable key lookup. |
| `grid` | lazy builder | box | `cross_axis_count` (min 1, default 2), `main_axis_spacing`, `cross_axis_spacing`, `child_aspect_ratio` (default 1), `padding`, `physics`, `shrink_wrap`. |
| `sliver_grid` | lazy builder | sliver | Same grid delegate parameters, no padding/physics/shrink-wrap container params. |
| `reorderable` | lazy/mutating | box | `scroll_direction`, `padding`, `shrink_wrap`; reorders the source list. |
| `dismissible` | lazy/mutating | box | `scroll_direction`, `padding`, `shrink_wrap`, `direction` (default `horizontal`); removes the dismissed item. |

These are the validator's complete accepted names. `box`, `data`, `event`, and `set` are not loop wrappers; they belong to other concepts.

## Mutation and constraints

`reorderable` and `dismissible` write a copied list back to the wrapper parameter `bind` when supplied, otherwise to `_in` only when `_in` is a bare binding such as `${items}`. Computed/path sources have no inferred write target and therefore display but do not mutate state. The target must resolve through the nearest declaring scope.

Every repeated item must produce a box, including inside sliver wrappers. The wrapper's own protocol must match its parent. Use `sliver_list`/`sliver_grid` only inside a sliver viewport; use the box strategies at the engine root or inside box parents.

