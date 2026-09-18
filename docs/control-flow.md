# Control flow and morphing

Conditions and switches select directive branches, while `_morph` exposes an animated value to one child subtree.

## Node `_if`

Any ordinary widget node may carry `_if: '${predicate}'`. It must be one whole non-empty expression; the widget renders only when truthy. `_if` can combine with `_scope` and `_loop` according to the wrapper order described in [Concepts](concepts.md#compile-pipeline).

## `cond`

`cond` is a control node: it takes `_children` and no widget props. Each child has exactly one `_if` expression or `_else: true`; only one fallback is allowed.

```yaml
_type: cond
_children:
  - _type: text
    _if: '${score >= 90}'
    value: Excellent
  - _type: text
    _if: '${score >= 60}'
    value: Passing
  - _type: text
    _else: true
    value: Try again
```

The first truthy branch wins. A condition may contain only `_if`, `_loop`, and `_scope` as control-node markers; branch marker keys are stripped before the child is compiled. Every branch is validated even when inactive and must satisfy the parent's layout protocol.

## `switch`

`switch` requires a whole-expression `_value` and at least one `_case`. Case values are literal strings, numbers, or booleans; expressions and duplicates are rejected. One `_default: true` is optional.

```yaml
_type: switch
_value: '${status}'
_children:
  - { _type: text, _case: ready, value: Ready }
  - { _type: text, _case: 404, value: Missing }
  - { _type: text, _default: true, value: Unknown }
```

Matching uses the evaluator's structural equality. A switch control node allows `_value`, `_if`, `_loop`, and `_scope` only; like `cond`, it takes no widget props.

## `_morph`

`_morph` animates from a scalar/numeric source to `_to` and exposes the current interpolated value under `_as`:

| Key | Type | Default |
| --- | --- | --- |
| `_to` | whole expression or scalar number/bool | required |
| `_from` | whole expression or scalar | previous/current target behavior when omitted |
| `_as` | bindable identifier | required |
| `_duration` | non-negative integer ms | `400` |
| `_curve` | string | `ease_out` |
| `_delay` | non-negative integer ms | `0` |
| `_trigger` | expression or scalar | none |
| `_repeat` | bool | `false` |
| `_reverse` | bool | `false` |

```yaml
_type: opacity
_morph:
  _from: 0
  _to: '${visible ? 1 : 0}'
  _as: alpha
  _duration: 250
opacity: '${alpha}'
_child: { _type: text, value: Ready }
```

The morph variable is readable only by its child and is not writable state. Unknown morph keys are rejected. Curve names use the same resolver documented in [Motion](motion.md).

