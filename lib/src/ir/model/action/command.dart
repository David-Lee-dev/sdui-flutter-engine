import 'package:sdui_engine/src/ir/expression.dart';

/// Defines a flow of sequential [Batch] values.
///
/// Each batch completes before the next begins. Action bodies and command
/// handlers share this recursive structure.
typedef Flow = List<Batch>;

/// Defines commands that execute concurrently as one batch.
typedef Batch = List<Command>;

/// Represents a compiled named action with execution steps and deduplication policy.
class Action {
  const Action({required this.steps, this.dedupe = true});

  /// The pipeline of sequential batches containing concurrent commands.
  final Flow steps;

  /// Whether invocations are dropped while this action is already running.
  final bool dedupe;
}

/// Represents one driver invocation and its result handlers.
///
/// Handlers are themselves [Flow] values, allowing command pipelines to compose
/// recursively.
class Command {
  const Command({
    required this.type,
    this.params = const {},
    this.when,
    this.then,
    this.onError,
    this.dismiss,
    this.always,
    this.background = false,
  });

  /// The driver name resolved from the registry at runtime.
  final String type;

  /// Whether the command runs without being awaited or invoking handlers.
  ///
  /// Background failures are ignored. This is command-level so the same driver
  /// can be used in either execution mode.
  final bool background;

  /// The compiled arguments resolved against the environment before invocation.
  final Map<String, Object?> params;

  /// Optional guard expression. When non-null and falsy at run time, the command
  /// and all its handlers are skipped. Null means the command always runs.
  final Expression? when;

  /// The `_then` flow, where the result is exposed as `$data`.
  final Flow? then;

  /// Maps error codes to `_error` flows, using `_` as the default branch.
  final Map<String, Flow>? onError;

  /// The `_dismiss` flow, run when the command signals a user dismissal
  /// (`DriverError.dismissed`, e.g. a modal closed via its backdrop) instead of
  /// succeeding or failing. A dismissal without this handler is a no-op.
  final Flow? dismiss;

  /// The `_always` flow executed after either success or failure.
  final Flow? always;
}
