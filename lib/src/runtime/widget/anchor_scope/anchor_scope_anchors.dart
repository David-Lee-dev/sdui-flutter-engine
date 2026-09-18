import 'package:flutter/widgets.dart';

import '../../engine_registries.dart';

/// Exposes the nearest `anchor_scope`'s local [AnchorRegistry] to descendants.
///
/// An `anchor` widget inside a scope registers into this registry *in addition
/// to* the mount-global one (see `anchor_widget.dart`), so the `anchoring`
/// driver can resolve anchors within the scope's own coordinate space without
/// disturbing the global `scroll` driver lookup.
class AnchorScopeAnchors extends InheritedWidget {
  const AnchorScopeAnchors({
    super.key,
    required this.anchors,
    required super.child,
  });

  /// The registry local to the nearest `anchor_scope`.
  final AnchorRegistry anchors;

  /// Returns the nearest scope's local registry, or `null` outside one.
  static AnchorRegistry? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnchorScopeAnchors>()?.anchors;

  @override
  bool updateShouldNotify(AnchorScopeAnchors oldWidget) =>
      !identical(anchors, oldWidget.anchors);
}
