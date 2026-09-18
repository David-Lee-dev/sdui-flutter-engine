# nested_body (internal)

`nested_body` is an internal helper used by `nested_scroll_view`; no template `_type` is registered for it.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `overlap` | flag | — | `true` | Yes | Applies the nested overlap injector when true. |
| `_child` | widget node | — | `null` | No | Internal box child. |

## Protocol

The helper produces a box and consumes one box child. It cannot host `_loop` and cannot be used as a `_wrap` target because it is absent from `WidgetFactory`.

## Examples

Templates must use the public composition instead:

```yaml
_type: nested_scroll_view
_children:
  - _type: sliver_app_bar
    _slots:
      title: { _type: text, value: Example }
  - _type: list_view
    _children:
      - _type: text
        value: Body
```

```yaml
_type: custom_scroll_view
_children:
  - _type: sliver_to_box_adapter
    _child: { _type: text, value: Public alternative }
```

## Pitfalls & related

- `_type: nested_body` fails catalog validation as an unknown widget.
- Use [nested_scroll_view](../scrolling/nested_scroll_view.md); return to the [widget catalog](../README.md).
