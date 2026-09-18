import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:sdui_engine/src/dependency/telemetry_sink.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import '../../environment/_base.dart';
import '../../environment/map_environment.dart';
import '../../environment/scope/scope_environment.dart';
import '../../interpreter/expression_evaluator.dart';
import '../../driver/_base.dart';
import '../../driver/driver_error.dart';
import '../../driver/driver_registry.dart';
import '../../engine_host.dart';
import '../../log/engine_log.dart';
import '../../telemetry/telemetry.dart';
import '../../widget/contract/action_sink.dart';

/// Runs a scope’s compiled actions against its state and host capabilities.
///
/// Batches run sequentially while commands within a batch run concurrently.
/// Separate invocations may overlap; actions marked for deduplication suppress
/// only another invocation of the same name until its foreground flow ends.
/// Background commands deliberately do not extend that interval because their
/// futures may represent long-lived services rather than actionable work.
final class ActionHost implements ActionSink {
  ActionHost({required this.actions, required this.env, this.parent});

  Map<String, Action> actions;

  final ScopeEnvironment env;

  ActionHost? parent;

  EngineHost? host;

  String? screenId;

  String? screenViewId;

  final Set<String> _inflight = {};

  // Drivers register resources whose lifetime belongs to this mounted scope.
  final List<void Function()> _disposalCallbacks = [];

  bool _disposed = false;

  void Function() _registerDisposal(void Function() cleanup) {
    // Late registration must not resurrect a resource after owner disposal.
    if (_disposed) {
      cleanup();
      return () {};
    }
    _disposalCallbacks.add(cleanup);
    return () => _disposalCallbacks.remove(cleanup);
  }

  @override
  /// Starts [name] without waiting for its foreground flow to complete.
  ///
  /// Unknown names are offered to [parent]. When [event] is provided, commands
  /// can resolve it from the temporary `event` environment entry.
  void handle(String name, {Object? event, ActionInvocation? invocation}) {
    if (_disposed) return;
    final current =
        invocation ??
        ActionInvocation(
          invocationId: Telemetry.newId(),
          origin: ActionOrigin.background,
        );
    final action = actions[name];
    if (action == null) {
      parent?.handle(name, event: event, invocation: current);
      return;
    }
    final readEnv = event == null ? env : _shadow(env, {'event': event});
    if (action.dedupe) {
      if (_inflight.contains(name)) {
        EngineLog.action.deduped(name);
        return;
      }
      _inflight.add(name);
      unawaited(
        _runLogged(
          name,
          () => _runFlow(action.steps, readEnv, <Future<void>>[], current),
        ).whenComplete(() => _inflight.remove(name)),
      );
    } else {
      unawaited(
        _runLogged(
          name,
          () => _runFlow(action.steps, readEnv, <Future<void>>[], current),
        ),
      );
    }
  }

  @override
  /// Runs [name] until its foreground flow completes.
  ///
  /// This entry point omits deduplication so widgets that already serialize
  /// calls, such as refresh controls, can await their own invocation.
  Future<void> handleAwaitable(
    String name, {
    Object? event,
    ActionInvocation? invocation,
  }) async {
    if (_disposed) return;
    final current =
        invocation ??
        ActionInvocation(
          invocationId: Telemetry.newId(),
          origin: ActionOrigin.background,
        );
    final action = actions[name];
    if (action == null) {
      if (parent != null) {
        await parent!.handleAwaitable(name, event: event, invocation: current);
      }
      return;
    }
    final readEnv = event == null ? env : _shadow(env, {'event': event});
    await _runLogged(
      name,
      () => _runFlow(action.steps, readEnv, <Future<void>>[], current),
    );
  }

  Future<void> _runLogged(String name, Future<void> Function() run) async {
    if (!kDebugMode) {
      await run();
      return;
    }
    final sw = Stopwatch()..start();
    EngineLog.action.start(name);
    try {
      await run();
    } finally {
      EngineLog.action.done(name, sw.elapsed);
    }
  }

  Future<void> _runFlow(
    Flow flow,
    Environment readEnv,
    List<Future<void>> background,
    ActionInvocation invocation, {
    String? branchOrigin,
  }) async {
    for (final batch in flow) {
      // A completed driver cannot be cancelled, but its continuations can.
      if (_disposed) return;
      await Future.wait(
        batch.map(
          (command) => _runCommand(
            command,
            readEnv,
            background,
            invocation,
            branchOrigin: branchOrigin,
          ),
        ),
      );
    }
  }

