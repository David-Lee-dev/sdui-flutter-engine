import 'package:sdui_engine/src/contract/external_command.dart';

import '_base.dart';
import 'driver_error.dart';

/// Adapts an app-registered [ExternalCommand] to the internal [Driver] surface.
///
/// Builds a narrowed [CommandInvocation] from the [DriverContext] (params, event,
/// cancellation, and scope-lifetime cleanup — never state/host/registries) and maps the
/// command's contract-level signals onto [DriverError]: [CommandDismissed] →
/// [DriverError.dismissed], [CommandFailure] → a coded [DriverError]. Any other
/// throw propagates unchanged for the action host to report.
class ExternalDriver extends Driver {
  const ExternalDriver(this._command);

  final ExternalCommand _command;

  @override
  String get type => _command.type;

  @override
  bool get measured => _command.measured;

  @override
  Future<Object?> run(DriverContext ctx) async {
    final invocation = CommandInvocation(
      params: ctx.params,
      event: ctx.event,
      isCancelled: () => ctx.isCancelled,
      correlationId: ctx.correlationId,
      onDispose: ctx.onOwnerDispose,
    );
    try {
      return await _command.run(invocation);
    } on CommandDismissed {
      throw const DriverError(DriverError.dismissed);
    } on CommandFailure catch (e) {
      throw DriverError(e.code, e.message, e.data);
    }
  }
}
