part of '_base.dart';

/// Selects at most one branch by comparing [selector] with [cases].
///
/// Matching uses `==`. If no case matches, [fallback] is rendered when present;
/// otherwise the directive renders an empty position.
final class SwitchDirective extends Directive {
  const SwitchDirective({
    required this.selector,
    required this.cases,
    this.fallback,
    required this.path,
  });

  /// The compiled expression whose value is compared with case labels.
  final Expression selector;

  /// The literal case labels and their branches, matched using `==`.
  final List<({Object? value, Directive branch})> cases;

  /// The `_default` branch used when no case matches, if present.
  final Directive? fallback;

  /// Returns the binding roots that can change the selected branch.
  Set<String> get roots => selector.roots;

  /// The source node's tree path for diagnostics.
  final String path;
}
