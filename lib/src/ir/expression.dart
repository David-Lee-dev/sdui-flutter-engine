/// Compiles the expression subset used by template bindings.
///
/// The grammar includes short-circuit logic, chained comparisons, membership,
/// null coalescing, arithmetic, calls, traversal, slicing, literals, and list
/// comprehensions. Missing traversal data yields `null`, while invalid arithmetic
/// and syntax raise [FormatException].
final class Expression {
  Expression._(this.source, this.ast, this.roots);

  final String source;

  final Expr ast;

  final Set<String> roots;

  /// Parses [source] once and records its exact binding-root dependencies.
  ///
  /// Throws a [FormatException] when [source] violates the grammar.
  factory Expression.compile(String source) {
    final ast = _Parser(_lex(source), source).parse();
    final roots = <String>{};
    ast.collectRoots(roots);
    return Expression._(source, ast, Set.unmodifiable(roots));
  }

  /// Returns the root only when the entire expression is a bare binding.
  ///
  /// This stricter test prevents write-back features from overwriting a root with
  /// the result of a path, index, filter, or computed expression.
  String? get bareBindingKey => switch (ast) {
    BindingExpr(:final root) => root,
    _ => null,
  };
}

/// Holds literal fragments and compiled [Expression] fragments.
///
/// Unlike a standalone expression, interpolation always returns a string and
/// renders `null` fragments as empty text.
final class Interpolation {
  const Interpolation(this.parts);

  final List<Object?> parts;

  Set<String> get roots {
    final out = <String>{};
    for (final part in parts) {
      if (part is Expression) out.addAll(part.roots);
    }
    return out;
  }
}

Never _error(String message) => throw FormatException(message);

sealed class Expr {
  const Expr();
  void collectRoots(Set<String> out);
}

final class LiteralExpr extends Expr {
  const LiteralExpr(this.value);
  final Object? value;
  @override
  void collectRoots(Set<String> out) {}
}

final class BindingExpr extends Expr {
  const BindingExpr(this.root);
  final String root;
  @override
  void collectRoots(Set<String> out) => out.add(root);
}

final class PropertyExpr extends Expr {
  const PropertyExpr(this.target, this.name);
  final Expr target;
  final String name;

  @override
  void collectRoots(Set<String> out) => target.collectRoots(out);
}

final class IndexExpr extends Expr {
  const IndexExpr(this.target, this.index);
  final Expr target;
  final Expr index;

  @override
  void collectRoots(Set<String> out) {
    target.collectRoots(out);
    index.collectRoots(out);
  }
}

final class UnaryExpr extends Expr {
  const UnaryExpr(this.op, this.operand);
  final String op;
  final Expr operand;

  @override
  void collectRoots(Set<String> out) => operand.collectRoots(out);
}

final class BinaryExpr extends Expr {
  const BinaryExpr(this.op, this.left, this.right);
  final String op;
  final Expr left;
  final Expr right;
  @override
  void collectRoots(Set<String> out) {
    left.collectRoots(out);
    right.collectRoots(out);
  }
}

final class LogicalExpr extends Expr {
  const LogicalExpr(this.op, this.left, this.right);
  final String op;
  final Expr left;
  final Expr right;

  @override
  void collectRoots(Set<String> out) {
    left.collectRoots(out);
    right.collectRoots(out);
  }
}

final class ComparisonExpr extends Expr {
  const ComparisonExpr(this.first, this.rest);
  final Expr first;
  final List<({String op, Expr operand})> rest;

  @override
  void collectRoots(Set<String> out) {
    first.collectRoots(out);
    for (final link in rest) {
      link.operand.collectRoots(out);
    }
  }
}

final class TernaryExpr extends Expr {
  const TernaryExpr(this.cond, this.then, this.orElse);
  final Expr cond;
  final Expr then;
  final Expr orElse;

  @override
  void collectRoots(Set<String> out) {
    cond.collectRoots(out);
    then.collectRoots(out);
    orElse.collectRoots(out);
  }
}

final class NullCoalesceExpr extends Expr {
  const NullCoalesceExpr(this.left, this.right);
  final Expr left;
  final Expr right;

  @override
  void collectRoots(Set<String> out) {
    left.collectRoots(out);
    right.collectRoots(out);
  }
}

