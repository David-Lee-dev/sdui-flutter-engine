# `modal`

The `modal` command opens or closes engine-rendered modal templates on the host overlay.

| Parameter | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `method` | string | `open`, `close` | `open` | Yes | Modal operation. |
| `modal` | string | non-empty registered modal id | required for `open` | Yes | Selects a template from the host's modal template map. |
| `params` | map | — | `null` | Yes | Becomes the modal runner's root data. |
| `variant` | string | `dialog`, `bottom_sheet` | `dialog` | Yes | Any value other than `bottom_sheet` selects dialog. |
| `align` | string | resolved by modal frame | `null` | Yes | Dialog alignment hint. |
| `motion` | string | motion atom/preset, `none`, `fade` | native entrance | Yes | Replaces a bottom sheet's native slide; dialogs already fade. |
| `dismissible` | bool | — | `true` | Yes | Whether backdrop tap dismisses. |
| `return` | any | — | `null` | Yes | `close` result returned to the pending `open` command. |

Dialogs are capped at 90% of keyboard-adjusted height and scroll their content; bottom sheets are capped at 80% and let their template own scrolling. Missing template throws `MODAL_NOT_FOUND`; missing host/overlay throws `NO_OVERLAY`. Backdrop dismissal emits reserved `DISMISSED` and routes to `_dismiss`. `close` affects the top modal and is a no-op for an empty stack.

```yaml
_type: modal
modal: confirm_delete
variant: bottom_sheet
params: { id: '${item.id}' }
_then: { _type: set, deleted: '${data}' }
_dismiss: { _type: toast, message: Cancelled }
```

```yaml
_type: modal
method: close
return: { confirmed: true }
```

