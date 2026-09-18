import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'props_resolver.dart';

/// Maps expression-call names to pure runtime functions.
///
/// Built-ins and application functions share one uniform argument-list signature.
/// Built-ins treat wrong arity or value types as `null` unless producing the
/// requested collection would exceed the safety cap.
final class FunctionRegistry {
  const FunctionRegistry._();

  static Object? Function(List<Object?>) _ar(
    int max,
    Object? Function(List<Object?>) fn,
  ) =>
      (a) => (max >= 0 && a.length > max) ? null : fn(a);

  static final Map<String, Object? Function(List<Object?>)> _builtins = {
    'str': _ar(1, _Builtins.strOf),
    'int': _ar(1, _Builtins.intOf),
    'num': _ar(1, _Builtins.numOf),
    'bool': _ar(1, _Builtins.boolOf),
    'len': _ar(1, _Builtins.len),
    'type': _ar(1, _Builtins.typeOf),
    'default': _ar(2, _Builtins.defaultOf),
    'abs': _ar(1, _Builtins.abs),
    'round': _ar(2, _Builtins.round),
    'floor': _ar(1, _Builtins.floor),
    'ceil': _ar(1, _Builtins.ceil),
    'min': _ar(-1, _Builtins.min),
    'max': _ar(-1, _Builtins.max),
    'sum': _ar(-1, _Builtins.sum),
    'clamp': _ar(3, _Builtins.clamp),
    'lerp': _ar(3, _Builtins.lerp),
    'mix': _ar(3, _Builtins.mix),
    'comma': _ar(1, _Builtins.comma),
    'format': _ar(2, _Builtins.format),
    'percent': _ar(2, _Builtins.percent),
    'currency': _ar(2, _Builtins.currency),
    'upper': _ar(1, _Builtins.upper),
    'lower': _ar(1, _Builtins.lower),
    'trim': _ar(1, _Builtins.trim),
    'capitalize': _ar(1, _Builtins.capitalize),
    'replace': _ar(3, _Builtins.replace),
    'split': _ar(2, _Builtins.split),
    'substring': _ar(3, _Builtins.substring),
    'starts_with': _ar(2, _Builtins.startsWith),
    'ends_with': _ar(2, _Builtins.endsWith),
    'contains': _ar(2, _Builtins.contains),
    'pad_start': _ar(3, _Builtins.padStart),
    'pad_end': _ar(3, _Builtins.padEnd),
    'repeat': _ar(2, _Builtins.repeat),
    'join': _ar(2, _Builtins.join),
    'first': _ar(1, _Builtins.first),
    'last': _ar(1, _Builtins.last),
    'reversed': _ar(1, _Builtins.reversed),
    'sorted': _ar(1, _Builtins.sorted),
    'range': _ar(3, _Builtins.range),
    'concat': _ar(-1, _Builtins.concat),
    'keys': _ar(1, _Builtins.keys),
    'values': _ar(1, _Builtins.values),
    'get': _ar(3, _Builtins.get),
    'has': _ar(2, _Builtins.has),
    'merge': _ar(2, _Builtins.merge),
    'update_at': _ar(3, _Builtins.updateAt),
    'set_path': _ar(3, _Builtins.setPath),
  };

  static final Map<String, Object? Function(List<Object?>)> _functions = {
    ..._builtins,
  };

  static bool _frozen = false;

  /// Prevents later registration until [reset] is called.
  static void freeze() => _frozen = true;

  /// Registers [fn] under [name], replacing any existing implementation.
  ///
  /// Throws a [StateError] after [freeze].
  static void register(String name, Object? Function(List<Object?>) fn) {
    if (_frozen) {
      throw StateError(
        'FunctionRegistry is frozen — register before freeze().',
      );
    }
    _functions[name] = fn;
  }

  /// Registers every entry in [fns] as one validated operation.
  static void registerAll(Map<String, Object? Function(List<Object?>)> fns) {
    if (_frozen) {
      throw StateError(
        'FunctionRegistry is frozen — register before freeze().',
      );
    }
    _functions.addAll(fns);
  }