final class InExpr extends Expr {
  const InExpr(this.left, this.right, {required this.negate});
  final Expr left;
  final Expr right;
  final bool negate;

  @override
  void collectRoots(Set<String> out) {
    left.collectRoots(out);
    right.collectRoots(out);
  }
}

final class ListLiteralExpr extends Expr {
  const ListLiteralExpr(this.elements);
  final List<Expr> elements;

  @override
  void collectRoots(Set<String> out) {
    for (final e in elements) {
      e.collectRoots(out);
    }
  }
}

final class MapLiteralExpr extends Expr {
  const MapLiteralExpr(this.entries);
  final List<(Expr key, Expr value)> entries;

  @override
  void collectRoots(Set<String> out) {
    for (final e in entries) {
      e.$1.collectRoots(out);
      e.$2.collectRoots(out);
    }
  }
}

final class SliceExpr extends Expr {
  const SliceExpr(this.target, this.start, this.stop, this.step);
  final Expr target;
  final Expr? start;
  final Expr? stop;
  final Expr? step;

  @override
  void collectRoots(Set<String> out) {
    target.collectRoots(out);
    start?.collectRoots(out);
    stop?.collectRoots(out);
    step?.collectRoots(out);
  }
}

final class CallExpr extends Expr {
  const CallExpr(this.name, this.args);
  final String name;
  final List<Expr> args;

  @override
  void collectRoots(Set<String> out) {
    for (final a in args) {
      a.collectRoots(out);
    }
  }
}

final class ComprehensionExpr extends Expr {
  const ComprehensionExpr(this.varName, this.iter, this.expr, this.cond);
  final String varName;
  final Expr iter;
  final Expr expr;
  final Expr? cond;

  @override
  void collectRoots(Set<String> out) {
    iter.collectRoots(out);
    final inner = <String>{};
    expr.collectRoots(inner);
    cond?.collectRoots(inner);
    inner.remove(varName);
    out.addAll(inner);
  }
}

enum _Tok { number, string, word, op, eof }

final class _Token {
  const _Token(this.kind, [this.value]);
  final _Tok kind;
  final Object? value;
}

const _cmpOps = {'==', '!=', '<', '<=', '>', '>='};

bool _isDigit(int c) => c >= 0x30 && c <= 0x39;
bool _isHexDigit(int c) =>
    _isDigit(c) || (c | 0x20) >= 0x61 && (c | 0x20) <= 0x66;
bool _isIdentStart(int c) =>
    c == 0x5f || (c | 0x20) >= 0x61 && (c | 0x20) <= 0x7a;
bool _isIdentPart(int c) => _isIdentStart(c) || _isDigit(c);

