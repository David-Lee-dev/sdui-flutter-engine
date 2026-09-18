import 'package:flutter/material.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../../environment/_base.dart';
import '../../../environment/map_environment.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import '../../../util/props_resolver.dart';
import '../../../widget/catalog/custom/spin_grid_widget.dart';
import '../../../widget/catalog/custom/swipe_layout_widget.dart';
import '../../../widget/catalog/custom/swipe_pane_widget.dart';
import '../../../widget/factory.dart';
import '../../../widget/contract/action_sink.dart';
import '../../../wrapper/scope/scope.dart';
import '../../../wrapper/scope/scope_binding.dart';
import '../../binding/loop_resolver.dart';
import '../../expression_evaluator.dart';
import '../node_builder.dart';
import '../node_guard.dart';

/// Expands a reactive loop while preserving item identity across source changes.
///
/// Eager wrappers reuse catalog widgets; lazy and mutating wrappers are built here
/// because they require indexed construction or source write-back callbacks.
class LoopObserver extends StatelessWidget {
  const LoopObserver({super.key, required this.directive});

  final LoopDirective directive;

  Widget _item(({Map<String, Object?> frame, String key}) item) {
    return KeyedSubtree(
      key: ValueKey(item.key),
      child: Builder(
        builder: (context) {
          final parent =
              LoopTelemetryScope.maybeOf(context)?.entries ?? const [];
          final entry = LoopTelemetryEntry.fromFrame(
            item.frame,
            alias: directive.as,
            indexName: directive.index,
            key: item.key,
          );
          return LoopTelemetryScope(
            entries: [...parent, entry],
            child: Scope.ofState(
              item.frame,
              child: NodeBuilder.build(directive.child),
            ),
          );
        },
      ),
    );
  }

  /// The `_wrap` strategies with a real case below, other than `'column'`
  /// (which is deliberately the same as the unhandled-name fallback).
  ///
  /// [TemplateValidator]'s `_knownWraps` is a second, compile-time list of the
  /// same strategy names. Keep the two in sync by hand when editing the switch
  /// below — a name declared valid there with no case here degrades silently
  /// into a bare column instead of failing loudly, which is exactly the bug
  /// this set exists to let a test catch.
  @visibleForTesting
  static const Set<String> handledWraps = {
    'row',
    'wrap',
    'serpentine',
    'serpentine_row',
    'auto_scroll',
    'swipe',
    'list',
    'sliver_list',
    'spin_grid',
    'grid',
    'sliver_grid',
    'reorderable',
    'dismissible',
  };

