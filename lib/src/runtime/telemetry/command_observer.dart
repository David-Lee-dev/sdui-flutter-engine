import 'dart:async';

import 'package:sdui_engine/src/ir/model/action/command.dart';

import '../driver/_base.dart';
import '../driver/driver_registry.dart';
import '../widget/contract/action_sink.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'telemetry.dart';

/// Observes command execution for telemetry — the executor's only telemetry
/// surface.
///
/// Whether a command gets a *reserved, latency-measured* span is declared by
/// the driver ([Driver.measured]) — never by a type-name check in the
/// executor. Un-measured commands record only failures. External commands
/// opt in through `ExternalCommand.measured`, which their adapter driver
/// forwards, so an app's long-running command gets the same observability as
/// the engine's own `net`.
final class CommandObserver {
  CommandObserver({required this.screenId, required this.screenViewId});

  /// Screen attribution of the owning scope (mutable — set by the scope on
  /// dependency changes, exactly like the host's own fields).
  String? screenId;
  String? screenViewId;

  /// Begins observing one command run; call [CommandMeasurement.complete]
  /// exactly once with the outcome.
  ///
  /// Returns synchronously for un-measured commands — an executor await here
  /// would insert a microtask boundary and break the synchronous `set`
  /// semantics — and a Future only when the driver declared [Driver.measured]
  /// (the reservation is inherently async).
  FutureOr<CommandMeasurement> begin(
    Command command,
    Map<String, Object?> params,
    ActionInvocation invocation,
    String? branchOrigin,
  ) {
    final measured = DriverRegistry.resolveOrNull(command.type)?.measured;
    final properties = CommandTelemetry.properties(
      type: command.type,
      params: params,
      invocation: invocation,
      branchOrigin: branchOrigin,
    );
    if (measured == true) {
      return Telemetry.reserve(
        'command',
        screenId: screenId,
        screenViewId: screenViewId,
        correlationId: invocation.invocationId,
        properties: properties,
      ).then(
        (reservation) =>
            CommandMeasurement._(reservation: reservation, recordFailure: null),
      );
    }
    return CommandMeasurement._(
      reservation: null,
      recordFailure: (completion) => Telemetry.record(
        'command',
        screenId: screenId,
        screenViewId: screenViewId,
        correlationId: invocation.invocationId,
        properties: {...properties, ...completion},
      ),
    );
  }
}

/// Extracts command telemetry without exposing parameter values.
///
/// Command vocabulary is implementation-owned (the `net` command's request
/// fields belong to the app's `NetworkClient`), so the engine records only
/// shapes — the sorted parameter key list — never values. Apps that want
/// richer request telemetry own the place to add it: their client.
abstract final class CommandTelemetry {
  /// Builds command properties from engine-known structure only.
  static Map<String, Object?> properties({
    required String type,
    required Map<String, Object?> params,
    required ActionInvocation invocation,
    required String? branchOrigin,
  }) {
    return {
      'type': type,
      'origin': invocation.origin,
      'branch_origin': ?branchOrigin,
      'invocation_id': invocation.invocationId,
      'param_keys': params.keys.toList()..sort(),
    };
  }
}

/// One command run's telemetry slot; completed exactly once.
final class CommandMeasurement {
  CommandMeasurement._({
    required this.reservation,
    required this.recordFailure,
  }) : _stopwatch = Stopwatch()..start();

  final TelemetryReservation? reservation;
  final void Function(Map<String, Object?> completion)? recordFailure;
  final Stopwatch _stopwatch;
  bool _completed = false;

  void complete({required String outcome, String? errorCode}) {
    if (_completed) return;
    _completed = true;
    _stopwatch.stop();
    final completion = <String, Object?>{
      'outcome': outcome,
      'error_code': ?errorCode,
      'duration_ms': _stopwatch.elapsedMilliseconds,
    };
    try {
      reservation?.complete(properties: completion);
      if (reservation == null && outcome != 'success') {
        recordFailure?.call(completion);
      }
    } catch (_) {
      // Telemetry is observational and may never alter driver control flow.
    }
  }
}
