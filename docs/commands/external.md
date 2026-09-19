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
| `onDispose(cleanup)` | `void Function()` method | Registers scope-lifetime cleanup and returns a callback that deregisters it. |

Use `onDispose` for resources that must not outlive the template scope that opened them: stream subscriptions, listeners, or platform sessions. The engine marks the invocation cancelled before running registered cleanups, so cleanup work observes `isCancelled == true`. If the resource closes normally, call the returned deregistration callback so its cleanup is not retained for later scope disposal.

`isCancelled` is a live signal for code to check; it does not itself stop work that has already crossed a platform or network boundary. `onDispose` is the corresponding release hook for work the command can actively tear down. When the engine supplies no owner lifetime, such as a bare invocation in a test, registration and the returned deregistration callback are no-ops; the command remains responsible for closing the resource itself.

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

## Telemetry

Override `ExternalCommand.measured` (default `false`) to opt into a reserved, latency-measured `command` telemetry span — the same observability the engine's own [`net`](net.md) command gets. Worth `true` for long-running work (SDK calls, uploads); the default records failures only, with no duration. `CommandObserver` reads this flag through the command's driver, so the distinction is declared by the command, never inferred from its type name.