List<_Token> _lex(String src) {
  final tokens = <_Token>[];
  var i = 0;
  int at(int k) => k >= 0 && k < src.length ? src.codeUnitAt(k) : -1;
  while (i < src.length) {
    final c = src.codeUnitAt(i);
    if (c == 0x20 || c == 0x09 || c == 0x0a || c == 0x0d) {
      i++;
      continue;
    }
    if (_isDigit(c) || (c == 0x2e && _isDigit(at(i + 1)))) {
      final start = i;
      if (c == 0x30 && (at(i + 1) == 0x78 || at(i + 1) == 0x58)) {
        i += 2;
        final hexStart = i;
        while (i < src.length &&
            (_isHexDigit(src.codeUnitAt(i)) || src.codeUnitAt(i) == 0x5f)) {
          i++;
        }
        final hexText = src.substring(hexStart, i).replaceAll('_', '');
        if (hexText.isEmpty) _error('malformed hex literal in: "$src"');
        tokens.add(_Token(_Tok.number, int.parse(hexText, radix: 16)));
        continue;
      }
      bool isDigitOrSep(int k) => _isDigit(k) || k == 0x5f;
      if (c == 0x2e) {
        i++;
        while (i < src.length && isDigitOrSep(src.codeUnitAt(i))) {
          i++;
        }
      } else {
        while (i < src.length && isDigitOrSep(src.codeUnitAt(i))) {
          i++;
        }
        if (at(i) == 0x2e && _isDigit(at(i + 1))) {
          i++;
          while (i < src.length && isDigitOrSep(src.codeUnitAt(i))) {
            i++;
          }
        }
      }
      if (at(i) == 0x65 || at(i) == 0x45) {
        i++;
        if (at(i) == 0x2b || at(i) == 0x2d) i++;
        if (!_isDigit(at(i))) _error('malformed exponent in: "$src"');
        while (i < src.length && _isDigit(src.codeUnitAt(i))) {
          i++;
        }
      }
      final text = src.substring(start, i).replaceAll('_', '');
      final value =
          (text.contains('.') || text.contains('e') || text.contains('E'))
          ? double.parse(text)
          : int.parse(text);
      tokens.add(_Token(_Tok.number, value));
      continue;
    }
    if (c == 0x22 || c == 0x27) {
      i = _lexString(src, i, c, tokens);
      continue;
    }
    if (_isIdentStart(c)) {
      final start = i;
      while (i < src.length && _isIdentPart(src.codeUnitAt(i))) {
        i++;
      }
      tokens.add(_Token(_Tok.word, src.substring(start, i)));
      continue;
    }
    final two = i + 1 < src.length ? src.substring(i, i + 2) : '';
    if (const {'==', '!=', '<=', '>=', '??', '//', '**'}.contains(two)) {
      tokens.add(_Token(_Tok.op, two));
      i += 2;
      continue;
    }
    final one = src[i];
    if (const {
      '<',
      '>',
      '+',
      '-',
      '*',
      '/',
      '%',
      '(',
      ')',
      '[',
      ']',
      '.',
      '?',
      ':',
      '{',
      '}',
      ',',
    }.contains(one)) {
      tokens.add(_Token(_Tok.op, one));
      i++;
      continue;
    }
    _error('unexpected character "$one" in: "$src"');
  }
  tokens.add(const _Token(_Tok.eof));
  return tokens;
}

int _lexString(String src, int start, int quote, List<_Token> tokens) {
  final buf = StringBuffer();
  var i = start + 1;
  while (i < src.length && src.codeUnitAt(i) != quote) {
    final ch = src.codeUnitAt(i);
    if (ch == 0x0a || ch == 0x0d) {
      _error('unterminated string (line break) in: "$src"');
    }
    if (ch != 0x5c) {
      buf.writeCharCode(ch);
      i++;
      continue;
    }
    i++;
    if (i >= src.length) _error('trailing backslash in: "$src"');
    final esc = src[i];
    switch (esc) {
      case '\\':
        buf.write('\\');
      case '"':
        buf.write('"');
      case "'":
        buf.write("'");
      case 'n':
        buf.write('\n');
      case 'r':
        buf.write('\r');
      case 't':
        buf.write('\t');
      case 'b':
        buf.write('\b');
      case 'f':
        buf.write('\f');
      case 'u':
        i = _lexUnicode(src, i + 1, buf) - 1;
      default:
        _error('unknown escape "\\$esc" in: "$src"');
    }
    i++;
  }
  if (i >= src.length) _error('unterminated string in: "$src"');
  tokens.add(_Token(_Tok.string, buf.toString()));
  return i + 1;
}

int _lexUnicode(String src, int i, StringBuffer buf) {
  String hex;
  int next;
  if (i < src.length && src[i] == '{') {
    final start = i + 1;
    var j = start;
    while (j < src.length && src[j] != '}') {
      j++;
    }
    if (j >= src.length || j == start) _error('malformed \\u{...} in: "$src"');
    hex = src.substring(start, j);
    next = j + 1;
  } else {
    if (i + 4 > src.length) _error('malformed \\uXXXX in: "$src"');
    hex = src.substring(i, i + 4);
    next = i + 4;
  }
  final code = int.tryParse(hex, radix: 16);
  if (code == null || code < 0 || code > 0x10ffff) {
    _error('invalid unicode escape "\\u$hex" in: "$src"');
  }
  buf.writeCharCode(code);
  return next;
}

final class _Parser {
  _Parser(this.tokens, this.source);
  final List<_Token> tokens;
  final String source;
  int _pos = 0;
  int _depth = 0;

  static const _maxDepth = 128;

