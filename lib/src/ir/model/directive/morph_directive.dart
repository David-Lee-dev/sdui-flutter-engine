part of '_base.dart';

/// Supplies [child] with an animated local variable named by [as].
///
/// [from], [to], and [trigger] are compiled expressions. A change to [to]
/// transitions from the current value to the new target. A [spring] replaces
/// the duration/curve tween with a physical simulation. [velocityAs], when
/// set, names a second variable carrying the value's current velocity.
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
    this.spring,
    this.velocityAs,
  });

  final Expression to;
  final Expression? from;
  final String as;

  /// Tween length; `null` takes the settle time of a spring curve name.
  final int? durationMs;

  /// A curve name or a `[x1, y1, x2, y2]` cubic-bezier list.
  final Object curve;
  final int delayMs;
  final bool repeat;
  final bool reverse;
  final Expression? trigger;
  final EngineSpringSpec? spring;

  /// Name of the velocity variable (`_to` units per second), if declared.
  final String? velocityAs;
  final Directive child;
  final String path;

  /// Returns external binding roots used by this directive.
  ///
  /// The locally supplied [as] and [velocityAs] variables are excluded.
  Set<String> get roots => {...to.roots, ...?from?.roots, ...?trigger?.roots}
    ..remove(as)
    ..remove(velocityAs);
}
