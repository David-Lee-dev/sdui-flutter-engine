# Expressions

Expressions are embedded as `${…}` and preserve native types when the entire string is one expression.

## Interpolation

```yaml
value: '${user}'                 # preserves the map/list/number/bool/null result
semantics_label: 'User ${user.id}' # always produces a string; null fragments are empty
price: '$$${comma(total)}'       # `$$` emits one literal dollar sign
```

Positions requiring a predicate or selector accept exactly one `${…}` expression, not interpolated text. Expressions inside maps and lists are compiled recursively. Missing bindings or missing property/index traversal resolve to `null`; syntax and invalid arithmetic raise an error isolated at the node/action boundary.

## Grammar and precedence

From lowest to highest precedence:

| Form | Syntax and behavior |
| --- | --- |
| Ternary | `condition ? then : else`; right-associative. |
| Null coalescing | `left ?? right`; evaluates the right only when left is null. |
| Logic | `or`, then `and`; both short-circuit and return an operand value. |
| Negation | `not value`, using template truthiness. |
| Membership | `x in list/map/string`, `x not in value`; maps test keys, strings require a string needle. |
| Comparison | `== != < <= > >=`; order supports number-number or string-string; comparisons may chain. Equality is structural for maps/lists. |
| Additive | `+ -`; `+` also concatenates two strings. |
| Multiplicative | `* / // %`; `*` repeats strings/lists by an integer-valued number. Division by zero fails. |
| Unary | `+value`, `-value`; numeric only. |
| Power | `**`; binds tighter than a leading sign and accepts a signed right operand. |
| Postfix | `.name`, `[index]`, `[start:stop:step]`; may chain. |

Literals are decimal/hex/bin/oct numbers (underscores and exponents supported), single- or double-quoted strings with standard escapes and `\uXXXX`/`\u{…}`, `true`, `false`, `null`, lists, and maps. Identifiers begin with a letter and continue with letters, digits, or `_`; binding roots may not start with `_`.

The expression parser understands map literals, but the template interpolation scanner ends an unquoted `${…}` segment at its first `}`. Consequently, an inline map literal cannot currently be embedded in a template string; pass an existing map binding to functions such as `merge`, or use helpers such as `set_path` instead. Braces inside a quoted expression string do not close the interpolation.

List indices accept integral numbers and negative offsets. Map indices use their evaluated key. Slices work on lists and Unicode scalar sequences in strings; omitted bounds and negative steps use Python-like normalization, while a zero/non-integral step fails.

## Collections and comprehensions

```yaml
value: '${[user.name for user in users if user.active]}'
```

The grammar is `[expression for name in listExpression]` with an optional `if predicate`. A non-list source produces `[]`. The loop variable shadows outer bindings only inside the result expression/condition. Comprehensions, repetition, ranges, and concatenation are capped at 100,000 produced elements/characters.

## Truthiness

`null`, `false`, numeric zero, empty strings, empty iterables, and empty maps are false. Other values are true.

## Function registry

Wrong types or excess fixed-arity arguments generally return `null`; omitted arguments are read as `null`.

### Application functions

Pass application functions to `Sdui.initialize(functions: ...)` or `Engine.initialize(functions: ...)`. Each function receives its evaluated positional arguments as a `List<Object?>` and may return any expression value:

```dart
Sdui.initialize(
  // Required dependencies omitted.
  functions: {
    'app_slug': (args) {
      final value = args.isEmpty ? null : args[0];
      return value is String
          ? value.trim().toLowerCase().replaceAll(' ', '-')
          : null;
    },
  },
);
```

Templates can then call the registered name like a built-in:

```yaml
value: '${app_slug(article.title)}'
```

