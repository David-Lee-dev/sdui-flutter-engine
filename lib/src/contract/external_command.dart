/// The safe surface a fully-external command sees when the engine invokes it.
///
/// Deliberately excludes engine runtime internals (scope state, host,
/// registries): an external service owns its own behavior and returns data — it
/// never mutates engine state directly. Params are already resolved (all `${}`
/// expressions expanded) before the command runs.
class CommandInvocation {
  const CommandInvocation({
    required this.params,
    required this.event,
    required bool Function() isCancelled,
    this.correlationId,
    void Function() Function(void Function())? onDispose,
  }) : _isCancelled = isCancelled,
       _onDispose = onDispose;

  /// The command's resolved parameters.
  final Map<String, Object?> params;

  /// The event payload that started the command, if any.
  final Object? event;

  /// Ties this command to the user action that caused it, for telemetry and
  /// server-side correlation (sent as `x-event-id` by the default protocol).
  final String? correlationId;

  final bool Function() _isCancelled;

  /// Reports whether the scope that started this command has been disposed.
  ///
  /// Commands should check this before irreversible external work; it cannot
  /// cancel work that already crossed a platform or network boundary.
  bool get isCancelled => _isCancelled();

  final void Function() Function(void Function())? _onDispose;

  /// Registers [cleanup] to run when the scope that started this command is
  /// disposed — the release point for subscriptions, listeners, or platform
  /// sessions a command opens.
  ///
  /// Returns a deregistration callback for normal resource closure. When the
  /// engine supplied no lifetime (bare test invocations), registration is a
  /// no-op and the command must manage its resource itself.
  void Function() onDispose(void Function() cleanup) =>
      _onDispose?.call(cleanup) ?? () {};
}

/// Signals the user dismissed or cancelled the operation.
///
/// The engine routes this to the command's `_dismiss` flow and treats it as a
/// normal outcome — never reported as an error.
class CommandDismissed implements Exception {
  const CommandDismissed();
}

/// Signals an expected domain failure the template can branch on.
///
/// [code] selects the command's `_error[code]` flow (`_` is the default
/// branch); [message] and [data] are exposed to that flow as `$error`.
class CommandFailure implements Exception {
  const CommandFailure(this.code, {this.message, this.data});

  final String code;
  final String? message;
  final Object? data;
}

/// A command whose behavior is owned entirely by the app (an external service),
/// registered at boot via [Engine.initialize]. The engine routes to it by
/// [type] and knows nothing else about it.
///
/// The return value becomes the success flow's `$data`. Throw [CommandDismissed]
/// to run the `_dismiss` flow, or [CommandFailure] to select a coded `_error`
/// branch; any other thrown object is reported as an unexpected engine error.
abstract class ExternalCommand {
  const ExternalCommand();

  /// Opt into a reserved, latency-measured telemetry span per run — the same
  /// observability the engine's `net` command gets. Worth `true` for
  /// long-running work (SDK calls, uploads); the default records failures
  /// only.
  bool get measured => false;

  /// The template-facing command type resolved by the driver registry.
  String get type;

  /// Executes the command and returns data exposed to its success flow.
  Future<Object?> run(CommandInvocation invocation);
}
