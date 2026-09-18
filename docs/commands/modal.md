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

Modal bodies are opaque by default, using the theme's `colorScheme.surface`. Set `background` on each `open` command to override the body color, or use `background: 'none'` when the template paints a fully custom transparent body.

The app owns the surrounding chrome through `SduiPresentation.modal`, installed by `Sdui.initialize` or `Engine.initialize`:

```dart
Sdui.initialize(
  // Required dependencies omitted.
  presentation: const SduiPresentation(
    modal: ModalStyle(
      barrierColor: Color(0x99000000),
      borderRadius: 24,
      sheetMaxHeightFactor: 0.85,
      dialogMaxHeightFactor: 0.88,
      dialogWidthFactor: 0.92,
    ),
  ),
);
```

| Field | Default | Purpose |
| --- | --- | --- |
| `barrierColor` | `Color(0x8A000000)` | Backdrop color. |
| `borderRadius` | `16` | Body radius: top corners for sheets, all corners for dialogs. |
| `sheetMaxHeightFactor` | `0.8` | Sheet height cap as a fraction of keyboard-adjusted height. |
| `dialogMaxHeightFactor` | `0.9` | Dialog height cap as a fraction of keyboard-adjusted height. |
| `dialogWidthFactor` | `0.9` | Dialog width as a fraction of viewport width. |

Dialogs scroll their content within their configured height cap; bottom sheets let their template own scrolling. The command-level `background` still controls the body surface independently of the injected chrome. Missing template throws `MODAL_NOT_FOUND`; missing host/overlay throws `NO_OVERLAY`. Backdrop dismissal emits reserved `DISMISSED` and routes to `_dismiss`. `close` affects the top modal and is a no-op for an empty stack.

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
