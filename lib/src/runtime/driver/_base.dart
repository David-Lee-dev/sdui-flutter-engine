import '../environment/state_writer.dart';
import '../engine_host.dart';
import '../engine_registries.dart';
import '../widget/contract/action_sink.dart';
import 'driver_error.dart';

/// Carries resolved command inputs and mount-scoped capabilities into a [Driver].
class DriverContext {
  const DriverContext({
    required this.params,
    required this.state,
    required bool Function() isCancelled,
    this.event,
    this.invocation,
    this.branchOrigin,
    this.host,
    void Function() Function(void Function())? onOwnerDispose,
  }) : _isCancelled = isCancelled,
       _onOwnerDispose = onOwnerDispose;

  /// Contains command parameters after environment expressions are resolved.
  final Map<String, Object?> params;

  /// Accepts state commits without exposing mutable environment internals.
  final StateWriter state;

  /// Contains the payload supplied by the event that started the command.
  final Object? event;

  /// The action execution that caused this command.
  final ActionInvocation? invocation;

  /// The continuation lane (`then`, `error`, etc.) containing this command.
  final String? branchOrigin;

  /// The request correlation id forwarded by network drivers.
  String? get correlationId => invocation?.invocationId;

  /// Provides optional capabilities owned by the current engine mount.
  final EngineHost? host;

  /// Returns the mount’s element registries, if the command runs in an engine.
  EngineRegistries? get registries => host?.registries;

  /// Returns modal templates visible to the current engine mount.
  Map<String, Object?> get modalTemplates => host?.modalTemplates ?? const {};

  final bool Function() _isCancelled;

  final void Function() Function(void Function())? _onOwnerDispose;

  /// Reports whether the scope that started this command has been disposed.
  ///
  /// Drivers should check this before irreversible external work. It cannot
  /// cancel an operation that has already crossed a platform or network boundary.
  bool get isCancelled => _isCancelled();

  /// Registers [cleanup] for the lifetime of the command’s owning scope.
  ///
  /// The returned callback deregisters [cleanup] after normal resource closure.
  /// If the owner is already gone, [cleanup] runs immediately.
  void Function() onOwnerDispose(void Function() cleanup) =>
      _onOwnerDispose?.call(cleanup) ?? () {};
}

/// Defines an executable command adapter selected by its template-facing [type].
abstract class Driver {
  const Driver();

  /// Returns the command type resolved by [DriverRegistry].
  String get type;

  /// Executes a command and returns data exposed to its success flow.
  ///
  /// Expected domain failures should be reported as [DriverError] so actions can
  /// select a matching error branch.
  Future<Object?> run(DriverContext ctx);
}