Initialization registers these functions before the catalog freezes, includes their names in `Engine.catalog`, and rejects later registration. When booted through `Sdui.initialize` or `Engine.initialize`, `EngineRunner` validates function calls in widget properties and command parameters/guards against that snapshot, so an unknown call there is a compile-fatal `unknown function` validator error before mounting. A bare mount without initialization falls back to `Engine.snapshotCatalog()`, a live enumeration of every registered function name, so this check still applies to any call reachable at compile time. A server-side or build-time compiler using `LanguageCatalog.builtin()` validates only the built-in functions declared in `BuiltinLanguage`; an application function registered only at runtime is invisible to that offline catalog.

### Built-ins

| Function | Signature | Result |
| --- | --- | --- |
| `str` | `str(value?)` | Text; null becomes `''`. |
| `int` | `int(value?)` | Truncated number or parsed integer string. |
| `num` | `num(value?)` | Number or parsed numeric string. |
| `bool` | `bool(value?)` | Template truthiness. |
| `len` | `len(value?)` | String/list/map length. |
| `type` | `type(value?)` | `null`, `bool`, `num`, `string`, `list`, `map`, or `unknown`. |
| `default` | `default(value?, fallback?)` | Fallback only when value is null. |
| `abs` | `abs(number?)` | Absolute value. |
| `round` | `round(number?, decimals?)` | Integer, or rounding to decimal places. |
| `floor` / `ceil` | `floor(number?)`, `ceil(number?)` | Integer rounding. |
| `min` / `max` | `min(...values)`, `max(...values)` | Extremum of numeric args; one list arg is unpacked. |
| `sum` | `sum(...values)` | Sum of numeric args; one list arg is unpacked. |
| `clamp` | `clamp(value?, low?, high?)` | Inclusive numeric clamp. |
| `lerp` | `lerp(begin?, end?, t?)` | Numeric interpolation; invalid inputs default to zero. |
| `mix` | `mix(beginColor?, endColor?, t?)` | ARGB integer color interpolation, clamped to 0–1. |
| `comma` | `comma(number?)` | Thousands-grouped number text. |
| `format` | `format(number?, decimals?)` | Fixed-decimal text. |
| `percent` | `percent(ratio?, decimals?)` | Ratio × 100 plus `%`; decimals default to 0. |
| `currency` | `currency(number?, symbol?)` | Grouped number prefixed by symbol; default `₩`. |
| `upper` / `lower` / `trim` / `capitalize` | one string arg | Corresponding string transform. |
| `replace` | `replace(string?, from?, to?)` | Replaces all occurrences. |
| `split` | `split(string?, separator?)` | List of substrings. |
| `substring` | `substring(string?, start?, end?)` | Clamped substring; end defaults to length. |
| `starts_with` / `ends_with` | `(string?, part?)` | Prefix/suffix test. |
| `contains` | `contains(stringOrList?, value?)` | Substring or structural list membership. |
| `pad_start` / `pad_end` | `(string?, width?, fill?)` | Padding; fill defaults to a space. |
| `repeat` | `repeat(string?, count?)` | Repeated string. |
| `join` | `join(list?, separator?)` | Joined text; null elements become empty text. |
| `first` / `last` | `(list?)` | Endpoint element or null. |
| `reversed` / `sorted` | `(list?)` | New reversed/naturally ordered list. Mixed incomparable values retain comparator equality. |
| `range` | `range(stop)` / `range(start, stop[, step])` | Stop-exclusive numeric list; step cannot be zero. |
| `concat` | `concat(...lists)` | New flattened one-level list; non-lists are skipped. |
| `keys` / `values` | `(map?)` | New key/value list. |
| `get` | `get(map?, key?, default?)` | Map value, or default when key is absent. |
| `has` | `has(map?, key?)` | Whether the map contains the key. |
| `merge` | `merge(baseMap?, changesMap?)` | New shallowly merged map. |
| `update_at` | `update_at(list?, index?, value?)` | New list with one index changed; invalid input returns the original. |
| `set_path` | `set_path(value?, pathList?, newValue?)` | Immutable nested map/list update; invalid branches are preserved. |