  _Token get _cur => tokens[_pos];
  bool _op(String o) => _cur.kind == _Tok.op && _cur.value == o;
  bool _word(String w) => _cur.kind == _Tok.word && _cur.value == w;

  _Token _peek(int k) {
    final idx = _pos + k;
    return idx < tokens.length ? tokens[idx] : tokens.last;
  }

  bool _peekWord(int k, String w) =>
      _peek(k).kind == _Tok.word && _peek(k).value == w;

  T _nest<T>(T Function() f) {
    if (_depth >= _maxDepth) {
      _error('expression too deeply nested (>$_maxDepth) in: "$source"');
    }
    _depth++;
    try {
      return f();
    } finally {
      _depth--;
    }
  }

  Expr parse() {
    final e = _ternary();
    if (_cur.kind != _Tok.eof) {
      _error('unexpected "${_cur.value}" in: "$source"');
    }
    return e;
  }

  Expr _ternary() {
    final cond = _nullCoalesce();
    if (!_op('?')) return cond;
    _pos++;
    final then = _nest(_ternary);
    if (!_op(':')) _error('expected ":" in ternary in: "$source"');
    _pos++;
    final orElse = _nest(_ternary);
    return TernaryExpr(cond, then, orElse);
  }

  Expr _nullCoalesce() {
    final left = _or();
    if (!_op('??')) return left;
    _pos++;
    return NullCoalesceExpr(left, _nest(_nullCoalesce));
  }

  Expr _or() {
    var l = _and();
    while (_word('or')) {
      _pos++;
      l = LogicalExpr('or', l, _and());
    }
    return l;
  }

  Expr _and() {
    var l = _not();
    while (_word('and')) {
      _pos++;
      l = LogicalExpr('and', l, _not());
    }
    return l;
  }

  Expr _not() {
    if (_word('not')) {
      _pos++;
      return UnaryExpr('not', _nest(_not));
    }
    return _comparison();
  }

  Expr _comparison() {
    final first = _additive();
    if (_word('not') && _peekWord(1, 'in')) {
      _pos += 2;
      return InExpr(first, _additive(), negate: true);
    }
    if (_word('in')) {
      _pos++;
      return InExpr(first, _additive(), negate: false);
    }
    final rest = <({String op, Expr operand})>[];
    while (_cur.kind == _Tok.op && _cmpOps.contains(_cur.value)) {
      final op = _cur.value! as String;
      _pos++;
      rest.add((op: op, operand: _additive()));
    }
    return rest.isEmpty ? first : ComparisonExpr(first, rest);
  }

  Expr _additive() {
    var l = _multiplicative();
    while (_op('+') || _op('-')) {
      final op = _cur.value! as String;
      _pos++;
      l = BinaryExpr(op, l, _multiplicative());
    }
    return l;
  }

  Expr _multiplicative() {
    var l = _unary();
    while (_op('*') || _op('/') || _op('//') || _op('%')) {
      final op = _cur.value! as String;
      _pos++;
      l = BinaryExpr(op, l, _unary());
    }
    return l;
  }

  Expr _unary() {
    if (_op('+') || _op('-')) {
      final op = _cur.value! as String;
      _pos++;
      return UnaryExpr(op, _nest(_unary));
    }
    return _power();
  }

  // Power binds tighter than a leading sign, but its right operand accepts a
  // sign. Thus `-2 ** 2` is `-(2 ** 2)` while `2 ** -2` remains valid.
  Expr _power() {
    final left = _postfix();
    if (!_op('**')) return left;
    _pos++;
    return BinaryExpr('**', left, _nest(_unary));
  }

  Expr _postfix() {
    var e = _primary();
    while (true) {
      if (_op('.')) {
        _pos++;
        if (_cur.kind != _Tok.word) {
          _error('expected a property name after "." in: "$source"');
        }
        e = PropertyExpr(e, _cur.value! as String);
        _pos++;
      } else if (_op('[')) {
        _pos++;
        e = _indexOrSlice(e);
      } else {
        return e;
      }
    }
  }