  /// Restores built-ins and unfreezes the registry for test isolation.
  static void reset() {
    _frozen = false;
    _functions
      ..clear()
      ..addAll(_builtins);
  }

  /// Returns the function registered as [name], or `null` if none exists.
  /// An immutable snapshot of every registered function name.
  static Set<String> names() => Set.unmodifiable(_functions.keys);

  static Object? Function(List<Object?>)? resolve(String name) =>
      _functions[name];
}

final class _Builtins {
  const _Builtins._();

  /// Converts a value to its string representation, with `null` as empty text.
  static Object? strOf(List<Object?> a) {
    final x = _at(a, 0);
    return x == null ? '' : x.toString();
  }

  /// Converts a number or numeric string to an integer, or returns `null`.
  static Object? intOf(List<Object?> a) {
    final x = _at(a, 0);
    if (x is num) return x.truncate();
    if (x is String) return int.tryParse(x);
    return null;
  }

  /// Converts a number or numeric string to a number, or returns `null`.
  static Object? numOf(List<Object?> a) {
    final x = _at(a, 0);
    if (x is num) return x;
    if (x is String) return double.tryParse(x);
    return null;
  }

  /// Converts a value to the expression language's truth value.
  static Object? boolOf(List<Object?> a) => _truthy(_at(a, 0));

  /// Returns the length of a string, list, or map, or `null` otherwise.
  static Object? len(List<Object?> a) {
    final x = _at(a, 0);
    if (x is String) return x.length;
    if (x is List) return x.length;
    if (x is Map) return x.length;
    return null;
  }

  /// Returns the expression type name for a value.
  static Object? typeOf(List<Object?> a) => switch (_at(a, 0)) {
    null => 'null',
    bool() => 'bool',
    num() => 'num',
    String() => 'string',
    List() => 'list',
    Map() => 'map',
    _ => 'unknown',
  };

  /// Returns the first argument unless it is `null`, then the fallback.
  static Object? defaultOf(List<Object?> a) => _at(a, 0) ?? _at(a, 1);

  /// Returns a number's absolute value, or `null` for a non-number.
  static Object? abs(List<Object?> a) {
    final x = _at(a, 0);
    return x is num ? x.abs() : null;
  }

  /// Rounds a number, optionally to `d` decimal places with `round(x, d)`.
  static Object? round(List<Object?> a) {
    final x = _at(a, 0);
    if (x is! num) return null;
    final dRaw = _at(a, 1);
    if (dRaw == null) return x.round();
    if (dRaw is! num) return null;
    final factor = math.pow(10, dRaw.toInt());
    return (x * factor).round() / factor;
  }

  /// Rounds a number down to an integer, or returns `null`.
  static Object? floor(List<Object?> a) {
    final x = _at(a, 0);
    return x is num ? x.floor() : null;
  }

  /// Rounds a number up to an integer, or returns `null`.
  static Object? ceil(List<Object?> a) {
    final x = _at(a, 0);
    return x is num ? x.ceil() : null;
  }

  /// Returns the smallest numeric argument, skipping non-numbers.
  static Object? min(List<Object?> a) {
    final values = _numArgs(a);
    if (values.isEmpty) return null;
    return values.reduce((x, y) => x < y ? x : y);
  }

  /// Returns the largest numeric argument, skipping non-numbers.
  static Object? max(List<Object?> a) {
    final values = _numArgs(a);
    if (values.isEmpty) return null;
    return values.reduce((x, y) => x > y ? x : y);
  }

  /// Sums the numeric arguments, skipping non-numbers.
  static Object? sum(List<Object?> a) {
    num total = 0;
    for (final v in _numArgs(a)) {
      total += v;
    }
    return total;
  }

  /// Constrains a number to the inclusive lower and upper bounds.
  static Object? clamp(List<Object?> a) {
    final x = _at(a, 0);
    final lo = _at(a, 1);
    final hi = _at(a, 2);
    if (x is! num || lo is! num || hi is! num) return null;
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
  }

  /// Linearly interpolates or extrapolates between two finite numbers.
  static Object? lerp(List<Object?> a) {
    final begin = _finiteNum(_at(a, 0)) ?? 0;
    final end = _finiteNum(_at(a, 1)) ?? 0;
    final t = _finiteNum(_at(a, 2)) ?? 0;
    return begin + (end - begin) * t;
  }

