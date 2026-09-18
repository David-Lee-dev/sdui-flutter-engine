# `net`

The `net` command sends an application-defined request through a configured `NetworkClient`. The engine owns request routing and the result envelope, but it does not define a REST, GraphQL, or other transport vocabulary.

## Engine-owned surface

| Field | Type | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- |
| `protocol` | string | the required `networkClient` | Yes | Selects a named client from `Sdui.initialize(networkProtocols: {...})` or `Engine.initialize(networkProtocols: {...})`. The selector is not forwarded. An unknown or non-string selector throws an `ArgumentError`. |
| `_when`, `_background`, `_then`, `_error`, `_dismiss`, `_always` | common flow metadata | varies | See [Actions](../actions.md) | Compiled and consumed by the action engine; never included in the request. |

`_type` is also consumed by compilation. Every other bare field is recursively expression-resolved and passed through unchanged as `NetworkRequest.fields`. The action invocation id is supplied separately as `NetworkRequest.correlationId`.

The default client is required at initialization even when named protocols are configured:

```dart
Sdui.initialize(
  // Other required dependencies omitted.
  networkClient: graphQlClient,
  networkProtocols: {'rest': restClient},
);
```

Tests that mount the engine without the facade can import `package:sdui_engine/testing.dart` and call `installTestNetworkClient(client)`.

## Application-owned request fields

The `NetworkClient` implementation and the templates that call it share their own request vocabulary. For example, the starter kit's `RestNetworkClient` reads classic REST fields — `method`, `path`, `params` (query), `body`; these names are application vocabulary, not engine grammar:

```yaml
_type: net
protocol: rest
path: '/users/${user_id}'
params: { expand: profile }
_then: { _type: set, profile: '${data}' }
_error:
  NOT_FOUND: { _type: toast, message: User not found, variant: warn }
  _: { _type: toast, message: Could not load profile, variant: error }
```

A different client may instead define named operations (`op: user_profile` with the URL owned app-side) or GraphQL fields; the engine validates none of them. A client should report malformed application requests through `NetworkResult.errorCode` when templates need to handle the failure.

## `NetworkResult` routing

| Result | Action behavior |
| --- | --- |
| `data` with no `errorCode` | Becomes `$data` in `_then`. |
| non-null `errorCode` | Becomes `DriverError(errorCode, errorMessage)` and selects `_error[code]`, then `_error._`; `$error` contains `code`, `message`, and `data`. |
| `errorCode: NetworkResult.handledErrorCode` (`BOUNDARY_HANDLED`) | The application boundary already handled the failure. `_then` and `_error` are skipped, nothing is reported, and `_always` still runs. |

See [actions](../actions.md).
