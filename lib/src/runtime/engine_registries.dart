/// Provides mount-scoped widget registries for identifier-based operations.
///
/// Each engine mount owns a separate instance, preventing identifier collisions
/// between screens. Widgets obtain it from [EngineRegistryScope], while drivers
/// receive the same instance through their runtime context.
library;

import 'package:flutter/widgets.dart';

/// Groups the registries owned by one engine mount.
final class EngineRegistries {
  EngineRegistries();

  /// Stores named tree positions used by operations such as scrolling.
  final AnchorRegistry anchors = AnchorRegistry();

  /// Stores focus nodes for named input widgets.
  final FocusRegistry focus = FocusRegistry();

  /// Stores `anchor_scope` controllers reachable by the `anchoring` driver.
  final AnchorScopeRegistry anchorScopes = AnchorScopeRegistry();
}

/// Exposes mount-scoped [EngineRegistries] to a widget subtree.
class EngineRegistryScope extends InheritedWidget {
  const EngineRegistryScope({
    super.key,
    required this.registries,
    required super.child,
  });

  final EngineRegistries registries;

  /// Returns the nearest engine registries, or `null` outside an engine mount.
  static EngineRegistries? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<EngineRegistryScope>()
      ?.registries;

  @override
  bool updateShouldNotify(EngineRegistryScope oldWidget) =>
      registries != oldWidget.registries;
}

/// Maps named anchors to keys for widgets currently mounted in the tree.
final class AnchorRegistry {
  AnchorRegistry();

  final Map<String, GlobalKey> _anchors = {};

  /// Registers [key] for [id], replacing any previous registration.
  void register(String id, GlobalKey key) => _anchors[id] = key;

  /// Removes [id] only when [owner] is still its registered key.
  ///
  /// The ownership check prevents a disposing widget from deleting a newer
  /// replacement's registration.
  void unregister(String id, GlobalKey owner) {
    if (identical(_anchors[id], owner)) _anchors.remove(id);
  }

  /// Returns the key registered for [id], or `null` if none is mounted.
  GlobalKey? keyFor(String id) => _anchors[id];
}

/// Capabilities an `anchor_scope` exposes to the `anchoring` driver (`method:
/// move`), independent of the widget that implements them.
///
/// Anchor rects are resolved in the scope's own local coordinate space (the
/// same space [launch]'s `from`/`to` points are given in), so the driver never
/// needs to know how the scope maps global to local coordinates.
abstract interface class AnchorScopeController {
  /// Returns the rect of the anchor registered as [anchorId] within this
  /// scope, or `null` when it is not currently mounted.
  Rect? rectFor(String anchorId);

  /// Returns whether [item] is a declared key in this scope's `items`.
  bool hasItem(String item);

  /// Starts one flight of [item] from [from] to [to] and returns a future
  /// that completes when that single flight's animation ends (immediately, if
  /// [item] cannot be built).
  ///
  /// Callers resolve [item]/[from]/[to] validity beforehand — an unresolved
  /// launch here would rather no-op than throw, since a decorative flight
  /// scheduling failure should not surface as a command error.
  Future<void> launch({
    required String item,
    required Offset from,
    required Offset to,
    required Duration duration,
    required Curve curve,
  });
}

/// Maps named anchor scopes to their controllers for widgets currently mounted.
///
/// Mirrors [AnchorRegistry]'s id-ownership shape. Also resolves the "no `scope`
/// given" case the `anchoring` driver supports: with exactly one scope mounted,
/// that scope is used.
final class AnchorScopeRegistry {
  AnchorScopeRegistry();

  final Map<String, AnchorScopeController> _scopes = {};

  /// Registers [controller] for [id], replacing any previous registration.
  void register(String id, AnchorScopeController controller) =>
      _scopes[id] = controller;

  /// Removes [id] only when [owner] is still its registered controller.
  ///
  /// The ownership check prevents a disposing scope from deleting a newer
  /// replacement's registration.
  void unregister(String id, AnchorScopeController owner) {
    if (identical(_scopes[id], owner)) _scopes.remove(id);
  }

  /// Resolves the controller a driver call should use.
  ///
  /// With a non-null [id], returns the controller registered under it (or
  /// `null` if none is mounted). With `null`, returns the sole mounted scope,
  /// or `null` when zero or several are mounted — the template must then name
  /// one explicitly.
  AnchorScopeController? resolve(String? id) {
    if (id != null) return _scopes[id];
    return _scopes.length == 1 ? _scopes.values.first : null;
  }
}

/// Maps named inputs to their mounted [FocusNode] instances.
final class FocusRegistry {
  FocusRegistry();

  final Map<String, FocusNode> _nodes = {};

  /// Registers [node] for [id], replacing any previous registration.
  void register(String id, FocusNode node) => _nodes[id] = node;

  /// Removes [id] only when [owner] is still its registered node.
  void unregister(String id, FocusNode owner) {
    if (identical(_nodes[id], owner)) _nodes.remove(id);
  }

  /// Returns the focus node registered for [id], or `null` if none is mounted.
  FocusNode? nodeFor(String id) => _nodes[id];
}
