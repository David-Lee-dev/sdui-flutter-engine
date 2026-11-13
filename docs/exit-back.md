# Exit back

Since 0.28.0 a template can react to an Android system back that would close the app. The engine only detects that moment and exposes it as the [lifecycle](lifecycle.md) trigger `exit_back`; what happens next — a confirm bottom sheet, a toast, nothing — is template behavior built from ordinary commands. The engine never opens a modal or decides the UX itself.

## Template usage

Declare `lifecycle_exit_back_v1` in the root `_requires` and add an `exit_back` hook to a scope:

```yaml
_requires: [lifecycle_exit_back_v1]
_type: column
_scope:
  _action:
    confirm_exit:
      _type: modal
      modal: exit_confirm
      variant: bottom_sheet
      _then: { _type: sys_exit_app, _when: '${data.confirmed}' }
  _lifecycle:
    - { 'on': exit_back, action: confirm_exit }
_children:
  - { _type: text, value: Home }
```

A template that uses `exit_back` without `lifecycle_exit_back_v1` fails compilation, so it cannot silently lose the hook on an engine that predates it. `delay` works as for `remount`/`dispose`; `every` is rejected.

The hook action runs with the action origin `exit_back`. While its foreground flow is still running — for example the bottom sheet is still open — another exit back is deduplicated by the action's `_dedupe` (default `true`), and that back is still consumed.

## When it fires

`Sdui.router` installs a root back dispatcher that first runs the normal back flow:

1. child back dispatchers,
2. the go_router delegate: nested shell and root navigators pop their top route,
3. `PopScope(canPop: false)` blocks the pop,
4. a go_router `onExit` that returns `false` vetoes leaving the route.

If any of these handles the back, no hook fires. Only when nothing handled it — the moment Flutter would call `SystemNavigator.pop` — the dispatcher fires the `exit_back` hooks of every scope that is currently visible and not exiting, and keeps the app open. Visible means the same as for `remount`: the scope's route is current and its `TickerMode` is enabled, so a scope on an inactive shell branch or under a route pushed on an outer navigator does not fire. A disposed scope no longer counts.

When no visible scope declares `exit_back`, the back stays unhandled and Flutter closes the app exactly as before. Templates without `exit_back` therefore behave as they always did.

## Closing the app after a confirmation

The engine has no command that closes the app. A template that wants to exit after the user confirms needs an app-provided [external command](commands/external.md), e.g. a `sys_exit_app` that calls `SystemNavigator.pop()`. In the example above, the `exit_confirm` modal closes with `method: close, return: { confirmed: true }` on confirm. The `_then` receives that result as `${data}`, so `_when: '${data.confirmed}'` exits only on confirm. A cancel, a backdrop dismissal, or a close without `confirmed` leaves the app open.

## Android 13+ and predictive back

On Android 13 and later the OS delivers a back to Flutter only while the app reports `SystemNavigator.setFrameworkHandlesBack(true)`. Flutter reports `false` when the root navigator cannot pop, and then the OS closes the app without Flutter — or any `exit_back` hook — ever seeing the back.

An app whose templates use `exit_back` must keep reporting `true`, typically from `MaterialApp.router`'s `onNavigationNotification`:

```dart
MaterialApp.router(
  routerConfig: Sdui.router(),
  onNavigationNotification: (notification) {
    SystemNavigator.setFrameworkHandlesBack(true);
    return true;
  },
);
```

The engine does not change this signal. Keeping it `true` also turns off the OS predictive "back to home" animation at the root, since Flutter now decides the exit.
