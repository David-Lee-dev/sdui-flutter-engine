import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';

/// Builds a compiled [Directive] into widgets without importing the builder.
///
/// Catalog widgets that mount nested compiled content (`anchor_scope`'s
/// flyable items) sit *below* the interpreter in the import graph — the
/// factory registers them, the interpreter's `NodeBuilder` builds through
/// the factory, so reaching up for `NodeBuilder` directly would close an
/// import cycle. The runner installs the concrete builder here on first
/// mount; nested content only ever builds under a mounted engine.
abstract final class DirectiveSubtree {
  /// Installed by `EngineRunner` (first mount wins; they are equivalent).
  static Widget Function(Directive directive)? builder;

  /// Builds [directive] into a widget subtree.
  static Widget mount(Directive directive) {
    final build = builder;
    if (build == null) {
      throw StateError(
        'DirectiveSubtree.builder not installed — nested compiled content '
        'can only build under a running EngineRunner.',
      );
    }
    return build(directive);
  }
}