  Widget _expand(BuildContext context, Environment env) {
    final resolved = LoopResolver.resolve(directive, env);
    final p = ExpressionEvaluator.resolveMap(directive.wrapParams, env);
    final finder = _indexFinder(resolved);
    switch (directive.wrap) {
      case 'row':
        return _eager(context, 'row', p, resolved);
      case 'wrap':
        return _eager(context, 'wrap', p, resolved);
      case 'serpentine':
        return WidgetFactory.build(context, 'serpentine', p, [
          for (final item in resolved) _item(item),
        ]);
      case 'serpentine_row':
        return WidgetFactory.build(context, 'serpentine_row', p, [
          for (final item in resolved) _item(item),
        ]);
      case 'auto_scroll':
        return WidgetFactory.build(context, 'auto_scroll', p, [
          for (final item in resolved) _item(item),
        ]);
      case 'swipe':
        // A data-driven swipe carousel: the loop owns the page count, so the
        // wrapping swipe_layout's length is the resolved item count rather than
        // an author-set value, and swipe_pane hosts the repeated pages. Autoplay,
        // loop, and viewport come from the wrap params.
        //
        // The enclosing action host is handed through so `on_changed` in the
        // wrap params dispatches the settled page index, exactly as it does on an
        // explicit swipe_layout. Without it a carousel built from data could show
        // a selection but never report one, and an author cannot reach for the
        // explicit form instead — positional `swipe_pane` children cannot come
        // from a loop.
        return SwipeLayoutWidget.build(
          context,
          {...p, 'length': resolved.length},
          [
            SwipePaneWidget.build(context, p, [
              for (final item in resolved) _item(item),
            ]),
          ],
          Scope.actionHost(context),
        );
      case 'list':
        return ListView.builder(
          scrollDirection:
              PropsResolver.axis(p['scroll_direction']) ?? Axis.vertical,
          reverse: PropsResolver.flag(p['reverse']) ?? false,
          padding: PropsResolver.edge(context, p['padding']),
          physics: PropsResolver.scrollPhysics(p['physics']),
          shrinkWrap: PropsResolver.flag(p['shrink_wrap']) ?? false,
          itemCount: resolved.length,
          itemBuilder: (context, i) => _item(resolved[i]),
          findChildIndexCallback: finder,
        );
      case 'sliver_list':
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _item(resolved[i]),
            childCount: resolved.length,
            findChildIndexCallback: finder,
          ),
        );
      case 'spin_grid':
        // Grid-shaped like 'grid' below, but registered as an ActionSpec
        // (factory.dart), not an EagerSpec — WidgetFactory.build only accepts
        // EagerSpec and would throw StateError here. Built directly instead,
        // following the 'swipe' precedent above: the action host is required
        // so `on_finish` can dispatch once the spin animation settles.
        return SpinGridWidget.build(context, p, [
          for (final item in resolved) _item(item),
        ], Scope.actionHost(context));
      case 'grid':
        return GridView.builder(
          gridDelegate: _gridDelegate(context, p),
          padding: PropsResolver.edge(context, p['padding']),
          physics: PropsResolver.scrollPhysics(p['physics']),
          shrinkWrap: PropsResolver.flag(p['shrink_wrap']) ?? false,
          itemCount: resolved.length,
          itemBuilder: (context, i) => _item(resolved[i]),
          findChildIndexCallback: finder,
        );
      case 'sliver_grid':
        return SliverGrid(
          gridDelegate: _gridDelegate(context, p),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _item(resolved[i]),
            childCount: resolved.length,
            findChildIndexCallback: finder,
          ),
        );
      case 'reorderable':
        return ReorderableListView.builder(
          scrollDirection:
              PropsResolver.axis(p['scroll_direction']) ?? Axis.vertical,
          padding: PropsResolver.edge(context, p['padding']),
          shrinkWrap: PropsResolver.flag(p['shrink_wrap']) ?? false,
          itemCount: resolved.length,
          itemBuilder: (context, i) => _item(resolved[i]),
          onReorder: (oldIndex, newIndex) =>
              _reorder(context, env, oldIndex, newIndex),
        );
      case 'dismissible':
        return ListView.builder(
          scrollDirection:
              PropsResolver.axis(p['scroll_direction']) ?? Axis.vertical,
          padding: PropsResolver.edge(context, p['padding']),
          shrinkWrap: PropsResolver.flag(p['shrink_wrap']) ?? false,
          itemCount: resolved.length,
          itemBuilder: (context, i) => Dismissible(
            key: ValueKey('dismiss:${resolved[i].key}'),
            direction:
                PropsResolver.dismissDirection(p['direction']) ??
                DismissDirection.horizontal,
            onDismissed: (_) => _dismissKey(context, env, resolved[i].key),
            child: _item(resolved[i]),
          ),
        );
      default:
        return _eager(context, 'column', p, resolved);
    }
  }

  Widget _eager(
    BuildContext context,
    String type,
    Map<String, Object?> p,
    List<({Map<String, Object?> frame, String key})> resolved,
  ) {
    final children = [for (final item in resolved) _item(item)];
    final props = type == 'wrap' ? p : {'main_axis_size': 'min', ...p};
    return WidgetFactory.build(context, type, props, children);
  }

  static SliverGridDelegate _gridDelegate(
    BuildContext context,
    Map<String, Object?> params,
  ) {
    final cross = PropsResolver.integer(params['cross_axis_count']) ?? 2;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cross < 1 ? 1 : cross,
      mainAxisSpacing:
          PropsResolver.size(context, params['main_axis_spacing']) ?? 0,
      crossAxisSpacing:
          PropsResolver.size(context, params['cross_axis_spacing']) ?? 0,
      childAspectRatio:
          PropsResolver.number(params['child_aspect_ratio']) ?? 1.0,
    );
  }

  // Flutter reports the insertion point before removal, so moving forward
  // requires compensating for the removed slot.
  void _reorder(
    BuildContext context,
    Environment env,
    int oldIndex,
    int newIndex,
  ) {
    final key = _sourceKey();
    if (key == null) return;
    final list = ExpressionEvaluator.resolveValue(directive.source, env);
    if (list is! List) return;
    final copy = List<Object?>.of(list);
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = copy.removeAt(oldIndex);
    copy.insert(target, moved);
    ScopeBinding.write(context, key, copy);
  }

  void _dismissKey(BuildContext context, Environment env, String dismissedKey) {
    final key = _sourceKey();
    if (key == null) return;
    final list = ExpressionEvaluator.resolveValue(directive.source, env);
    if (list is! List) return;
    final resolved = LoopResolver.resolve(directive, env);
    final index = resolved.indexWhere((e) => e.key == dismissedKey);
    if (index < 0 || index >= list.length) return;
    final copy = List<Object?>.of(list)..removeAt(index);
    ScopeBinding.write(context, key, copy);
  }

  // Only a bare source binding is an unambiguous inferred write target.
  String? _sourceKey() {
    final explicit = directive.wrapParams['bind'];
    if (explicit is String && explicit.isNotEmpty) return explicit;
    final source = directive.source;
    return source is Expression ? source.bareBindingKey : null;
  }

  static int? Function(Key) _indexFinder(
    List<({Map<String, Object?> frame, String key})> resolved,
  ) {
    final byKey = {
      for (var i = 0; i < resolved.length; i++) resolved[i].key: i,
    };
    return (key) => key is ValueKey ? byKey[key.value] : null;
  }

  @override
  Widget build(BuildContext context) {
    final env = Scope.envOf(context) ?? MapEnvironment.empty;
    final listenable = env.listen(directive.roots);
    Widget expand(BuildContext ctx) =>
        NodeGuard.run(directive.path, () => _expand(ctx, env));
    if (listenable == null) return expand(context);
    return ListenableBuilder(
      listenable: listenable,
      builder: (ctx, _) => expand(ctx),
    );
  }
}

