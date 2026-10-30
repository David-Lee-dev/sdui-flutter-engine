import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
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
import '../../wrapper/scope/press_scope.dart';
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

  /// Indexes of `_motion` layers turned off per node element after their
  /// parameters failed to evaluate; a layer stays off for the node's lifetime.
  static final _offMotions = Expando<Set<int>>('NodeBuilder.offMotions');

  /// Builds the observer or scope boundary represented by [directive].
  static Widget build(Directive directive) {
    return switch (directive) {
      PlainDirective node => _plain(node),
      ConditionDirective cond => ConditionObserver(directive: cond),
      LoopDirective loop => LoopObserver(directive: loop),
      MorphDirective morph when morph.spring != null => SpringMorphScope(
        directive: morph,
        child: _isolated(morph.child),
      ),
      MorphDirective morph => MorphScope(
        directive: morph,
        child: morph.repeat ? _isolated(morph.child) : build(morph.child),
      ),
      SwitchDirective sw => SwitchObserver(directive: sw),
      // A scope's state changes repaint only its own section, not the
      // sections around it.
      ScopeDirective scope => Scope(
        config: scope.config,
        actions: scope.actions,
        lifecycle: scope.lifecycle,
        skeleton: scope.skeleton == null ? null : build(scope.skeleton!),
        child: _isolated(scope.child),
      ),
    };
  }

  /// Builds [directive] as the direct widget of a continuously animating
  /// morph or of a scope: a plain box node gets its own repaint boundary.
  static Widget _isolated(Directive directive) => directive is PlainDirective
      ? _plain(directive, isolate: true)
      : build(directive);

  /// A plain node's observer, under its press scope when it declares
  /// `pressed_as`.
  static Widget _plain(PlainDirective node, {bool isolate = false}) {
    final observer = PlainObserver(directive: node, isolate: isolate);
    final pressed = node.pressedAs;
    return pressed == null
        ? observer
        : PressScope(name: pressed, child: observer);
  }

  /// Resolves and assembles one [PlainDirective] against [env].
  ///
  /// Child delivery follows the widget specification, then motion, interaction,
  /// scroll events, the repaint boundary ([isolate]) and identity wrappers are
  /// applied in that order. For a parent-data widget (`positioned`,
  /// `expanded`, ...) all but the identity wrapper go around its child.
  static Widget assemble(
    BuildContext context,
    PlainDirective directive,
    Environment env, {
    bool isolate = false,
  }) {
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
    final spec = WidgetFactory.specFor(directive.type);
    // A sliver must stay the direct render child of its viewport, so it never
    // gets a (box) repaint boundary.
    final box = spec?.produces != LayoutProtocol.sliver;
    Widget widget = switch (spec) {
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
    final interactive = directive.on.keys.any(
      InteractionWrapper.events.contains,
    );
    final scrolls = directive.on.keys.any(ScrollEventWrapper.events.contains);
    if (directive.motions.isNotEmpty || interactive || scrolls || isolate) {
      widget = _inside(
        widget,
        (child) => _decorate(
          context,
          directive,
          env,
          props,
          child,
          interactive: interactive,
          scrolls: scrolls,
          isolate: isolate && box,
          box: box,
        ),
      );
    }
    final key = directive.key;
    return key == null
        ? widget
        : KeyedSubtree(key: ValueKey(key), child: widget);
  }

  /// Applies [decorate] to the child of a parent-data widget, which must stay
  /// the direct widget of its parent, or to [widget] itself otherwise.
  static Widget _inside(Widget widget, Widget Function(Widget) decorate) =>
      switch (widget) {
        Positioned p => Positioned(
          key: p.key,
          left: p.left,
          top: p.top,
          right: p.right,
          bottom: p.bottom,
          width: p.width,
          height: p.height,
          child: decorate(p.child),
        ),
        Expanded e => Expanded(
          key: e.key,
          flex: e.flex,
          child: decorate(e.child),
        ),
        Flexible f => Flexible(
          key: f.key,
          flex: f.flex,
          fit: f.fit,
          child: decorate(f.child),
        ),
        Spacer s => Expanded(
          key: s.key,
          flex: s.flex,
          child: decorate(const SizedBox.shrink()),
        ),
        _ => decorate(widget),
      };

  /// Wraps a node's [widget] in its motion, interaction, scroll-event and
  /// repaint-boundary layers. Only a [box] node gets repaint boundaries.
  static Widget _decorate(
    BuildContext context,
    PlainDirective directive,
    Environment env,
    Map<String, Object?> props,
    Widget widget, {
    required bool interactive,
    required bool scrolls,
    required bool isolate,
    required bool box,
  }) {
    final off = _offMotions[context];
    for (final (index, motion) in directive.motions.indexed) {
      if (off != null && off.contains(index)) continue;
      final List<(Motion, MotionParams)> atoms;
      try {
        final resolved = ExpressionEvaluator.resolveMap(motion.params, env);
        atoms = [
          for (final atom in MotionPresets.expand(motion.type, resolved))
            (MotionFactory.resolve(atom.type), MotionParams(atom.params)),
        ];
      } catch (error) {
        (_offMotions[context] ??= {}).add(index);
        EngineLog.widget.stilled(
          context,
          directive.path,
          '_motion "${motion.type}" params failed: ${error.runtimeType}',
        );
        continue;
      }
      for (final (atom, params) in atoms) {
        widget = MotionWrapper(
          motion: atom,
          params: params,
          path: directive.path,
          repaintBoundary: box,
          child: widget,
        );
      }
    }
    if (interactive) {
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
        onPressed: directive.pressedAs == null ? null : PressScope.of(context),
        child: widget,
      );
    }
    if (scrolls) {
      widget = ScrollEventWrapper(
        on: directive.on,
        timing: directive.timing,
        endThreshold: PropsResolver.number(props['end_threshold']),
        startThreshold: PropsResolver.number(props['start_threshold']),
        child: widget,
      );
    }
    return isolate ? RepaintBoundary(child: widget) : widget;
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
