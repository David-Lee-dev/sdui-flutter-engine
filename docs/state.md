# State and reactivity

`_scope` introduces a lexical, reactive state/action boundary whose declared keys define what descendants may read and write.

## Declaring state

```yaml
_type: column
_scope:
  _state:
    name: Ada
    enabled: true
  _action:
    disable:
      _type: set
      enabled: false
_children:
  - _type: text
    value: 'Hello ${name}'
  - _type: toggle
    bind: enabled
```

State names must match `[A-Za-z][A-Za-z0-9_]*`. Initial values are preserved as literal JSON-like values; `_state` itself does not compile `${…}`. State snapshots are normalized and committed atomically. Observers subscribe to the exact root names recorded during expression compilation, so changes rebuild only directives depending on those roots.

## Nesting and shadowing

Reads walk from the nearest environment outward. A nested scope may shadow an outer key. Loop variables, morph variables, `$event`, `$data`, and `$error` are temporary read-only frames and may shadow state for their lifetime.

`set` is intentionally narrower than reads: a named action may write only keys declared by the scope that defines that action. A `bind` lookup walks outward and writes the nearest scope that declares its literal key. Loop/morph/handler frames are never writable.

## Bound widgets

The bound inputs are [`toggle`](widgets/input/toggle.md), [`cupertino_switch`](widgets/input/cupertino_switch.md), [`checkbox`](widgets/input/checkbox.md), [`dropdown`](widgets/input/dropdown.md), [`radio`](widgets/input/radio.md), [`slider`](widgets/input/slider.md), and [`text_field`](widgets/input/text_field.md). `bind` reads the live value, writes changes before dispatching a `change` action, and must be a literal declared writable key when statically checkable. `_on.submit` dispatches without an automatic write beyond the widget's normal change path.

## Root data and query parameters

`EngineRunner.rootData` supplies the outermost declarations used during validation. Route/query parameters arrive through this map and are read as ordinary `${key}` bindings. If the template root has `_scope`, root data is merged into that root scope and wins over a same-named `_state` default; otherwise the engine creates a plain root state layer.

Changing root-data values without changing the key set updates the root scope without recompiling. Changing the template identity or declared root key set triggers compilation. A mounted scope can reseed values only when its state key set is unchanged; schema changes require remounting/keying by revision.

See [expressions](expressions.md), [actions](actions.md), and [loops](loops.md).