  Expr _indexOrSlice(Expr target) {
    Expr? start;
    if (!_op(':') && !_op(']')) start = _nest(_ternary);
    if (!_op(':')) {
      if (start == null) _error('expected index expression in: "$source"');
      if (!_op(']')) _error('expected "]" in: "$source"');
      _pos++;
      return IndexExpr(target, start);
    }
    _pos++;
    Expr? stop;
    if (!_op(':') && !_op(']')) stop = _nest(_ternary);
    Expr? step;
    if (_op(':')) {
      _pos++;
      if (!_op(']')) step = _nest(_ternary);
    }
    if (!_op(']')) _error('expected "]" in slice: "$source"');
    _pos++;
    return SliceExpr(target, start, stop, step);
  }

  Expr _primary() {
    final t = _cur;
    switch (t.kind) {
      case _Tok.number:
      case _Tok.string:
        _pos++;
        return LiteralExpr(t.value);
      case _Tok.word:
        return switch (t.value) {
          'true' => _consumeLiteral(true),
          'false' => _consumeLiteral(false),
          'null' => _consumeLiteral(null),
          'and' ||
          'or' ||
          'not' => _error('unexpected keyword "${t.value}" in: "$source"'),
          final String w when w.startsWith('_') => _error(
            'binding root must not start with "_" (reserved) in: "$source"',
          ),
          final String w => _identifierOrCall(w),
          _ => _error('unexpected token in: "$source"'),
        };
      case _Tok.op:
        if (_op('(')) {
          _pos++;
          final e = _nest(_ternary);
          if (!_op(')')) _error('expected ")" in: "$source"');
          _pos++;
          return e;
        }
        if (_op('[')) {
          _pos++;
          return _listLiteralOrComprehension();
        }
        if (_op('{')) {
          _pos++;
          return _mapLiteral();
        }
        return _error('unexpected "${t.value}" in: "$source"');
      case _Tok.eof:
        return _error('unexpected end of expression: "$source"');
    }
  }

  Expr _consumeLiteral(Object? value) {
    _pos++;
    return LiteralExpr(value);
  }

  Expr _identifierOrCall(String name) {
    _pos++;
    if (!_op('(')) return BindingExpr(name);
    _pos++;
    final args = <Expr>[];
    if (!_op(')')) {
      args.add(_nest(_ternary));
      while (_op(',')) {
        _pos++;
        if (_op(')')) break;
        args.add(_nest(_ternary));
      }
    }
    if (!_op(')')) _error('expected ")" in: "$source"');
    _pos++;
    return CallExpr(name, args);
  }

  Expr _listLiteralOrComprehension() {
    if (_op(']')) {
      _pos++;
      return const ListLiteralExpr([]);
    }
    final first = _nest(_ternary);
    if (_word('for')) {
      _pos++;
      if (_cur.kind != _Tok.word) {
        _error('expected a loop variable after "for" in: "$source"');
      }
      final varName = _cur.value! as String;
      if (varName.startsWith('_')) {
        _error(
          'comprehension variable must not start with "_" (reserved) in: "$source"',
        );
      }
      _pos++;
      if (!_word('in')) _error('expected "in" in comprehension in: "$source"');
      _pos++;
      final iter = _nest(_ternary);
      Expr? cond;
      if (_word('if')) {
        _pos++;
        cond = _nest(_ternary);
      }
      if (!_op(']')) {
        _error('expected "]" to close comprehension in: "$source"');
      }
      _pos++;
      return ComprehensionExpr(varName, iter, first, cond);
    }
    final elements = <Expr>[first];
    while (_op(',')) {
      _pos++;
      if (_op(']')) break;
      elements.add(_nest(_ternary));
    }
    if (!_op(']')) _error('expected "]" in: "$source"');
    _pos++;
    return ListLiteralExpr(elements);
  }

  Expr _mapLiteral() {
    if (_op('}')) {
      _pos++;
      return const MapLiteralExpr([]);
    }
    final entries = <(Expr, Expr)>[];
    while (true) {
      final key = _nest(_ternary);
      if (!_op(':')) _error('expected ":" in map literal in: "$source"');
      _pos++;
      final value = _nest(_ternary);
      entries.add((key, value));
      if (!_op(',')) break;
      _pos++;
      if (_op('}')) break;
    }
    if (!_op('}')) _error('expected "}" in: "$source"');
    _pos++;
    return MapLiteralExpr(entries);
  }
}
