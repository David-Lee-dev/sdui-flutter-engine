import 'package:flutter/widgets.dart';

import '../../../engine_registries.dart';
import '../../anchor_scope/anchor_scope_anchors.dart';

/// `anchor` — Registers an `anchor` node's first child under its non-empty `id`.
///
/// Nodes outside an [EngineRegistryScope], or without a usable `id`, pass the
/// child through without registration.
///
/// Inside an `anchor_scope`, the child registers into that scope's *local*
/// registry in addition to the mount-global one (see [AnchorScopeAnchors]) —
/// the global registration is unconditional, so the `scroll` driver keeps
/// working exactly as before regardless of scope nesting.
///
/// ```yaml
/// _type: anchor
/// id: example
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `id` (`text`, default `null`) — identifier used to register or connect the widget.
///
/// Child: `_child`.
final class AnchorWidget {
  const AnchorWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? const SizedBox.shrink() : children.first;
    final id = props['id'];
    if (id is! String || id.isEmpty) return child;

    Widget result = child;
    final scopeRegistry = AnchorScopeAnchors.of(context);
    if (scopeRegistry != null) {
      result = AnchorScope(id: id, registry: scopeRegistry, child: result);
    }
    final globalRegistry = EngineRegistryScope.of(context)?.anchors;
    if (globalRegistry != null) {
      result = AnchorScope(id: id, registry: globalRegistry, child: result);
    }
    return result;
  }
}

/// Keeps [child] registered in [registry] under [id] for this widget's lifetime.
class AnchorScope extends StatefulWidget {
  const AnchorScope({
    super.key,
    required this.id,
    required this.registry,
    required this.child,
  });

  final String id;
  final AnchorRegistry registry;
  final Widget child;

  @override
  State<AnchorScope> createState() => _AnchorScopeState();
}

class _AnchorScopeState extends State<AnchorScope> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.registry.register(widget.id, _key);
  }

  @override
  void didUpdateWidget(AnchorScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      oldWidget.registry.unregister(oldWidget.id, _key);
      widget.registry.register(widget.id, _key);
    }
  }

  @override
  void dispose() {
    widget.registry.unregister(widget.id, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: _key, child: widget.child);
}
