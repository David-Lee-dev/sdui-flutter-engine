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

A skeleton shows while a scope's first `mount` actions run. It is held invisible for a 300 ms grace (its space is reserved), then painted with the skeleton style in effect ([Skeleton style](#skeleton-style)). When the load finishes the skeleton swaps for the content as a presence swap (`_presence` on the node tunes it, `false` swaps at once): the content fades in while the slot's size goes from the skeleton's to the content's. A load inside the grace swaps the same way, so the content still fades in; the never-painted skeleton stays unpainted. If the mount actions have not finished after 8 s, the content shows anyway in its current state and a warning is logged; the requests are not cancelled and a late response updates the content in place. `remount`, reseeds and later loads never show the skeleton again.

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
        - { _type: text, value: 내 적립, style: { font_size: 16 } }   # a text bone too
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
| `{ width }` | the derived bone of a text, image or icon, with that width |
| `merge` or `{ merge: true, radius, shape, width }` (`_requires: [skeleton_merge_v1]`) | the bones derived as for `true` and laid out, but painted as one rounded box of the node's size instead (radius 8 by default; `shape: rect` or `pill`; `width` lays the bones out at that width) |
| `true` or `{ count, tree }` on a `_loop` node | `count` rows (default 3) of `tree` (default: derived from the row) in a copy of the loop's `_wrap`; lazy and sliver wraps (`list`, `grid`, `sliver_list`, `sliver_grid`) fail to compile, and an interactive wrap (`reorderable`, `dismissible`, `swipe`, `spin_grid`, `auto_scroll`) becomes a plain column (a row with `scroll_direction: horizontal`) keeping only `spacing`, `main_axis_alignment`, `cross_axis_alignment` and `padding` |

Derived bones never read data: frames (layout, padding, decoration, spacing, alignment) keep their literal props, every reserved key (`_on`, `_motion`, `_morph`, `_scope`, …) is dropped, and every display leaf becomes a bone, literal or bound. A text or `rich_text` becomes one `skeleton` `of: text` with its literal `style` and `max_lines` (so `내 적립` and `'${a}/1000원'` are one bone each). An `image` becomes a box of its literal `width` and `height` (a circle under `clip_oval`, its literal `radius` otherwise); an `icon` becomes a square of its `size` (24 by default). An input or action widget (`toggle`, `checkbox`, `text_field`, `slider`, `page_view`, `refresh_indicator`, `dismissible`, `scratch_card`, `video`, …) becomes one box of its literal `width` and `height`, children and all, keeping a literal `radius` and `shape`. A bound `color`, `gradient`, `opacity` or `semantics_label` is dropped. Compilation fails, naming the node, for any other bound prop, an image or an input or action widget without a literal size, and a nested `_if`, `_loop`, `cond` or `switch` without its own `_skeleton` (whose bones are then used).

A merged `_skeleton` (`merge`) is one box where `true` would draw many bones: its height comes from the derived layout (text styles and literal sizes), and its width too unless `width` sets it. The box is the node's own layout box, so a `positioned` child that overflows a stack does not enlarge it. It is painted by the skeleton style in effect like any bone, and grace, the 8 s limit, the swap and inertness are those of the other forms. The same derivation rules and errors apply. Compilation also fails, naming the node, without `skeleton_merge_v1` in `_requires`, for another key, `merge` other than literal `true`, a `${…}` binding, a `radius` or `width` that is not a non-negative number, a `shape` other than `rect` or `pill`, `radius` together with `shape: pill`, and on a `_loop` node; validation fails on a parent-data node.

Inside another node's derived `_skeleton` (`true`), a node with `merge` contributes its merged box to that node's bones in place of its own bones: the same box, radius, shape and `width`, the same errors. It adds no slot of its own; the ancestor's slot loads, swaps and applies the skeleton style, so the box is tinted, held and replaced with the other bones there.

A node `_skeleton` sits outside the node's `_if` and `_loop`, so an `_if` that turns out false after the load collapses the bones to nothing. It is a box: it fails to compile on a parent-data node (`expanded`, `flexible`, `positioned`, `positioned_fill`, `spacer`) and in a sliver position; on an app-registered widget it is skipped with a warning. The bones of one scope share one animation phase (breathe or shimmer at the scope's period), which runs only while some bones are on stage; a still tint runs none.

Bones are inert, `_scope._skeleton` included: while held or shown they take no taps, drags or focus and expose nothing to screen readers. A text bone without `width` fills the parent's width (80 px when the width is unbounded) and stands for `max_lines` lines, so a frame that sizes to its content, or a text that wraps to another line count, can change size when the content swaps in; give the bone a `width` (`_skeleton: { width }`) and the text a `max_lines`.

### Skeleton style

Bones are painted with one `srcATop` mask over the whole outline, so transparent layout gaps stay clear and layout is never touched. Three effects:

| `effect` | Paint |
| --- | --- |
| `tint` (default) | `base`, still. Nothing ticks. |
| `breathe` | The whole outline eases from `base` to `highlight` and back (ease in-out) once per `duration`. |
| `shimmer` | A `highlight` band padded by `base` sweeps left to right once per `duration`. |

Each skeleton animates on its own; there is no sync between scopes and no screen-space alignment. When the platform asks to reduce motion (`MediaQuery.disableAnimations`), `breathe` and `shimmer` paint `base` and run nothing.

The app sets the default through `SduiPresentation(skeleton: SkeletonStyle(...))`: `effect` (`SkeletonEffect.tint` / `breathe` / `shimmer`), `base` and `highlight` (`SkeletonPaint.color(...)` or `SkeletonPaint.gradient(...)`), and `duration`. When the app sets nothing the engine uses `tint`, base `#2C2C2C`, highlight `#4B4B4B`, 1500 ms (`shimmer` with these is the sweep of 0.18.0 and earlier).

Since `skeleton_style_v1`, any `_scope` may declare `_skeleton_style`. Every key is optional and merges key by key over the nearest outer scope's style, then the app's. It applies to that scope's `_scope._skeleton`, the node `_skeleton`s below it and nested scopes until one declares its own; sibling scopes are unaffected.

```yaml
_requires: [skeleton_style_v1]
_type: column
_scope:
  _lifecycle: [{ 'on': mount, action: load }]
  _skeleton_style: { effect: breathe, base: '#1E2016', highlight: { colors: ['#0D9EFF', '#F32DD6'] }, duration: 1800 }
```

| Key | Value |
| --- | --- |
| `effect` | `tint`, `breathe` or `shimmer` |
| `base`, `highlight` | a color (`#RGB`, `#RRGGBB`, `#AARRGGBB`) or a gradient map with at least two `colors`, as in widget props |
| `duration` | milliseconds, positive (a fraction rounds up) |

Values are literal: compilation fails, naming the scope, when `_skeleton_style` is not a map, has an unknown key, an unknown effect, a `${…}` binding, a malformed color or gradient, a duration that is not a positive number, or when the template root does not declare `skeleton_style_v1` in `_requires`.
