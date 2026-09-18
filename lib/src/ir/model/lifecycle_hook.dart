/// Defines the lifecycle moments that can trigger named scope actions.
///
/// A scope owns scheduling, while action execution resolves through the current
/// scope and its ancestors.
enum LifecycleTrigger {
  /// Triggers during the first dependency initialization, before layout and paint.
  mount,

  /// Triggers after the first frame is painted.
  render,

  /// Triggers when the app resumes or the scope becomes visible again.
  ///
  /// Visibility covers more than the enclosing route becoming current: a route
  /// pushed on an *outer* navigator and a shell branch swapped out by a tab
  /// switch both obscure the scope, and returning from either fires this.
  remount,

  /// Repeats at [LifecycleHook.every] while the scope remains mounted.
  interval,

  /// Triggers immediately before disposal as fire-and-forget work.
  dispose,
}

/// Schedules a named [action] for a lifecycle [trigger].
final class LifecycleHook {
  const LifecycleHook({
    required this.trigger,
    required this.action,
    this.delay = Duration.zero,
    this.every,
  });

  /// The lifecycle moment that initiates the hook.
  final LifecycleTrigger trigger;

  /// The action name resolved through the scope chain at runtime.
  final String action;

  /// The delay applied before firing the action.
  final Duration delay;

  /// The repetition period for [LifecycleTrigger.interval], otherwise `null`.
  final Duration? every;
}
