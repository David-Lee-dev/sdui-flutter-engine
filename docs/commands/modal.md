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
| `background` | color string | engine color syntax, `none` | theme `colorScheme.surface` | Yes | Body background for `open`; `none` makes it transparent. |
| `return` | any | — | `null` | Yes | `close` result returned to the pending `open` command. |

Modal bodies are opaque by default, using the theme's `colorScheme.surface`. Bottom sheets round their top corners to radius 16; dialogs round all corners to radius 16. Set `background` on each `open` command to override the body color, or use `background: 'none'` when the template paints a fully custom transparent body.

Dialogs are capped at 90% of keyboard-adjusted height and scroll their content; bottom sheets are capped at 80% and let their template own scrolling. Missing template throws `MODAL_NOT_FOUND`; missing host/overlay throws `NO_OVERLAY`. Backdrop dismissal emits reserved `DISMISSED` and routes to `_dismiss`. `close` affects the top modal and is a no-op for an empty stack.

```yaml
_type: modal
modal: confirm_delete
variant: bottom_sheet
background: '#FFF8F0'
params: { id: '${item.id}' }
_then: { _type: set, deleted: '${data}' }
_dismiss: { _type: toast, message: Cancelled }
```

```yaml
_type: modal
modal: image_preview
background: 'none'
```

```yaml
_type: modal
method: close
return: { confirmed: true }
```