  /// Interpolates between two colors and returns an ARGB integer.
  static Object? mix(List<Object?> a) {
    final begin = PropsResolver.color(_at(a, 0));
    final end = PropsResolver.color(_at(a, 1));
    if (begin == null || end == null) return begin?.toARGB32() ?? 0x00000000;

    final t = (_finiteNum(_at(a, 2)) ?? 0).clamp(0, 1).toDouble();
    return Color.lerp(begin, end, t)!.toARGB32();
  }

  static num? _finiteNum(Object? value) =>
      value is num && value.isFinite ? value : null;

  static List<num> _numArgs(List<Object?> a) {
    final raw = a.length == 1 && a[0] is List ? a[0]! as List : a;
    return [
      for (final v in raw)
        if (v is num) v,
    ];
  }

  /// Formats a number with comma-separated thousands.
  static Object? comma(List<Object?> a) {
    final x = _at(a, 0);
    return x is num ? _commaFormat(x) : null;
  }

  /// Formats a number with the requested fixed decimal places.
  static Object? format(List<Object?> a) {
    final x = _at(a, 0);
    final d = _at(a, 1);
    if (x is! num || d is! num) return null;
    return x.toStringAsFixed(d.toInt());
  }

  /// Formats a ratio as a percentage with optional decimal places.
  static Object? percent(List<Object?> a) {
    final r = _at(a, 0);
    if (r is! num) return null;
    final dRaw = _at(a, 1);
    final d = dRaw is num ? dRaw.toInt() : 0;
    return '${(r * 100).toStringAsFixed(d)}%';
  }

  /// Formats a number with comma grouping and an optional currency symbol.
  static Object? currency(List<Object?> a) {
    final n = _at(a, 0);
    if (n is! num) return null;
    final symbolRaw = _at(a, 1);
    final symbol = symbolRaw is String ? symbolRaw : '₩';
    return '$symbol${_commaFormat(n)}';
  }

  static String _commaFormat(num n) {
    final text = n.toString();
    final neg = text.startsWith('-');
    final body = neg ? text.substring(1) : text;
    final dot = body.indexOf('.');
    final intPart = dot == -1 ? body : body.substring(0, dot);
    final fracPart = dot == -1 ? '' : body.substring(dot);
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${neg ? '-' : ''}$buf$fracPart';
  }

  /// Converts a string to uppercase, or returns `null`.
  static Object? upper(List<Object?> a) {
    final s = _at(a, 0);
    return s is String ? s.toUpperCase() : null;
  }

  /// Converts a string to lowercase, or returns `null`.
  static Object? lower(List<Object?> a) {
    final s = _at(a, 0);
    return s is String ? s.toLowerCase() : null;
  }

  /// Removes leading and trailing whitespace from a string.
  static Object? trim(List<Object?> a) {
    final s = _at(a, 0);
    return s is String ? s.trim() : null;
  }

