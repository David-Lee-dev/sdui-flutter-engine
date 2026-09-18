# Core concepts

An SDUI template is a YAML/JSON widget tree that is parsed, compiled to typed directives, validated against frozen catalogs, and interpreted reactively.

## Node anatomy

Every node is a map with a string `_type`:

```yaml
_type: container
padding: 16
_key: profile-card
_motion: fade_in
_child:
  _type: text
  value: '${user.name}'
```

Bare keys are widget properties. Structural and compiler keys start with `_`. `_child`, `_children`, and `_slots` are mutually exclusive child forms; `_key`, when present, must be a string. A tree may be at most 256 nested nodes deep.

Widget property values, command parameters, `_motion` parameters, `_on.*.event`, and loop-wrapper parameters are recursively compiled for [expressions](expressions.md). Structural shapes are not interpolated.

## Compile pipeline

1. **Parse** — `TemplateParser` requires `_type`, parses child forms, splits bare props from reserved keys, and attaches diagnostic paths.
2. **Compile** — `TemplateCompiler` turns values into literals/expressions and wraps plain widgets with morph, scope, condition, and loop directives. Wrapper order from inner to outer is morph → scope → condition → loop.
3. **Validate** — `TemplateValidator` checks widget and command registration, binding roots, action references, child shapes, writable bindings, loop wrappers, and box/sliver protocols, including inactive branches.
4. **Interpret** — observers evaluate against the current environment, subscribe only to referenced roots, and rebuild the affected directive.

Unknown registered types, unknown reserved keys, undeclared binding roots, incompatible child forms, and protocol mismatches fail before mounting. Registries are seeded from runtime catalogs and frozen during engine initialization; applications may add widgets, functions, motions, and external commands before that freeze.

## Structural contracts

The runtime has five widget specification kinds:

| Kind | Child form | Runtime behavior |
| --- | --- | --- |
| eager | `_child` or `_children` | Receives an already-built positional list. |
| slot | `_slots` | Receives named children; positional children are rejected. |
| builder | positional child | Requests scoped children lazily. |
| bound | none | Receives live state value and change/submit callbacks. |
| action | `_child` or `_children` | Receives positional children and an action dispatcher. |

The parser rejects mixing `_slots` with positional children and mixing `_child` with `_children`. Validation additionally rejects slots on non-slot specifications, positional children on slot specifications, and any children on bound inputs.

## Box and sliver protocols

Every widget declares the render protocol it produces and the protocol its children require. Most produce and consume boxes. Sliver producers are valid only under sliver parents such as [`custom_scroll_view`](widgets/scrolling/custom_scroll_view.md); [`sliver_to_box_adapter`](widgets/scrolling/sliver_to_box_adapter.md) adapts a box into a sliver. A bare sliver at the engine root is invalid.

`nested_scroll_view` deliberately accepts mixed child roles. Loop wrappers `sliver_list` and `sliver_grid` produce slivers; all other loop wrappers produce boxes. Repeated items themselves must produce boxes.

## Reserved keys

The parser always consumes `_type`, `_child`, `_children`, `_slots`, and `_key`. The compiler recognizes these additional widget-node markers:

| Key | Purpose |
| --- | --- |
| `_if` | Conditional node or `cond` branch predicate. |
| `_else` | Literal-`true` fallback marker on a `cond` child only. |
| `_value` | Whole-expression selector on `switch`. |
| `_case` | Literal string/number/bool case label on a `switch` child. |
| `_default` | Literal-`true` switch fallback marker. |
| `_loop` | Repetition and wrapper configuration. |
| `_morph` | Animated numeric/scalar environment value. |
| `_scope` | State, actions, lifecycle, and skeleton boundary. |
| `_on` | Interaction event map. |
| `_motion` | Motion atom/preset or list. |
| `_provides` | Builder-provided readable variable names. |

Inside `_scope`, the allowed keys are `_state`, `_action`, `_lifecycle`, and `_skeleton`. Inside a command, the metadata keys are `_type`, `_then`, `_error`, `_dismiss`, `_always`, `_background`, `_when`, plus action-level `_dedupe` on the single-command form. Other underscore-prefixed names are rejected; widget/driver properties must not begin with `_`.

See [control flow](control-flow.md), [loops](loops.md), [state](state.md), [actions](actions.md), and [widgets](widgets/README.md).