/// Describes one repeated item without retaining its raw payload.
final class LoopTelemetryEntry {
  /// Creates a redacted repeated-item placement entry.
  const LoopTelemetryEntry({
    required this.index,
    required this.key,
    this.entity,
  });

  /// Zero-based position in this loop level.
  final int index;

  /// Stable reconciliation key; retained internally but never emitted.
  final String key;

  /// Entity selected only from the explicit identifier allowlist.
  final Map<String, Object?>? entity;

  static const Map<String, String> _typedFields = {
    'partnerId': 'partner',
    'productId': 'product',
    'shopId': 'shop',
    'missionId': 'mission',
    'adId': 'ad',
    'externalId': 'external',
  };

  /// Redacts one resolver frame into placement and entity identity.
  static LoopTelemetryEntry fromFrame(
    Map<String, Object?> frame, {
    required String alias,
    required String indexName,
    required String key,
  }) {
    final rawIndex = frame[indexName];
    final item = frame[alias];
    return LoopTelemetryEntry(
      index: rawIndex is int ? rawIndex : 0,
      key: key,
      entity: item is Map ? _entity(item) : null,
    );
  }

  static Map<String, Object?>? _entity(Map<dynamic, dynamic> item) {
    for (final field in _typedFields.entries) {
      final id = _scalarId(item[field.key]);
      if (id != null) return {'type': field.value, 'id': id};
    }
    final id = _scalarId(item['id']);
    return id == null ? null : {'type': 'unknown', 'id': id};
  }

  static String? _scalarId(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is num && value.isFinite) return value.toString();
    return null;
  }
}

/// Propagates the full nesting path of repeated items to interactive nodes.
class LoopTelemetryScope extends InheritedWidget {
  /// Propagates [entries] without introducing a render object.
  const LoopTelemetryScope({
    super.key,
    required this.entries,
    required super.child,
  });

  /// Outer-to-inner loop entries for the current repeated node.
  final List<LoopTelemetryEntry> entries;

  /// Returns the nearest repeated-item telemetry context.
  static LoopTelemetryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LoopTelemetryScope>();

  /// Combines the loop path with a compiled node's stable identity.
  ActionNode node({required String type, required String path}) {
    Map<String, Object?>? entity;
    for (final entry in entries.reversed) {
      if (entry.entity?['type'] != 'unknown') {
        entity = entry.entity;
        break;
      }
    }
    if (entity == null) {
      for (final entry in entries.reversed) {
        if (entry.entity != null) {
          entity = entry.entity;
          break;
        }
      }
    }
    return ActionNode(
      type: type,
      path: path,
      entity: entity,
      position: [
        for (final entry in entries)
          {
            'index': entry.index,
            if (entry.entity != null) 'entity': entry.entity,
          },
      ],
    );
  }

  @override
  bool updateShouldNotify(LoopTelemetryScope oldWidget) =>
      oldWidget.entries != entries;
}
