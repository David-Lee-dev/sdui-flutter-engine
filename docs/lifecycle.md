# Lifecycle hooks

`_scope._lifecycle` schedules named scope actions at five runtime moments.

## Hook schema

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `on` | string | required | `mount`, `render`, `remount`, `interval`, or `dispose`. |
| `action` | string | required | Non-empty visible action name. |
| `delay` | non-negative milliseconds | `0` | Delay before the firing; invalid values fall back to zero. |
| `every` | positive milliseconds | required for `interval` | Repetition period; rejected for every other trigger. |

```yaml
_type: column
_scope:
  _state: { data: null }
  _action:
    load:
      _type: net
      op: home
      _then: { _type: set, data: '${data}' }
    poll: { _type: net, op: status, _background: true }
  _lifecycle:
    - { 'on': mount, action: load }
    - { 'on': interval, action: poll, delay: 1000, every: 30000 }
_children:
  - { _type: text, value: '${data}' }
```

Here `op` is application vocabulary understood by the configured `NetworkClient`, not an engine-defined `net` field.

## Trigger semantics

- `mount` fires during the first dependency initialization, before layout/paint. With `_scope._skeleton`, or with a node `_skeleton` below the scope (see [Skeletons](#skeletons)), the skeleton remains until all foreground mount actions complete, for at most 8 s; otherwise mount actions are dispatched without awaiting UI presentation (deduplicated like any `handle`).
- `render` fires after the first frame.
- `remount` fires when a previously obscured scope becomes visible again or when the app returns from paused/hidden state. Visibility combines the current route with `TickerMode`, covering outer navigators and inactive shell branches.
- `interval` fires once after `delay` and then periodically every `every` while mounted. Its high-frequency engine logging is suppressed.
- `dispose` dispatches immediately before action-host invalidation as fire-and-forget work.

Timers are cancelled on disposal. Updating the lifecycle list cancels old schedules and starts the new set. Mount/render hooks therefore run again when lifecycle configuration is replaced on an existing scope; ordinary widget rebuilds do not restart them. A genuinely remounted/key-changed scope is a fresh scope and runs initial hooks again.

## Skeletons

A skeleton shows while a scope's first `mount` actions run. It is held invisible for a 300 ms grace (its space is reserved), then painted with a shimmer. A load that finishes inside the grace shows the content at once; a later one swaps the skeleton for the content as a presence swap (`_presence` on the node tunes it, `false` swaps at once). If the mount actions have not finished after 8 s, the content shows anyway in its current state and a warning is logged; the requests are not cancelled and a late response updates the content in place. `remount`, reseeds and later loads never show the skeleton again.

`_scope._skeleton` draws one tree for the whole scope. Since 0.17.0 (`_requires: [skeleton_v2]`) a node may instead carry its own `_skeleton`: the frames around it show at once and only that node shows bones. The nearest enclosing scope with a `mount` hook gates it (a scope without mount hooks passes through; a nested scope with mount hooks gates the node skeletons below it). A node built after the load, or without such a scope, shows its content directly. A scope with both `_scope._skeleton` and node skeletons below fails to compile, and so does a node `_skeleton` on a node with its own mount hooks (use `_scope._skeleton` there).

```yaml
_requires: [skeleton_v2]
_type: column
_scope:
  _state: { user: null, banner: null, items: [] }
  _action: { load: { _type: net, op: home, _then: { _type: set, user: '${data.user}', banner: '${data.banner}', items: '${data.items}' } } }
  _lifecycle: [{ 'on': mount, action: load }]
_children:
  - _type: container                      # the card frame shows at once
    padding: 20
    _child:
      _type: column
      _skeleton: true                     # derive the bones of this column
      _children:
        - { _type: text, value: 내 적립, style: { font_size: 16 } }
        - { _type: text, value: '${user.point}', style: { font_size: 28 }, _skeleton: { width: 120 } }
  - _if: '${banner != null}'              # bones while loading, collapses if absent
    _skeleton: { _type: skeleton, height: 72, radius: 14 }
    _type: image
    src: '${banner.url}'
  - _type: text                           # three bone rows in the same wrap
    value: '${item.name}'
    _loop: { _in: '${items}', _as: item, _key: '${item.id}', _wrap: { _type: column, spacing: 12 } }
    _skeleton: true
```

| `_skeleton` value | Bones |
| --- | --- |
| a map with `_type` | that tree |
| `true` | derived from the node (below) |
| `{ width }` | the derived bone of a bound text, image or icon, with that width |
| `true` or `{ count, tree }` on a `_loop` node | `count` rows (default 3) of `tree` (default: derived from the row) in a copy of the loop's `_wrap`; lazy and sliver wraps (`list`, `grid`, `sliver_list`, `sliver_grid`) fail to compile, and an interactive wrap (`reorderable`, `dismissible`, `swipe`, `spin_grid`, `auto_scroll`) becomes a plain column (a row with `scroll_direction: horizontal`) keeping only `spacing`, `main_axis_alignment`, `cross_axis_alignment` and `padding` |

Derived bones never read data: frames keep their literal props, every reserved key (`_on`, `_motion`, `_morph`, `_scope`, …) is dropped, and a text, image or icon with literal values stays as it is. A text or `rich_text` with any binding becomes one `skeleton` `of: text` with its literal `style` and `max_lines` (so `'${a}/1000원'` is one bone). A bound `image` becomes a box of its literal `width` and `height` (a circle under `clip_oval`, its literal `radius` otherwise); a bound icon name becomes a square of its `size` (24 by default). An input or action widget (`toggle`, `checkbox`, `text_field`, `slider`, `page_view`, `refresh_indicator`, `dismissible`, `scratch_card`, `video`, …) becomes one box of its literal `width` and `height`, children and all. A bound `color`, `gradient`, `opacity` or `semantics_label` is dropped. Compilation fails, naming the node, for any other bound prop, a bound image or an input or action widget without a literal size, and a nested `_if`, `_loop`, `cond` or `switch` without its own `_skeleton` (whose bones are then used).

A node `_skeleton` sits outside the node's `_if` and `_loop`, so an `_if` that turns out false after the load collapses the bones to nothing. It is a box: it fails to compile on a parent-data node (`expanded`, `flexible`, `positioned`, `positioned_fill`, `spacer`) and in a sliver position; on an app-registered widget it is skipped with a warning. The bones of one scope share one shimmer phase, which runs only while some bones are on stage.

Bones are inert, `_scope._skeleton` included: while held or shown they take no taps, drags or focus and expose nothing to screen readers. A text bone without `width` fills the parent's width (80 px when the width is unbounded) and stands for `max_lines` lines, so a frame that sizes to its content, or a text that wraps to another line count, can change size when the content swaps in; give the bone a `width` (`_skeleton: { width }`) and the text a `max_lines`.
