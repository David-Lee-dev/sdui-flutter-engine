import 'dart:math' as math;

import '../environment/_base.dart';
import '../environment/map_environment.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import '../util/function_registry.dart';

/// Evaluates compiled expressions and values against a runtime environment.
final class ExpressionEvaluator {
  const ExpressionEvaluator._();

  /// Evaluates [expression] against [env].
  static Object? evaluate(Expression expression, Environment env) =>
      _eval(expression.ast, env);

  /// Evaluates [expression] and applies template truthiness rules.
  static bool evaluateTruthy(Expression expression, Environment env) =>
      _truthy(_eval(expression.ast, env));

  /// Evaluates expression fragments in [interpolation] and joins them as text.
  static String evaluateInterpolation(
    Interpolation interpolation,
    Environment env,
  ) {
    final buffer = StringBuffer();
    for (final part in interpolation.parts) {
      if (part is Expression) {
        final value = evaluate(part, env);
        if (value != null) buffer.write(value);
      } else {
        buffer.write(part);
      }
    }
    return buffer.toString();
  }

  /// Resolves expressions recursively within [value].
  static Object? resolveValue(Object? value, Environment env) {
    if (value is Expression) return evaluate(value, env);
    if (value is Interpolation) return evaluateInterpolation(value, env);
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: resolveValue(entry.value, env),
      };
    }
    if (value is List) {
      return [for (final element in value) resolveValue(element, env)];
    }
    return value;
  }

  /// Resolves expressions recursively within the values of [values].
  static Map<String, Object?> resolveMap(
    Map<String, Object?> values,
    Environment env,
  ) => {
    for (final entry in values.entries)
      entry.key: resolveValue(entry.value, env),
  };

  static Object? _eval(Expr node, Environment env) => switch (node) {
    LiteralExpr(:final value) => value,
    BindingExpr(:final root) => () {
      for (Environment? e = env; e != null; e = e.parent) {
        if (e.has(root)) return e.read(root);
      }
      return null;
    }(),
    PropertyExpr(:final target, :final name) => () {
      final t = _eval(target, env);
      return t is Map ? t[name] : null;
    }(),
    IndexExpr(:final target, :final index) => () {
      final t = _eval(target, env);
      final i = _eval(index, env);
      if (t is Map) return t[i];
      if (t is List) {
        if (i is num && i == i.truncate()) {
          var n = i.toInt();
          if (n < 0) n += t.length;
          if (n >= 0 && n < t.length) return t[n];
        }
        return null;
      }
      return null;
    }(),
    UnaryExpr(:final op, :final operand) => () {
      if (op == 'not') return !_truthy(_eval(operand, env));
      final v = _eval(operand, env);
      if (v is! num) {
        _error("unary '$op' needs a number, got ${v.runtimeType}");
      }
      return op == '-' ? -v : v;
    }(),
    BinaryExpr(:final op, :final left, :final right) => _arith(
      op,
      _eval(left, env),
      _eval(right, env),
    ),
    LogicalExpr(:final op, :final left, :final right) => () {
      final l = _eval(left, env);
      if (op == 'and') return _truthy(l) ? _eval(right, env) : l;
      return _truthy(l) ? l : _eval(right, env);
    }(),
    ComparisonExpr(:final first, :final rest) => () {
      var prev = _eval(first, env);
      for (final link in rest) {
        final next = _eval(link.operand, env);
        final ok = switch (link.op) {
          '==' => _equals(prev, next),
          '!=' => !_equals(prev, next),
          _ => _order(link.op, prev, next),
        };
        if (!ok) return false;
        prev = next;
      }
      return true;
    }(),
    TernaryExpr(:final cond, then: final thenExpr, :final orElse) =>
      _truthy(_eval(cond, env)) ? _eval(thenExpr, env) : _eval(orElse, env),
    NullCoalesceExpr(:final left, :final right) =>
      _eval(left, env) ?? _eval(right, env),
    InExpr(:final left, :final right, :final negate) => () {
      final l = _eval(left, env);
      final r = _eval(right, env);
      final bool result;
      if (r is List) {
        result = r.any((e) => _equals(e, l));
      } else if (r is Map) {
        result = r.containsKey(l);
      } else if (r is String && l is String) {
        result = r.contains(l);
      } else {
        result = false;
      }
      return negate ? !result : result;
    }(),
    ListLiteralExpr(:final elements) => [
      for (final e in elements) _eval(e, env),
    ],
    MapLiteralExpr(:final entries) => {
      for (final e in entries) _eval(e.$1, env): _eval(e.$2, env),
    },
    SliceExpr(:final target, :final start, :final stop, :final step) => () {
      final t = _eval(target, env);
      final s = start == null ? null : _eval(start, env);
      final e = stop == null ? null : _eval(stop, env);
      final st = step == null ? null : _eval(step, env);
      if (t is List) {
        return _sliceIndices(t.length, s, e, st).map((i) => t[i]).toList();
      }
      if (t is String) {
        // Slice Unicode scalars so surrogate pairs are never split in half.
        final runes = t.runes.toList();
        return String.fromCharCodes(
          _sliceIndices(runes.length, s, e, st).map((i) => runes[i]),
        );
      }
      return null;
    }(),
    CallExpr(:final name, :final args) => () {
      final fn = FunctionRegistry.resolve(name);
      if (fn == null) _error('unknown function "$name"');
      return fn([for (final a in args) _eval(a, env)]);
    }(),
    ComprehensionExpr(:final varName, :final iter, :final expr, :final cond) =>
      () {
        final source = _eval(iter, env);
        if (source is! List) return const <Object?>[];
        final out = <Object?>[];
        for (final item in source) {
          final child = MapEnvironment({varName: item}, parent: env);
          if (cond != null && !_truthy(_eval(cond, child))) continue;
          if (out.length >= _maxCollection) {
            _error(
              'comprehension exceeds max collection size ($_maxCollection)',
            );
          }
          out.add(_eval(expr, child));
        }
        return out;
      }(),
  };
}

