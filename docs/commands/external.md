# External commands

External commands let an application add template-facing command types through `SduiService`/`ExternalCommand` before the engine catalog freezes.

Each service contributes commands at engine initialization. `ExternalCommand.type` is the exact template `_type`; engine-owned built-in names cannot be replaced, and the registry convention for app/platform capability is `sys_*` (a convention, not a parser-enforced prefix). Registration after freeze fails.

## Invocation contract

`run(CommandInvocation)` receives only:

| Field | Type | Description |
| --- | --- | --- |
| `params` | `Map<String, Object?>` | All bare command parameters after recursive expression resolution. |
| `event` | `Object?` | Payload that initiated the action, if any. |
| `correlationId` | `String?` | Action invocation id for telemetry/server correlation. |
| `isCancelled` | `bool` getter | Whether the owning scope has disposed; check before irreversible external work. |

It deliberately cannot access engine state, host, or registries. Return data becomes `$data` in `_then`. Throw `CommandFailure(code, message:, data:)` to select `_error[code]` (falling back to `_`) and expose `{code, message, data}` as `$error`. Throw `CommandDismissed` to run `_dismiss`. Other exceptions are unexpected and reported by the action host.

```yaml
_type: sys_share
text: '${article.url}'
_then: { _type: toast, message: Shared, variant: success }
_dismiss: { _type: toast, message: Sharing cancelled }
_error:
  NOT_AVAILABLE: { _type: toast, message: Sharing is unavailable, variant: warn }
  _: { _type: toast, message: Could not share, variant: error }
```

External commands use all common flow metadata from [Actions](../actions.md), including `_when`, handlers, `_background`, and action deduplication.

