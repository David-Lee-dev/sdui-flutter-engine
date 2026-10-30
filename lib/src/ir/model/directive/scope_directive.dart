part of '_base.dart';

/// Establishes the state and action boundary surrounding [child].
///
/// Raw `_scope` data has already been converted into typed configuration,
/// actions, and lifecycle hooks before reaching the rendering layer.
final class ScopeDirective extends Directive {
  const ScopeDirective({
    required this.config,
    required this.child,
    required this.path,
    this.actions = const {},
    this.lifecycle = const [],
    this.skeleton,
    this.autoSkeleton = false,
  });

  final ScopeConfig config;
  final Directive child;

  /// Placeholder subtree displayed while mount actions are completing.
  final Directive? skeleton;

  /// Whether `_skeleton: auto` draws the placeholder from [child] itself,
  /// revealing each node when the mount-written state it reads arrives.
  final bool autoSkeleton;

  /// Dispatches named [actions] at this scope's lifecycle boundaries.
  final List<LifecycleHook> lifecycle;

  /// Maps locally declared names to compiled action flows.
  final Map<String, Action> actions;

  /// The source node's tree path for diagnostics.
  final String path;
}
