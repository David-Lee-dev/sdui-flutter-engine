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

- `mount` fires during the first dependency initialization, before layout/paint. With `_scope._skeleton`, the skeleton remains until all foreground mount actions complete; without a skeleton, mount actions are dispatched without awaiting UI presentation.
- `render` fires after the first frame.
- `remount` fires when a previously obscured scope becomes visible again or when the app returns from paused/hidden state. Visibility combines the current route with `TickerMode`, covering outer navigators and inactive shell branches.
- `interval` fires once after `delay` and then periodically every `every` while mounted. Its high-frequency engine logging is suppressed.
- `dispose` dispatches immediately before action-host invalidation as fire-and-forget work.

Timers are cancelled on disposal. Updating the lifecycle list cancels old schedules and starts the new set. Mount/render hooks therefore run again when lifecycle configuration is replaced on an existing scope; ordinary widget rebuilds do not restart them. A genuinely remounted/key-changed scope is a fresh scope and runs initial hooks again.
