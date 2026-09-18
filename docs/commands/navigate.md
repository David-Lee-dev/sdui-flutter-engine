# `navigate`

The `navigate` command delegates route changes to the current engine host.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `push`, `go`, `pop` | `push` | Yes | Navigation operation. |
| `route` | string | non-empty | required for `push`/`go` | Yes | Route passed to the host; the parameter name is `route`. |
| `result` | any | — | `null` | Yes | Value passed by `pop`. |

`push` awaits and returns the host result as `$data`; `go` and `pop` return null. A missing host callback is a no-op, but `push`/`go` still validate `route` when the callback is invoked through null-aware dispatch semantics as implemented.

```yaml
_type: navigate
method: push
route: '/product/${product.id}'
_then: { _type: set, child_result: '${data}' }
```

```yaml
_type: navigate
method: pop
result: { saved: true }
```

