# `set`

The `set` command atomically commits all resolved bare parameters to the state of the scope that defines the action.

Every bare parameter name is a target state key, every value is recursively expression-bindable, and there are no driver-specific metadata fields beyond the common command metadata.

```yaml
_type: set
loading: true
page: '${page + 1}'
filters: '${set_path(filters, ["active"], true)}'
```

Validation rejects a target not declared in that defining scope's `_state`. Unlike `bind`, `set` does not walk to an outer declaring scope. The driver returns null. See [state](../state.md) and [actions](../actions.md).
