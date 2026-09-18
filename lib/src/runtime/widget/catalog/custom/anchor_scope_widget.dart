import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/compile/compile.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';

import '../../../driver/driver_registry.dart';
import '../../../engine_registries.dart';
import '../../../directive_subtree.dart';
import '../../../util/props_resolver.dart';
import '../../../wrapper/scope/scope.dart';
import '../../anchor_scope/anchor_scope_anchors.dart';

/// `anchor_scope` — Owns the stacking context `anchor`s inside it fly within.
///
/// A transparent provider: `_child` is measured and painted exactly as if this
/// node were not present (see [_ScopeStack]), and a transfer layer above it
/// renders items in flight for the `anchoring` driver's `method: move`.
///
/// `items` declares the flying content by key — raw templates, compiled once
/// per key and instantiated fresh for each flight, so a launched item's own
/// `_motion` (entrance/exit) runs normally; this widget never touches it.
///
/// ```yaml
/// _type: anchor_scope
/// id: rewards
/// items:
///   coin: { _type: image, src: /assets/coin.png, width: 30 }
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `id` (`text`, default `null`) — identifier the `anchoring` driver's `scope` targets; omit only when this is the mount's sole `anchor_scope`.
/// - `items` (raw map, default `{}`) — `{ key: template }` flyable content, addressed by the driver's `item`.
///
/// Child: `_child`.
final class AnchorScopeWidget {
  const AnchorScopeWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final child = children.isEmpty ? const SizedBox.shrink() : children.first;
    final id = PropsResolver.text(props['id']);
    final rawItems = props['items'];
    final items = rawItems is Map
        ? Map<String, Object?>.unmodifiable(
            rawItems.map((key, value) => MapEntry('$key', value)),
          )
        : const <String, Object?>{};
    final registry = EngineRegistryScope.of(context)?.anchorScopes;
    return _AnchorScopeHost(
      id: id,
      items: items,
      registry: registry,
      child: child,
    );
  }
}

class _AnchorScopeHost extends StatefulWidget {
  const _AnchorScopeHost({
    required this.id,
    required this.items,
    required this.registry,
    required this.child,
  });

  final String? id;
  final Map<String, Object?> items;
  final AnchorScopeRegistry? registry;
  final Widget child;

  @override
  State<_AnchorScopeHost> createState() => _AnchorScopeHostState();
}