  /// Uppercases the first character of a string.
  static Object? capitalize(List<Object?> a) {
    final s = _at(a, 0);
    if (s is! String) return null;
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  /// Replaces every occurrence of one substring with another.
  static Object? replace(List<Object?> a) {
    final s = _at(a, 0);
    final from = _at(a, 1);
    final to = _at(a, 2);
    if (s is! String || from is! String || to is! String) return null;
    return s.replaceAll(from, to);
  }

  /// Splits a string around each occurrence of a separator.
  static Object? split(List<Object?> a) {
    final s = _at(a, 0);
    final sep = _at(a, 1);
    if (s is! String || sep is! String) return null;
    return s.split(sep);
  }

  /// Returns `substring(s, start, end?)` with indices clamped to the string.
  static Object? substring(List<Object?> a) {
    final s = _at(a, 0);
    final start = _at(a, 1);
    if (s is! String || start is! num) return null;
    final len = s.length;
    final st = _clampInt(start.toInt(), 0, len);
    final endRaw = _at(a, 2);
    final en = endRaw is num ? _clampInt(endRaw.toInt(), st, len) : len;
    return s.substring(st, en);
  }

  /// Reports whether a string starts with the given prefix.
  static Object? startsWith(List<Object?> a) {
    final s = _at(a, 0);
    final p = _at(a, 1);
    if (s is! String || p is! String) return null;
    return s.startsWith(p);
  }

  /// Reports whether a string ends with the given suffix.
  static Object? endsWith(List<Object?> a) {
    final s = _at(a, 0);
    final p = _at(a, 1);
    if (s is! String || p is! String) return null;
    return s.endsWith(p);
  }

  /// Reports whether a string or list structurally contains a value.
  static Object? contains(List<Object?> a) {
    final target = _at(a, 0);
    final x = _at(a, 1);
    if (target is String) return x is String && target.contains(x);
    if (target is List) return target.any((e) => _structEquals(e, x));
    return null;
  }

  /// Left-pads a string to a minimum width with an optional fill string.
  static Object? padStart(List<Object?> a) {
    final s = _at(a, 0);
    final n = _at(a, 1);
    if (s is! String || n is! num) return null;
    final c = _at(a, 2);
    return s.padLeft(n.toInt(), c is String && c.isNotEmpty ? c : ' ');
  }

  /// Right-pads a string to a minimum width with an optional fill string.
  static Object? padEnd(List<Object?> a) {
    final s = _at(a, 0);
    final n = _at(a, 1);
    if (s is! String || n is! num) return null;
    final c = _at(a, 2);
    return s.padRight(n.toInt(), c is String && c.isNotEmpty ? c : ' ');
  }

  /// Repeats a string up to the collection safety cap.
  static Object? repeat(List<Object?> a) {
    final s = _at(a, 0);
    final n = _at(a, 1);
    if (s is! String || n is! num) return null;
    final count = n.toInt();
    if (count <= 0) return '';
    if (s.length * count > _maxCollection) {
      throw const FormatException(
        'repeat exceeds max collection size ($_maxCollection)',
      );
    }
    return List.filled(count, s).join();
  }

  /// Joins list values with a separator, rendering `null` as empty text.
  static Object? join(List<Object?> a) {
    final list = _at(a, 0);
    final sep = _at(a, 1);
    if (list is! List || sep is! String) return null;
    return list.map((e) => e == null ? '' : e.toString()).join(sep);
  }

  /// Returns the first list element, or `null` for an empty or invalid list.
  static Object? first(List<Object?> a) {
    final list = _at(a, 0);
    return list is List && list.isNotEmpty ? list.first : null;
  }

  /// Returns the last list element, or `null` for an empty or invalid list.
  static Object? last(List<Object?> a) {
    final list = _at(a, 0);
    return list is List && list.isNotEmpty ? list.last : null;
  }

  /// Returns a new list with the input elements in reverse order.
  static Object? reversed(List<Object?> a) {
    final list = _at(a, 0);
    return list is List ? list.reversed.toList() : null;
  }

  /// Returns a new naturally ordered list without changing the input.
  static Object? sorted(List<Object?> a) {
    final list = _at(a, 0);
    if (list is! List) return null;
    return List<Object?>.of(list)..sort(_naturalCompare);
  }

  static int _naturalCompare(Object? a, Object? b) {
    if (a is num && b is num) return a.compareTo(b);
    if (a is String && b is String) return a.compareTo(b);
    return 0;
  }

  /// Builds `range(n | start, stop | start, stop, step)` within the safety cap.
  static Object? range(List<Object?> a) {
    if (a.isEmpty) return null;
    num start;
    num stop;
    num step = 1;
    if (a.length == 1) {
      final s = a[0];
      if (s is! num) return null;
      start = 0;
      stop = s;
    } else {
      final s0 = a[0];
      final s1 = a[1];
      if (s0 is! num || s1 is! num) return null;
      start = s0;
      stop = s1;
      if (a.length >= 3) {
        final s2 = a[2];
        if (s2 is! num) return null;
        step = s2;
      }
    }
    if (step == 0) return null;
    final out = <num>[];
    if (step > 0) {
      for (var v = start; v < stop; v += step) {
        if (out.length >= _maxCollection) {
          throw const FormatException(
            'range exceeds max collection size ($_maxCollection)',
          );
        }
        out.add(v);
      }
    } else {
      for (var v = start; v > stop; v += step) {
        if (out.length >= _maxCollection) {
          throw const FormatException(
            'range exceeds max collection size ($_maxCollection)',
          );
        }
        out.add(v);
      }
    }
    return out;
  }

  /// Concatenates the list arguments into one new list.
  ///
  /// Variadic and non-mutating; non-list arguments (including null) are skipped,
  /// mirroring the lenient handling of the variadic numeric builtins (min/max/sum).
  /// Used to accumulate paginated pages in templates, where the running list may
  /// still be null on the first append.
  static Object? concat(List<Object?> a) {
    final out = <Object?>[];
    for (final arg in a) {
      if (arg is! List) continue;
      if (out.length + arg.length > _maxCollection) {
        throw const FormatException(
          'concat exceeds max collection size ($_maxCollection)',
        );
      }
      out.addAll(arg);
    }
    return out;
  }

  /// Returns a map's keys as a new list, or `null` for a non-map.
  static Object? keys(List<Object?> a) {
    final m = _at(a, 0);
    return m is Map ? m.keys.toList() : null;
  }

  /// Returns a map's values as a new list, or `null` for a non-map.
  static Object? values(List<Object?> a) {
    final m = _at(a, 0);
    return m is Map ? m.values.toList() : null;
  }

  /// Returns `get(map, key, default)` using the default for a missing key.
  static Object? get(List<Object?> a) {
    final m = _at(a, 0);
    if (m is! Map) return null;
    final k = _at(a, 1);
    return m.containsKey(k) ? m[k] : _at(a, 2);
  }

  /// Reports whether a map contains the given key.
  static Object? has(List<Object?> a) {
    final m = _at(a, 0);
    return m is Map && m.containsKey(_at(a, 1));
  }

  /// Returns a new map with changes shallowly merged over the base map.
  static Object? merge(List<Object?> a) {
    final base = _at(a, 0);
    final changes = _at(a, 1);
    if (base is! Map || changes is! Map) return null;
    return {...base, ...changes};
  }

  /// Returns a new list with one index updated, or the input when invalid.
  static Object? updateAt(List<Object?> a) {
    final list = _at(a, 0);
    final i = _at(a, 1);
    if (list is! List) return list;
    if (i is! num || i != i.truncate()) return list;
    var n = i.toInt();
    if (n < 0) n += list.length;
    if (n < 0 || n >= list.length) return list;
    return List<Object?>.of(list)..[n] = _at(a, 2);
  }

  /// Immutably sets a value at a map/list path, preserving invalid branches.
  static Object? setPath(List<Object?> a) {
    final path = _at(a, 1);
    if (path is! List || path.isEmpty) return _at(a, 0);
    return _setPath(_at(a, 0), path, 0, _at(a, 2));
  }

  static Object? _setPath(
    Object? node,
    List<Object?> path,
    int i,
    Object? newValue,
  ) {
    final seg = path[i];
    final last = i == path.length - 1;
    if (node is Map) {
      if (seg is! String) return node;
      return {
        ...node,
        seg: last ? newValue : _setPath(node[seg], path, i + 1, newValue),
      };
    }
    if (node is List) {
      if (seg is! num || seg != seg.truncate()) return node;
      var n = seg.toInt();
      if (n < 0) n += node.length;
      if (n < 0 || n >= node.length) return node;
      return List<Object?>.of(node)
        ..[n] = last ? newValue : _setPath(node[n], path, i + 1, newValue);
    }
    return node;
  }
}

const int _maxCollection = 100000;

Object? _at(List<Object?> args, int i) => i < args.length ? args[i] : null;

int _clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

bool _truthy(Object? v) => switch (v) {
  null => false,
  final bool b => b,
  final num n => n != 0,
  final String s => s.isNotEmpty,
  final List<Object?> l => l.isNotEmpty,
  final Map<Object?, Object?> m => m.isNotEmpty,
  _ => true,
};

bool _structEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      if (!_structEquals(entry.value, b[entry.key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_structEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