  DriverContext _context(
    Map<String, Object?> params,
    ActionInvocation invocation,
    String? branchOrigin,
  ) => DriverContext(
    params: params,
    state: env,
    isCancelled: () => _disposed,
    invocation: invocation,
    branchOrigin: branchOrigin,
    host: host,
    onOwnerDispose: _registerDisposal,
  );

  Future<void> _runCommand(
    Command command,
    Environment readEnv,
    List<Future<void>> background,
    ActionInvocation invocation, {
    String? branchOrigin,
  }) async {
    if (_disposed) return;
    final guard = command.when;
    if (guard != null) {
      bool pass;
      try {
        pass = ExpressionEvaluator.evaluateTruthy(guard, readEnv);
      } catch (error, stack) {
        _report(error, stack);
        return;
      }
      if (!pass) return;
    }
    if (command.background) {
      background.add(_fireBackground(command, readEnv, invocation));
      return;
    }
    try {
      try {
        Object? data;
        var ok = true;
        final params = ExpressionEvaluator.resolveMap(command.params, readEnv);
        final ctx = _context(params, invocation, branchOrigin);
        final measurement = command.type == 'api'
            ? await _startMeasurement(command, params, invocation, branchOrigin)
            : _failureMeasurement(command, params, invocation, branchOrigin);
        try {
          data = await DriverRegistry.resolve(command.type).run(ctx);
          measurement.complete(outcome: _disposed ? 'cancelled' : 'success');
        } catch (error, stack) {
          ok = false;
          measurement.complete(
            outcome: _outcome(error),
            errorCode: error is DriverError ? error.code : null,
          );
          if (error is DriverError && error.code == DriverError.dismissed) {
            // A dismissal is a normal outcome, not a failure: run `_dismiss` if
            // present, otherwise no-op (never routed to `_error` or reported).
            if (command.dismiss != null) {
              await _runFlow(
                command.dismiss!,
                readEnv,
                background,
                invocation,
                branchOrigin: ActionOrigin.dismiss,
              );
            }
          } else if (error is DriverError &&
              error.code == DriverError.handled) {
            // The shared gateway boundary already dealt with this failure
            // globally (token cleared, user routed, notice shown). Routing it
            // to `_error` too would duplicate that handling per scope.
          } else {
            final branch = _pickOnError(command.onError, error);
            if (branch != null) {
              await _runFlow(
                branch,
                _shadow(readEnv, {'error': _errorData(error)}),
                background,
                invocation,
                branchOrigin: ActionOrigin.error,
              );
            } else {
              _report(error, stack);
            }
          }
        }
        if (ok && command.then != null) {
          await _runFlow(
            command.then!,
            _shadow(readEnv, {'data': data}),
            background,
            invocation,
            branchOrigin: ActionOrigin.then,
          );
        }
      } finally {
        if (command.always != null && !_disposed) {
          await _runFlow(
            command.always!,
            readEnv,
            background,
            invocation,
            branchOrigin: ActionOrigin.always,
          );
        }
      }
    } catch (error, stack) {
      // Handler and normalization failures must not escape the action queue.
      _report(error, stack);
    }
  }

  Future<void> _fireBackground(
    Command command,
    Environment readEnv,
    ActionInvocation invocation,
  ) async {
    _CommandMeasurement? measurement;
    try {
      final params = ExpressionEvaluator.resolveMap(command.params, readEnv);
      measurement = command.type == 'api'
          ? await _startMeasurement(
              command,
              params,
              invocation,
              ActionOrigin.background,
            )
          : _failureMeasurement(
              command,
              params,
              invocation,
              ActionOrigin.background,
            );
      final ctx = _context(params, invocation, ActionOrigin.background);
      await DriverRegistry.resolve(command.type).run(ctx);
      measurement.complete(outcome: _disposed ? 'cancelled' : 'success');
    } catch (error, stack) {
      measurement?.complete(
        outcome: _outcome(error),
        errorCode: error is DriverError ? error.code : null,
      );
      _reportBackground(error, stack);
    }
  }

