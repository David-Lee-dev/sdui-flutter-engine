import 'package:sdui_engine/src/ir/expression.dart';
import '../invalid_template_exception.dart';

/// Compiles template values into literals, expressions, and interpolations.
///
/// Widget properties, motion parameters, and command parameters share this
/// grammar so runtime resolution never needs to reparse template strings.
final class ValueCompiler {
  const ValueCompiler._();

  /// Compiles every entry in [values] recursively.
  static Map<String, Object?> map(Map<String, Object?> values, String path) => {
    for (final entry in values.entries) entry.key: value(entry.value, path),
  };

  /// Compiles [v] recursively while preserving values without expressions.
  ///
  /// Throws [InvalidTemplateException] when an embedded expression is invalid.
  static Object? value(Object? v, String path) {
    if (v is String) {
      if (v.contains(r'${')) return _interpolate(v, path);
      return v;
    }
    if (v is Map) {
      return {
        for (final entry in v.entries) '${entry.key}': value(entry.value, path),
      };
    }
    if (v is List) {
      return [for (final e in v) value(e, path)];
    }
    return v;
  }

  static Expression _expr(String source, String path) {
    try {
      return Expression.compile(source);
    } on FormatException catch (e) {
      throw InvalidTemplateException(
        path,
        'invalid expression "$source": ${e.message}',
      );
    }
  }

  /// Compiles [source] as one value-producing expression.
  ///
  /// Interpolated text and literal strings are rejected because selectors and
  /// predicates require the expression's native result type.
  static Expression wholeExpression(String source, String path) {
    if (source.contains(r'${')) {
      final List<({bool expr, String text})> parts;
      try {
        parts = _splitInterpolation(source);
      } on FormatException catch (e) {
        throw InvalidTemplateException(
          path,
          'invalid "\${…}" in "$source": ${e.message}',
        );
      }
      if (parts.length != 1 || !parts.first.expr) {
        throw InvalidTemplateException(
          path,
          'this position needs a single "\${…}" expression, '
          'not interpolated text: "$source"',
        );
      }
      return _expr(parts.first.text, path);
    }
    throw InvalidTemplateException(
      path,
      'this position needs a "\${…}" expression: "$source"',
    );
  }

  static Object? _interpolate(String source, String path) {
    final List<({bool expr, String text})> parts;
    try {
      parts = _splitInterpolation(source);
    } on FormatException catch (e) {
      throw InvalidTemplateException(
        path,
        'invalid "\${…}" in "$source": ${e.message}',
      );
    }
    if (parts.length == 1 && parts.first.expr) {
      return _expr(parts.first.text, path);
    }
    return Interpolation([
      for (final part in parts)
        if (part.expr) _expr(part.text, path) else part.text,
    ]);
  }

  static List<({bool expr, String text})> _splitInterpolation(String s) {
    final parts = <({bool expr, String text})>[];
    final literal = StringBuffer();
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if (c == r'$' && i + 1 < s.length) {
        final next = s[i + 1];
        if (next == r'$') {
          literal.write(r'$');
          i += 2;
          continue;
        }
        if (next == '{') {
          if (literal.isNotEmpty) {
            parts.add((expr: false, text: literal.toString()));
            literal.clear();
          }
          i += 2;
          final expr = StringBuffer();
          String? quote;
          var closed = false;
          while (i < s.length) {
            final d = s[i];
            if (quote != null) {
              expr.write(d);
              // An escaped quote remains part of the expression and must not
              // terminate quote tracking before the closing brace.
              if (d == r'\' && i + 1 < s.length) {
                expr.write(s[i + 1]);
                i += 2;
              } else {
                if (d == quote) quote = null;
                i++;
              }
            } else if (d == "'" || d == '"') {
              quote = d;
              expr.write(d);
              i++;
            } else if (d == '}') {
              closed = true;
              i++;
              break;
            } else {
              expr.write(d);
              i++;
            }
          }
          if (!closed) {
            throw const FormatException('unterminated "\${" (missing "}")');
          }
          parts.add((expr: true, text: expr.toString()));
          continue;
        }
      }
      literal.write(c);
      i++;
    }
    if (literal.isNotEmpty) parts.add((expr: false, text: literal.toString()));
    return parts;
  }
}
