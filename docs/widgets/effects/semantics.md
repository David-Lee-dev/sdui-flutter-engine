# semantics

Describes its child to assistive technology (TalkBack, VoiceOver). Since 0.9.0 (`_requires: [semantics_v1]`).

The node is its own semantics node: the `label` is read first, then the child's own text. It does not change layout or painting.

## Properties

| Name | Type | Allowed values | Default | Bindable (`${}`) | Description |
| --- | --- | --- | --- | --- | --- |
| `label` | `text` | — | `null` | Yes | The spoken label. |
| `button` | `flag` | — | `false` | Yes | Announces the node as a button. |
| `selected` | `flag` | — | `null` | Yes | Gives the node a selected state. Absent means the node has no selected state (not "not selected"). |
| `hidden` | `flag` | — | `false` | Yes | Removes the node and its child from the semantics tree. The child still paints and receives taps. |
| `_child` | widget node | — | `null` | No | The single positional child; cannot be combined with `_children` or `_slots`. |
| `_on` | event map | tap, double_tap, long_press, end_reached, start_reached, scroll | `{}` | Payload only | Maps supported events to action names or `{do, throttle/debounce, event, ripple}` options. |

An invalid value (a non-string `label`, a non-bool flag) falls back to its default; nothing is reported.

## Protocol

This widget produces the **box** layout protocol. Its positional children must produce box. This type is not selected directly by `_loop._wrap`; `_loop` may still wrap this widget node as the repeated item. See [Concepts](../../concepts.md#box-and-sliver-protocols) and [Loops](../../loops.md).

## Examples

A tab that announces "Home, button, selected":

```yaml
_type: semantics
label: Home
button: true
selected: '${tab == 0}'
_child:
  _type: sizedbox
  height: 64
  _on: { tap: { do: pick, event: 0 } }
  _child: { _type: icon, name: home }
```

A decorative image hidden from screen readers:

```yaml
_type: semantics
hidden: true
_child: { _type: image, src: 'https://example.com/flourish.png' }
```

## Pitfalls & related

- Put `semantics` outside the node that carries `_on`, so the label sits on the tab rather than inside the tap target's own node.
- Use only the documented positional child form; `_slots` are rejected for this specification kind.
- Return to the [widget catalog](../README.md).
