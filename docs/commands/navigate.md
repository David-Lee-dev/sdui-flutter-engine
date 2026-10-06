# `navigate`

The `navigate` command delegates route changes to the current engine host.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `push`, `go`, `pop` | `push` | Yes | Navigation operation. |
| `route` | string | non-empty | required for `push`/`go` | Yes | Route passed to the host; the parameter name is `route`. |
| `result` | any | — | `null` | Yes | Value passed by `pop`. |

`push` awaits the pushed page and returns its `pop` result as `$data`; when the page leaves the stack any other way (a later `go` or replace, or a navigation that overtakes it before it lands) it returns null, so the action is never left in flight. `go` and `pop` return null. A missing host callback is a no-op, but `push`/`go` still validate `route` when the callback is invoked through null-aware dispatch semantics as implemented.

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

Screen routes can select a root `_transition` when the app enables page transitions. The engine navigation handle preloads the destination before `push`/`go`, with a bounded timeout; `pop` reverses the selected effect. See [Page transitions](../transitions.md) for configuration, precedence, parameters, and iOS swipe behavior.
