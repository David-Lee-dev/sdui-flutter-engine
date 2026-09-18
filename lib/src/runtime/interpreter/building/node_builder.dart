import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import '../../log/engine_log.dart';
import '../../environment/_base.dart';
import '../expression_evaluator.dart';
import '../../motion/_base.dart';
import '../../motion/composite/presets.dart';
import '../../motion/motion_factory.dart';
import '../../widget/factory.dart';
import '../../widget/contract/action_sink.dart';
import '../../util/props_resolver.dart';
import '../../wrapper/interaction.dart';
import '../../wrapper/scroll_event_wrapper.dart';
import '../../wrapper/motion.dart';
import '../../wrapper/scope/bound_builder.dart';
import '../../wrapper/scope/morph_scope.dart';
import '../../wrapper/scope/scope.dart';
import 'observer/loop_observer.dart';
import 'observer/condition_observer.dart';
import 'observer/plain_observer.dart';
import 'observer/switch_observer.dart';

/// Converts compiled directives into reactive widget boundaries.
///
/// Directive dispatch remains separate from plain-node assembly so loops and
/// branches can rebuild only their own observer boundary.
final class NodeBuilder {
  const NodeBuilder._();

  /// Builds the observer or scope boundary represented by [directive].
  static Widget build(Directive directive) {
    return switch (directive) {
      PlainDirective node => PlainObserver(directive: node),
      ConditionDirective cond => ConditionObserver(directive: cond),
      LoopDirective loop => LoopObserver(directive: loop),
      MorphDirective morph => MorphScope(
        directive: morph,
        child: build(morph.child),
      ),
      SwitchDirective sw => SwitchObserver(directive: sw),
      ScopeDirective scope => Scope(
        config: scope.config,
        actions: scope.actions,
        lifecycle: scope.lifecycle,
        skeleton: scope.skeleton == null ? null : build(scope.skeleton!),
        child: build(scope.child),
      ),
    };
  }

  /// Resolves and assembles one [PlainDirective] against [env].
  ///
  /// Child delivery follows the widget specification, then motion, interaction,
  /// scroll events, and identity wrappers are applied in that order.
  static Widget assemble(
    BuildContext context,
    PlainDirective directive,
    Environment env,
  ) {
    final resolved = ExpressionEvaluator.resolveMap(directive.props, env);
    Map<String, Object?> props = resolved;
    _PropAudit? audit;
    // Property reads become the debug-only schema, avoiding a second catalog
    // that could drift from widget builders. The assertion removes all release cost.
    assert(() {
      audit = _PropAudit(resolved);
      props = audit!;
      return true;
    }());
    Widget widget = switch (WidgetFactory.specFor(directive.type)) {
      SlotSpec spec => spec.build(context, props, {
        for (final entry in directive.slots.entries)
          entry.key: build(entry.value),
      }),
      BuilderSpec spec => spec.build(
        context,
        props,
        directive.children.length,
        (index, {Map<String, Object?> vars = const {}}) {
          if (index < 0 || index >= directive.children.length) return null;
          final child = build(directive.children[index]);
          return vars.isEmpty ? child : Scope.ofState(vars, child: child);
        },
      ),
      EagerSpec spec => spec.build(context, props, [
        for (final child in directive.children) build(child),
      ]),
      BoundSpec spec => BoundBuilder(
        bind: PropsResolver.text(props['bind']),
        fieldId:
            PropsResolver.text(props['id']) ??
            PropsResolver.text(props['bind']) ??
            directive.path,
        validation: PropsResolver.text(props['error_text']) == null
            ? null
            : 'invalid',
        on: directive.on,
        builder: (context, value, onChanged, onSubmit) =>
            spec.build(context, props, value, onChanged, onSubmit),
      ),
      ActionSpec spec => spec.build(context, props, [
        for (final child in directive.children) build(child),
      ], Scope.actionHost(context)),
      null => throw StateError('Unknown widget type: "${directive.type}".'),
    };
    assert(() {
      audit?.warnUnread(directive.type, directive.path);
      return true;
    }());
    for (final motion in directive.motions) {
      final resolved = ExpressionEvaluator.resolveMap(motion.params, env);
      for (final atom in MotionPresets.expand(motion.type, resolved)) {
        widget = MotionWrapper(
          motion: MotionFactory.resolve(atom.type),
          params: MotionParams(atom.params),
          child: widget,
        );
      }
    }
    if (directive.on.keys.any(InteractionWrapper.events.contains)) {
      final node =
          LoopTelemetryScope.maybeOf(
            context,
          )?.node(type: directive.type, path: directive.path) ??
          ActionNode(type: directive.type, path: directive.path);
      widget = InteractionWrapper(
        on: directive.on,
        node: node,
        timing: directive.timing,
        // Resolved here, in the node's own frame — a loop item's `${item.x}`
        // means nothing in the scope that declares the action.
        payloads: ExpressionEvaluator.resolveMap(directive.onEvent, env),
        feedback: directive.tapFeedback,
        child: widget,
      );
    }
    if (directive.on.keys.any(ScrollEventWrapper.events.contains)) {
      widget = ScrollEventWrapper(
        on: directive.on,
        timing: directive.timing,
        endThreshold: PropsResolver.number(props['end_threshold']),
        startThreshold: PropsResolver.number(props['start_threshold']),
        child: widget,
      );
    }
    final key = directive.key;
    return key == null
        ? widget
        : KeyedSubtree(key: ValueKey(key), child: widget);
  }
}

/// Records property reads so unsupported keys can be diagnosed in debug builds.
class _PropAudit extends MapView<String, Object?> {
  _PropAudit(super.map);

  final Set<String> _read = {};

  @override
  Object? operator [](Object? key) {
    if (key is String) _read.add(key);
    return super[key];
  }

  void warnUnread(String type, String path) {
    final unread = [
      for (final key in keys)
        if (!_read.contains(key)) key,
    ];
    if (unread.isEmpty) return;

    EngineLog.widget.unknownProps(type, unread, path);
  }
}