class _AnchorScopeHostState extends State<_AnchorScopeHost>
    with TickerProviderStateMixin
    implements AnchorScopeController {
  /// Local anchor index — the same [AnchorRegistry] shape used mount-wide,
  /// just scoped to this `anchor_scope`. Descendant `anchor`s register here in
  /// addition to the global registry (see `anchor_widget.dart`).
  final AnchorRegistry _localAnchors = AnchorRegistry();

  /// Keys this widget's own box so anchor rects can be read in local space.
  final GlobalKey _boxKey = GlobalKey();

  /// Compiled item directives, memoized by items key ([_directiveFor]).
  final Map<String, Directive?> _compiled = {};

  /// Flights currently in the air, insertion order preserved for painting.
  final LinkedHashSet<_Flight> _flights = LinkedHashSet();

  int _nextFlightId = 0;

  @override
  void initState() {
    super.initState();
    _registerScope();
  }

  @override
  void didUpdateWidget(_AnchorScopeHost old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id || !identical(old.registry, widget.registry)) {
      _unregisterScope(old.id, old.registry);
      _registerScope();
    }
  }

  void _registerScope() {
    final id = widget.id;
    if (id != null && id.isNotEmpty) widget.registry?.register(id, this);
  }

  void _unregisterScope(String? id, AnchorScopeRegistry? registry) {
    if (id != null && id.isNotEmpty) registry?.unregister(id, this);
  }

  @override
  void dispose() {
    _unregisterScope(widget.id, widget.registry);
    // Completing outstanding flights here (rather than leaving them to
    // AnimationController's own disposal) is what makes a driver `await` on a
    // launch resolve instead of hanging when the scope leaves the tree —
    // the `isCancelled` "stop and clean up" contract from the design doc.
    for (final flight in _flights.toList()) {
      flight.finish();
    }
    super.dispose();
  }

  // --- AnchorScopeController -------------------------------------------

  @override
  Rect? rectFor(String anchorId) {
    final targetBox = _localAnchors
        .keyFor(anchorId)
        ?.currentContext
        ?.findRenderObject();
    final scopeBox = _boxKey.currentContext?.findRenderObject();
    if (targetBox is! RenderBox || !targetBox.attached) return null;
    if (scopeBox is! RenderBox || !scopeBox.attached) return null;
    final topLeft = targetBox.localToGlobal(Offset.zero, ancestor: scopeBox);
    return topLeft & targetBox.size;
  }

  @override
  // The contract asks "is this a declared key", not "does it compile" —
  // compilation stays lazy in [launch], whose null case already no-ops.
  bool hasItem(String item) => widget.items.containsKey(item);

  @override
  Future<void> launch({
    required String item,
    required Offset from,
    required Offset to,
    required Duration duration,
    required Curve curve,
  }) {
    final directive = _directiveFor(item);
    if (directive == null || !mounted) return Future<void>.value();

    final controller = AnimationController(vsync: this, duration: duration);
    final animation = Tween<Offset>(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
    late final _Flight flight;
    flight = _Flight(
      key: ValueKey(_nextFlightId++),
      controller: controller,
      animation: animation,
      // A fresh Scope + build per flight — instantiating the same compiled
      // directive again gives each concurrent flight independent state (own
      // `_motion` timers), matching what a fresh node in the tree would do.
      content: Scope.ofState(const {}, child: DirectiveSubtree.mount(directive)),
      // `dispose()` also drives this (via finish()) after the widget has
      // already unmounted — setState would throw there, so plain removal
      // covers that path and the rebuild-triggering path covers the rest.
      onDone: () {
        if (mounted) {
          setState(() => _flights.remove(flight));
        } else {
          _flights.remove(flight);
        }
      },
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) flight.finish();
    });
    setState(() => _flights.add(flight));
    controller.forward();
    return flight.done;
  }

  /// Compiles `items[item]` into a [Directive], memoized for this widget's
  /// lifetime. `null` covers a missing key and a malformed template alike —
  /// both are the driver's "unknown item" no-op case, never a throw (a
  /// decorative flight must not be able to crash a reward flow).
  Directive? _directiveFor(String item) => _compiled.putIfAbsent(item, () {
    final template = widget.items[item];
    if (template is! Map) return null;
    try {
      // No ensureRegistered here: this widget was built *by* the factory, so
      // both catalogs are seeded by construction. Not importing the factory
      // keeps factory -> catalog -> factory from becoming an import cycle.
      DriverRegistry.ensureRegistered();
      // Registry-snapshot catalog: this runtime module cannot reach the
      // engine root for the boot catalog without re-creating an import cycle.
      return Compile.build(
        Map<String, Object?>.from(template),
        const {},
      ).directive;
    } catch (_) {
      return null;
    }
  });

  // --- build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnchorScopeAnchors(
      anchors: _localAnchors,
      child: _ScopeStack(
        boxKey: _boxKey,
        transferLayer: _flights.isEmpty
            ? null
            : Stack(children: [for (final flight in _flights) flight.build()]),
        child: widget.child,
      ),
    );
  }
}

/// Wraps [child] in a [Stack] whose only size input is [child] itself, so the
/// subtree measures identically whether or not this scope is present.
///
/// [StackFit.passthrough] hands [child] the incoming constraints unmodified
/// (rather than loosening them); [transferLayer], when present, is a
/// `Positioned.fill` that never participates in sizing.
class _ScopeStack extends StatelessWidget {
  const _ScopeStack({
    required this.boxKey,
    required this.child,
    required this.transferLayer,
  });

  final GlobalKey boxKey;
  final Widget child;
  final Widget? transferLayer;

  @override
  Widget build(BuildContext context) {
    final layer = transferLayer;
    return Stack(
      key: boxKey,
      fit: StackFit.passthrough,
      children: [
        child,
        if (layer != null) Positioned.fill(child: IgnorePointer(child: layer)),
      ],
    );
  }
}

/// One in-flight item: an [AnimationController] driving a [Positioned] built
/// around already-compiled [content].
class _Flight {
  _Flight({
    required this.key,
    required this.controller,
    required this.animation,
    required this.content,
    required VoidCallback onDone,
  }) : _onDone = onDone;

  final Key key;
  final AnimationController controller;
  final Animation<Offset> animation;
  final Widget content;
  final VoidCallback _onDone;

  final Completer<void> _completer = Completer<void>();

  Future<void> get done => _completer.future;

  /// Ends this flight exactly once: completes [done], disposes the ticker,
  /// and drops it from the scope's paint list. Safe to call from natural
  /// animation completion or from the owning scope's `dispose()`.
  void finish() {
    if (_completer.isCompleted) return;
    _completer.complete();
    controller.dispose();
    _onDone();
  }

  /// The item's own center lands exactly on [animation]'s current point,
  /// regardless of the item's rendered size (no need to know it up front).
  Widget build() => AnimatedBuilder(
    key: key,
    animation: animation,
    builder: (context, _) => Positioned(
      left: animation.value.dx,
      top: animation.value.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: content,
      ),
    ),
  );
}