bool _truthy(Object? v) => switch (v) {
  null => false,
  final bool b => b,
  final num n => n != 0,
  final String s => s.isNotEmpty,
  final Iterable<Object?> it => it.isNotEmpty,
  final Map<Object?, Object?> m => m.isNotEmpty,
  _ => true,
};

Never _error(String message) => throw FormatException(message);

const int _maxCollection = 100000;

bool _equals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map) {
    if (b is! Map || a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      if (!_equals(entry.value, b[entry.key])) return false;
    }
    return true;
  }
  if (a is List) {
    if (b is! List || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_equals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

bool _order(String op, Object? a, Object? b) {
  final int c;
  if (a is num && b is num) {
    c = a.compareTo(b);
  } else if (a is String && b is String) {
    c = a.compareTo(b);
  } else {
    _error("'$op' not supported between ${a.runtimeType} and ${b.runtimeType}");
  }
  return switch (op) {
    '<' => c < 0,
    '<=' => c <= 0,
    '>' => c > 0,
    '>=' => c >= 0,
    _ => false,
  };
}

Object? _arith(String op, Object? a, Object? b) {
  if (op == '+' && a is String && b is String) return a + b;
  // Repetition must be recognized before the numeric type gate.
  if (op == '*') {
    if (a is String && b is num) return _repeatSeq(a, b);
    if (b is String && a is num) return _repeatSeq(b, a);
    if (a is List && b is num) return _repeatList(a, b);
    if (b is List && a is num) return _repeatList(b, a);
  }
  if (a is! num || b is! num) {
    _error("'$op' needs numbers, got ${a.runtimeType} and ${b.runtimeType}");
  }
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      if (b == 0) _error('division by zero');
      return a / b;
    case '//':
      if (b == 0) _error('floor division by zero');
      return (a / b).floor();
    case '**':
      return math.pow(a, b);
    case '%':
      if (b == 0) _error('modulo by zero');
      // Match Python floor-modulo, whose result follows the divisor's sign.
      final r = a % b;
      return r != 0 && b < 0 ? r + b : r;
  }
  return _error("unknown operator '$op'");
}

String _repeatSeq(String s, num n) {
  final count = n.truncate();
  if (count <= 0) return '';
  if (s.length * count > _maxCollection) {
    _error('repeat exceeds max collection size ($_maxCollection)');
  }
  return List.filled(count, s).join();
}

List<Object?> _repeatList(List<Object?> list, num n) {
  final count = n.truncate();
  if (count <= 0) return const [];
  if (list.length * count > _maxCollection) {
    _error('repeat exceeds max collection size ($_maxCollection)');
  }
  return [for (var i = 0; i < count; i++) ...list];
}

List<int> _sliceIndices(int length, Object? start, Object? stop, Object? step) {
  var stepVal = 1;
  if (step != null) {
    if (step is! num || step == 0) return const [];
    stepVal = step.toInt();
  }
  int clamp(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);
  int normalize(Object? v, int fallback) {
    if (v is! num) return fallback;
    var n = v.toInt();
    if (n < 0) n += length;
    return n;
  }

  int lo;
  int hi;
  if (stepVal > 0) {
    lo = clamp(start == null ? 0 : normalize(start, 0), 0, length);
    hi = clamp(stop == null ? length : normalize(stop, length), 0, length);
  } else {
    lo = clamp(
      start == null ? length - 1 : normalize(start, length - 1),
      -1,
      length - 1,
    );
    hi = clamp(stop == null ? -1 : normalize(stop, -1), -1, length - 1);
  }
  final out = <int>[];
  if (stepVal > 0) {
    for (var i = lo; i < hi; i += stepVal) {
      out.add(i);
    }
  } else {
    for (var i = lo; i > hi; i += stepVal) {
      out.add(i);
    }
  }
  return out;
}
