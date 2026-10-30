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

- `mount` fires during the first dependency initialization, before layout/paint. With a map `_scope._skeleton`, the skeleton remains until all foreground mount actions complete; with `_skeleton: auto`, each node reveals when the state it reads is first written (see [automatic skeleton](#automatic-skeleton)); without a skeleton, mount actions are dispatched without awaiting UI presentation.
- `render` fires after the first frame.
- `remount` fires when a previously obscured scope becomes visible again or when the app returns from paused/hidden state. Visibility combines the current route with `TickerMode`, covering outer navigators and inactive shell branches.
- `interval` fires once after `delay` and then periodically every `every` while mounted. Its high-frequency engine logging is suppressed.
- `dispose` dispatches immediately before action-host invalidation as fire-and-forget work.

Timers are cancelled on disposal. Updating the lifecycle list cancels old schedules and starts the new set. Mount/render hooks therefore run again when lifecycle configuration is replaced on an existing scope; ordinary widget rebuilds do not restart them. A genuinely remounted/key-changed scope is a fresh scope and runs initial hooks again.

## Automatic skeleton

`_scope._skeleton` is omitted, `auto`, or a map. A map is a hand-drawn tree shown in place of the scope until every mount action settles. Any other value fails compilation (engines up to 0.13 reject `auto`, so gate migrated templates by app version).

```yaml
_type: column
_scope:
  _state: { partners: null }
  _action:
    load_partners:
      _type: net
      op: partners
      _then: { _type: set, partners: '${data}' }
  _lifecycle:
    - { 'on': mount, action: load_partners }
  _skeleton: auto
_children:
  - { _type: text, value: 'Partners' }            # static: drawn at once
  - _type: text
    value: '${item.name}'
    _loop: { _in: '${partners}', _key: '${item.id}', _skeleton: 9 }
```

With `auto` the real tree is the skeleton:

- **Awaited keys.** The keys written by `set` commands anywhere in the flows (`_then`, `_error`, `_dismiss`, `_always`, nested) of the scope's `mount` hooks wait, on the scope that defines each action — a mount hook naming an ancestor's action waits on the ancestor's state. Keys written by other drivers are not inferred; nodes reading them render as usual.
- **Release.** A key stops waiting on its first write by an action, even with an equal value — so a mount flow whose first step `set`s an awaited key releases it at once. A template reseed does not release it. Several automatic skeletons whose mount hooks write the same key of a shared owner scope wait on that one key and reveal together on its first write. When a mount hook settles (success, failure, or skipped by `_when`) its remaining keys are released, and so are they when the scope is disposed first. If the mount hooks have not all settled 15 seconds after the scope's lifecycle starts (after any outer automatic skeleton it waits on), every remaining key is released and nested scopes start, with a debug warning. A released key never waits again, so `remount`, reload, and paging keep showing content.
- **Pending nodes.** A node inside a `_skeleton: auto` scope (including its stand-in loop rows) is pending while one of its props reads a waiting key (event payloads and motion parameters do not count). A node outside every automatic skeleton ignores waiting keys and renders as usual, even when it reads the same key — for example a header above a section whose scope loads its parent's `partners`. Layout keeps the real geometry: text lays out placeholder words in its real style — literal fragments and line breaks are kept, and text whose lines come from data spans `max_lines` lines (or one) — icons keep their `size`, images their `width`/`height` (an unsized image logs a debug warning), and a prop that fails to evaluate on missing data is dropped alone. A pending content leaf paints rounded bones (one per text line, a circle for icons) instead of its content and is hidden from accessibility; `_on` events and `_motion` are attached only once it reveals. Layout nodes draw their own children.
- **Input.** As with a hand-drawn skeleton, nothing waiting can be operated: a node inside a `_skeleton: auto` scope ignores pointers (with its subtree) while any of its bindings — props, `_on` event payloads or `_motion` parameters — reads a waiting key, even when it is drawn for real because its props do not wait. It accepts input from the first frame the key is released.
- **Branches.** A `cond` or `switch` whose predicate waits shows the first branch that reads a waiting key, else the fallback, else nothing.
- **Loops.** A loop over a waiting source draws stand-in rows from its row template; see [loops](loops.md#automatic-skeleton-rows).
- **Nested scopes.** A scope inside a still-loading automatic skeleton starts its lifecycle after the outer scope's mount hooks settle, keeping the parent-then-child order of a hand-drawn skeleton. Until it starts, returning from background does not fire its `remount`. A nested `_skeleton: auto` scope that pends a key of an ancestor scope marks it when it first builds, so a node reading that key built earlier may show its content for one frame before turning into a bone.
- **Timing.** Bones stay unpainted for 300 ms after the scope mounts, so data arriving within it never shows a bone. Later, all bones of the scope share one shimmer sweep aligned to the scope's box, and a revealing node fades its bones out over 250 ms above its real content without remounting. With reduced motion, bones are static and reveal at once.
