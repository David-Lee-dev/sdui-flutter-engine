part of '_base.dart';

/// Supplies [child] with an animated local variable named by [as].
///
/// [from], [to], and [trigger] are compiled expressions. A change to [to]
/// transitions from the current value to the new target.
final class MorphDirective extends Directive {
  const MorphDirective({
    required this.to,
    required this.as,
    required this.child,
    required this.path,
    this.from,
    this.durationMs = 400,
    this.curve = 'ease_out',
    this.delayMs = 0,
    this.repeat = false,
    this.reverse = false,
    this.trigger,
  });

  final Expression to;
  final Expression? from;
  final String as;
  final int durationMs;
  final String curve;
  final int delayMs;
  final bool repeat;
  final bool reverse;
  final Expression? trigger;
  final Directive child;
  final String path;

  /// Returns external binding roots used by this directive.
  ///
  /// The locally supplied [as] variable is excluded.
  Set<String> get roots =>
      {...to.roots, ...?from?.roots, ...?trigger?.roots}..remove(as);
}