  Future<_CommandMeasurement> _startMeasurement(
    Command command,
    Map<String, Object?> params,
    ActionInvocation invocation,
    String? branchOrigin,
  ) async {
    final properties = CommandTelemetry.properties(
      type: command.type,
      params: params,
      invocation: invocation,
      branchOrigin: branchOrigin,
    );
    final reservation = await Telemetry.reserve(
      'command',
      screenId: screenId,
      screenViewId: screenViewId,
      correlationId: invocation.invocationId,
      properties: properties,
    );
    return _CommandMeasurement(reservation: reservation, recordFailure: null);
  }

  _CommandMeasurement _failureMeasurement(
    Command command,
    Map<String, Object?> params,
    ActionInvocation invocation,
    String? branchOrigin,
  ) {
    final properties = CommandTelemetry.properties(
      type: command.type,
      params: params,
      invocation: invocation,
      branchOrigin: branchOrigin,
    );
    return _CommandMeasurement(
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

  static String _outcome(Object error) {
    if (error is DriverError && error.code == DriverError.dismissed) {
      return 'dismissed';
    }
    if (error is DriverError && error.code == DriverError.handled) {
      return 'handled';
    }
    return 'error';
  }

  Flow? _pickOnError(Map<String, Flow>? onError, Object error) {
    if (onError == null) return null;
    if (error is DriverError && onError.containsKey(error.code)) {
      return onError[error.code];
    }
    return onError['_'];
  }

  Map<String, Object?> _errorData(Object error) {
    if (error is DriverError) {
      return {'code': error.code, 'message': error.message, 'data': error.data};
    }
    String message;
    try {
      message = error.toString();
    } catch (_) {
      message = error.runtimeType.toString();
    }
    return {'code': null, 'message': message};
  }

  Environment _shadow(Environment base, Map<String, Object?> vars) =>
      MapEnvironment(vars, parent: base);

  void _reportBackground(Object error, StackTrace stack) {
    // Expected domain failures have no consumer in a fire-and-forget lane.
    if (error is DriverError) return;
    _report(error, stack);
  }

  void _report(Object error, StackTrace stack) {
    EngineLog.error(error, stack);
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'engine',
        context: ErrorDescription('running an action command'),
      ),
    );
  }

  /// Invalidates future continuations and releases scope-owned resources.
  ///
  /// Cleanup callbacks run after invalidation so any work they trigger sees a
  /// cancelled owner and cannot enqueue new action effects.
  void dispose() {
    _disposed = true;
    final callbacks = List.of(_disposalCallbacks);
    _disposalCallbacks.clear();
    for (final cb in callbacks) {
      try {
        cb();
      } catch (error, stack) {
        _report(error, stack);
      }
    }
  }
}

/// Extracts command telemetry without exposing arbitrary variable values.
abstract final class CommandTelemetry {
  /// Variable keys whose scalar values may leave the engine boundary.
  static const Set<String> variableAllowlist = {
    'partnerId',
    'productId',
    'shopId',
    'missionId',
    'adLogId',
    'externalId',
    'ticketCount',
    'order',
    'side',
    'currency',
  };

  /// Builds command properties while discarding every non-allowlisted value.
  static Map<String, Object?> properties({
    required String type,
    required Map<String, Object?> params,
    required ActionInvocation invocation,
    required String? branchOrigin,
  }) {
    final rawVariables = params['variables'];
    final variables = rawVariables is Map
        ? rawVariables.map((key, value) => MapEntry('$key', value))
        : const <String, Object?>{};
    final keys = variables.keys.toList()..sort();
    final allowed = <String, Object?>{};
    for (final key in keys) {
      final value = variables[key];
      if (variableAllowlist.contains(key) &&
          (value is String || value is num)) {
        allowed[key] = value;
      }
    }
    return {
      'type': type,
      if (params['query'] is String) 'query_id': params['query'],
      'origin': invocation.origin,
      if (branchOrigin != null) 'branch_origin': branchOrigin,
      'invocation_id': invocation.invocationId,
      'var_keys': keys,
      'vars': allowed,
    };
  }
}

final class _CommandMeasurement {
  _CommandMeasurement({required this.reservation, required this.recordFailure})
    : _stopwatch = Stopwatch()..start();

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
      if (errorCode != null) 'error_code': errorCode,
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
