part of '_base.dart';

/// Renders [child] once for every item produced by [source].
///
/// [as] and [index] name the per-item frame variables. [keyExpression] is
/// required to preserve identity during reconciliation and reordering.
final class LoopDirective extends Directive {
  const LoopDirective({
    required this.source,
    required this.as,
    required this.index,
    required this.keyExpression,
    required this.child,
    required this.path,
    this.wrap = 'column',
    this.wrapParams = const {},
  });

  final Object? source;
  final String as;
  final String index;
  final Expression keyExpression;
  final Directive child;

  /// The `_loop._wrap` container strategy for repeated items.
  ///
  /// The template validator checks the strategy name and render protocol before
  /// the observer dispatches to its concrete container.
  final String wrap;

  /// The compiled parameters for the selected wrap strategy.
  ///
  /// Bindings use the same compiled-value format as widget properties and are
  /// included in [roots] so container configuration remains reactive.
  final Map<String, Object?> wrapParams;

  /// The source node's tree path for runtime diagnostics.
  final String path;

  /// Returns the external binding roots required by the loop.
  ///
  /// Per-item variables are removed only from [keyExpression], where they are
  /// locally defined. They are retained for [source], which is evaluated in the
  /// outer environment even when a variable name overlaps.
  Set<String> get roots => {
    ...CompiledValue.rootsOf({'source': source}),
    ...keyExpression.roots.difference({as, index}),
    // Wrap parameters are resolved outside item frames and therefore keep all
    // of their external dependencies.
    ...CompiledValue.rootsOf(wrapParams),
  };
}
