part of '_base.dart';

/// Renders the first branch whose predicate evaluates to true.
///
/// If no predicate matches, [fallback] is rendered when present; otherwise the
/// directive renders an empty position. Predicates are compiled expressions and
/// are evaluated only during interpretation.
final class ConditionDirective extends Directive {
  const ConditionDirective({
    required this.branches,
    this.fallback,
    required this.path,
  });

  /// The ordered predicate/body pairs, with the first true predicate winning.
  final List<({Expression predicate, Directive body})> branches;

  /// The `_else` body rendered when no branch matches, if present.
  final Directive? fallback;

  /// The source node's tree path for diagnostics.
  final String path;

  /// Returns every binding root that can affect branch selection.
  ///
  /// All predicates are included regardless of short-circuiting because a
  /// change to any predicate may select a different branch.
  Set<String> get roots => {
    for (final branch in branches) ...branch.predicate.roots,
  };
}
