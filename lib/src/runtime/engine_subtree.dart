import 'package:flutter/widgets.dart';

import 'engine_host.dart';

/// Everything a nested engine mount needs — the modal body's slice of the
/// `EngineRunner` surface.
final class EngineSubtreeRequest {
  const EngineSubtreeRequest({
    required this.template,
    this.rootData = const {},
    this.host,
    this.screenId,
    this.screenViewId,
    this.surfaceType,
    this.modalId,
    this.resolveExitReason,
  });

  final Map<String, Object?> template;
  final Map<String, Object?> rootData;
  final EngineHost? host;
  final String? screenId;
  final String? screenViewId;
  final String? surfaceType;
  final String? modalId;
  final String? Function()? resolveExitReason;
}

/// Mounts a nested engine subtree without importing the runner.
///
/// Runtime modules that recursively mount the engine (the modal frame) sit
/// *below* `engine_runner.dart` in the import graph, so reaching up for the
/// concrete widget would create a cycle. Instead the runner installs its own
/// constructor here on first mount — and recursion guarantees a runner is
/// already mounted before any nested mount is requested.
abstract final class EngineSubtree {
  /// Installed by `EngineRunner` (first mount wins; they are equivalent).
  static Widget Function(EngineSubtreeRequest request)? builder;

  /// Builds a nested engine mount for [request].
  static Widget mount(EngineSubtreeRequest request) {
    final build = builder;
    if (build == null) {
      throw StateError(
        'EngineSubtree.builder not installed — a nested mount can only appear '
        'under a running EngineRunner.',
      );
    }
    return build(request);
  }
}
