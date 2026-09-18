/// Identifies the rendered node that originated an action invocation.
final class ActionNode {
  /// Creates node identity resolved at the directive construction site.
  const ActionNode({
    required this.type,
    required this.path,
    this.entity,
    this.position = const [],
  });

  /// Template widget type, independent of the rendered Flutter widget.
  final String type;

  /// Compiler-assigned template path within its template fingerprint.
  final String path;

  /// Deepest typed loop entity, or a bare-id `unknown` fallback.
  final Map<String, Object?>? entity;

  /// Outer-to-inner repeated-item placement without raw item values.
  final List<Map<String, Object?>> position;
}

/// Carries one action flow's stable correlation identity and origin.
///
/// The value is passed explicitly because commands in a batch overlap; a
/// process-wide pending id could attribute one command to a neighboring flow.
final class ActionInvocation {
  /// Creates an immutable execution context shared by a complete action flow.
  const ActionInvocation({
    required this.invocationId,
    required this.origin,
    this.node,
  });

  /// Per-action UUID used as command and server correlation identity.
  final String invocationId;

  /// Trigger that began the root action flow.
  final String origin;

  /// Rendered origin when the invocation began from a gesture.
  final ActionNode? node;
}

/// Canonical action origins accepted by the telemetry taxonomy.
abstract final class ActionOrigin {
  static const tap = 'tap';
  static const mount = 'mount';
  static const render = 'render';
  static const remount = 'remount';
  static const interval = 'interval';
  static const dispose = 'dispose';
  static const then = 'then';
  static const error = 'error';
  static const dismiss = 'dismiss';
  static const always = 'always';
  static const background = 'background';
}

/// Dispatches named engine actions without exposing runtime scope to widgets.
abstract interface class ActionSink {
  /// Dispatches [action] without waiting for its asynchronous work.
  void handle(String action, {Object? event, ActionInvocation? invocation});

  /// Dispatches [action] and completes after its asynchronous work finishes.
  Future<void> handleAwaitable(
    String action, {
    Object? event,
    ActionInvocation? invocation,
  });
}
