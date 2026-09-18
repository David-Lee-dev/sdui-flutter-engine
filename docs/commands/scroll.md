# `scroll`

The `scroll` command reveals a mounted [`anchor`](../widgets/custom/anchor.md) with `Scrollable.ensureVisible`.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `anchor` | string | non-empty | required | Yes | Registered anchor id. |
| `alignment` | number | normally 0–1 | `0.5` | Yes | Viewport alignment forwarded without clamping. |
| `duration` | number | milliseconds | `300` | Yes | Converted to integer milliseconds. |

The curve is fixed to Flutter `easeInOut`. Missing registries, ids, or unmounted targets are benign no-ops.

```yaml
_type: scroll
anchor: checkout
alignment: 0
duration: 450
```

```yaml
_type: scroll
anchor: '${event.target}'
```

