# text_field

Builds a controlled [TextField] synchronized with the bound engine value. This primitive mirrors the corresponding Flutter widget described by its implementation.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `input_type` | `text` | text, number, phone, email, multiline, url | `text` | Yes | keyboard type + input formatting. Values: text \| number \| phone \| email \| multiline \| url. |
| `decoration` | `inputDecoration` | — | `empty decoration` | Yes | paints the box or field decoration. |
| `hint_text` | `text` | — | `base.hintText` | Yes | placeholder shown while the field is empty. |
| `error_text` | `text` | — | `base.errorText` | Yes | error message shown by the field decoration. |
| `id` | `text` | — | `null` | Yes | identifier used to register or connect the widget. |
| `obscure_text` | `flag` | — | `false` | Yes | masks entered characters. |
| `max_lines` | `integer` | — | `null` | Yes | maximum number of displayed or editable lines. |
| `enabled` | `flag` | — | `true` | Yes | whether interaction is enabled. |
| `read_only` | `flag` | — | `false` | Yes | allows selection without permitting edits. |
| `semantics_label` | `text` | — | `null` | Yes | accessibility label. |
| `max_length` | `integer` | — | `null` | Yes | maximum number of input characters. |
| `text_input_action` | `textInputAction` | next, done, search, send, go, previous, newline, continue_action | `null` | Yes | action button displayed by the software keyboard. Values: next \| done \| search \| send \| go \| previous \| newline \| continue_action. |
| `text_capitalization` | `textCapitalization` | none, words, sentences, characters | `none` | Yes | capitalization behavior requested from the keyboard. Values: none \| words \| sentences \| characters. |
| `min_lines` | `integer` | — | `null` | Yes | minimum number of editable lines. |
| `text_align` | `textAlign` | left, right, center, justify, start, end | `start` | Yes | horizontal alignment of text within each line. Values: left \| right \| center \| justify \| start \| end. |
| `autofocus` | `flag` | — | `false` | Yes | requests focus when the field first appears. |
| `style` | `textStyle` | — | `null` | Yes | text style of the entered text. |
| `text_align_vertical` | `textAlignVertical` | top, center, bottom | `null` | Yes | vertical alignment of text within the field. Values: top \| center \| bottom. |
| `cursor_color` | `color` | — | `null` | Yes | color of the text cursor. |
| `cursor_width` | `size` | — | `2.0` | Yes | width of the text cursor. |
| `cursor_height` | `size` | — | `null` | Yes | height of the text cursor. |
| `cursor_radius` | `size` | — | `null` | Yes | corner radius of the text cursor. |
| `keyboard_appearance` | `brightness` | light, dark | `null` | Yes | keyboard brightness. Values: light \| dark. |
| `autocorrect` | `flag` | — | `true` | Yes | requests autocorrect from the keyboard. |
| `enable_suggestions` | `flag` | — | `true` | Yes | requests input suggestions from the keyboard. |
| `expands` | `flag` | — | `false` | Yes | fills the available vertical space; only takes effect when the effective `max_lines`/`min_lines` are both unset (e.g. `input_type: multiline` without them), since Flutter forbids combining `expands` with either. |
| `bind` | state key | Declared writable state key | `null` | No | Reads the controlled value and writes changes to the nearest scope declaring this key. |
| `_on` | event map | tap, double_tap, long_press, change, submit, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

All non-structural property values are recursively expression-bindable. Structural keys control compilation and therefore are not themselves interpolated.

## Protocol

This widget produces the **box** layout protocol. It accepts no children. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

```yaml
_type: text_field
_scope:
  _state: { state_key: null }
  _action:
    change_action:
      _type: toast
      message: Input updated
    submit_action:
      _type: toast
      message: Input updated
input_type: text
bind: state_key
_on: { change: change_action, submit: submit_action }
```

```yaml
_type: text_field
_scope:
  _action:
    announce:
      _type: toast
      message: Activated
_on:
  tap:
    do: announce
    ripple: false
```

## Pitfalls & related

- This is a bound input: children and slots are rejected, and a literal `bind` must name writable state declared by an enclosing `_scope` or root data.

- Interaction maps must reference actions visible from an enclosing scope; see [Interaction](../../interaction.md) and [Actions](../../actions.md).
- Return to the [widget catalog](../README.md).
