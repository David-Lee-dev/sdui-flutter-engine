import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import '../../log/engine_log.dart';
import '../../environment/_base.dart';
import '../../environment/scope/scope_environment.dart';
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
import '../../wrapper/scope/auto_skeleton.dart';
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

  /// Leaf node elements that have been pending: they keep their skeleton
  /// wrapper for life, so revealing never remounts their subtree.
  static final _wasPending = Expando<bool>('NodeBuilder.wasPending');

  /// Node elements that have gone without their motion layers (pending, or
  /// held with motions): they keep their core under one key for life.
  static final _coreKeys = Expando<GlobalKey>('NodeBuilder.coreKeys');

  /// Leaf node elements that have been held: they keep their pointer guard
  /// for life, so releasing it never remounts their subtree.
  static final _wasHeld = Expando<bool>('NodeBuilder.wasHeld');

  /// Guarded node elements whose focus is excluded right now, so their
  /// release can apply the autofocus the exclusion swallowed.
  static final _focusHeld = Expando<bool>('NodeBuilder.focusHeld');

  /// Whether any node has been pending or held, so apps that never use an
  /// automatic skeleton skip the [_wasPending], [_coreKeys] and [_wasHeld]
  /// lookups. Process-wide and monotonic: it only gates those lookups.
  static bool _anyWasPending = false;

  static final _visualRoots = Expando<Set<String>>('NodeBuilder.visualRoots');

  static final _warnedUnsized = Expando<bool>('NodeBuilder.warnedUnsized');

  /// The binding roots that shape what [directive] draws — its props, not
  /// event payloads or motion parameters.
  static Set<String> visualRoots(PlainDirective directive) =>
      _visualRoots[directive] ??= CompiledValue.rootsOf(directive.props);

  /// Whether a node at [context] reading [roots] shows as pending: only
  /// inside an automatic skeleton that has not finished, so nodes elsewhere
  /// (or already revealed) reading the same awaited key render as usual.
  /// While no key pends anywhere, or outside a loading skeleton, it returns
  /// without computing [roots] or walking the environment chain.
  static bool isPending(
    BuildContext context,
    Environment env,
    Set<String> Function() roots,
  ) =>
      ScopeEnvironment.pendingKeys > 0 &&
      SkeletonClock.maybeOf(context)?.finished == false &&
      env.pendState(roots()) == PendState.pending;

  static final _treeRoots = Expando<Set<String>>('NodeBuilder.treeRoots');

  /// Whether anything in the subtree of [directive] reads a key that still
  /// waits on an automatic skeleton in [env] — how a pending branch choice
  /// picks the branch that will show the awaited data.
  static bool readsPending(Directive directive, Environment env) =>
      env.pendState(_rootsBelow(directive)) == PendState.pending;

  /// Every outer binding root read in the subtree of [directive]; names a
  /// node defines for its own descendants are left out.
  static Set<String> _rootsBelow(Directive directive) =>
      _treeRoots[directive] ??= switch (directive) {
        PlainDirective node => {
          ...node.roots,
          for (final child in node.children) ..._rootsBelow(child),
          for (final slot in node.slots.values) ..._rootsBelow(slot),
        }..removeAll({...node.provides, ?node.pressedAs}),
        ConditionDirective cond => {
          ...cond.roots,
          for (final branch in cond.branches) ..._rootsBelow(branch.body),
          ...?_maybeRootsBelow(cond.fallback),
        },
        SwitchDirective sw => {
          ...sw.roots,
          for (final branch in sw.cases) ..._rootsBelow(branch.branch),
          ...?_maybeRootsBelow(sw.fallback),
        },
        LoopDirective loop => {
          ...loop.roots,
          ..._rootsBelow(loop.child).difference({loop.as, loop.index}),
        },
        MorphDirective morph => {
          ...morph.roots,
          ..._rootsBelow(morph.child)..removeAll({morph.as, ?morph.velocityAs}),
        },
        ScopeDirective scope => _rootsBelow(
          scope.child,
        ).difference(scope.config.state.keys.toSet()),
      };

  static Set<String>? _maybeRootsBelow(Directive? directive) =>
      directive == null ? null : _rootsBelow(directive);

  /// Builds the observer or scope boundary represented by [directive].
  static Widget build(Directive directive) {
    return switch (directive) {
      PlainDirective node => _plain(node),
      ConditionDirective cond => ConditionObserver(directive: cond),
      LoopDirective loop => LoopObserver(directive: loop),
      MorphDirective morph when morph.spring != null => SpringMorphScope(
        directive: morph,
        child: _continuous(morph.child),
      ),
      MorphDirective morph => MorphScope(
        directive: morph,
        child: morph.repeat ? _continuous(morph.child) : build(morph.child),
      ),
      SwitchDirective sw => SwitchObserver(directive: sw),
      ScopeDirective scope => Scope(
        config: scope.config,
        actions: scope.actions,
        lifecycle: scope.lifecycle,
        skeleton: scope.skeleton == null ? null : build(scope.skeleton!),
        autoSkeleton: scope.autoSkeleton,
        child: build(scope.child),
      ),
    };
  }

  /// Builds [directive] as the direct widget of a continuously animating
  /// morph: a plain node gets its own repaint boundary.
  static Widget _continuous(Directive directive) => directive is PlainDirective
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
  /// Child delivery follows the widget specification; [_layers] then wraps
  /// the result in its decoration, skeleton and identity layers.
  ///
  /// A [pending] node waits on an automatic skeleton: its props resolve
  /// leniently and it draws its spec's [SkeletonForm] — text draws
  /// placeholder words in the real style, icons and media keep their
  /// declared box, any other spec builds for real — events and motion stay
  /// off, and a box leaf paints as bones under a [SkeletonMask]. A [held]
  /// node reads a waiting key anywhere (props, event payloads or motion
  /// parameters) and fires none of its own events until it arrives — a leaf,
  /// or a widget that acts on its own, ignores pointers and focus; a layout
  /// node leaves its children's input working; every pending node is held.
  static Widget assemble(
    BuildContext context,
    PlainDirective directive,
    Environment env, {
    bool isolate = false,
    bool held = false,
    bool pending = false,
  }) {
    final spec = WidgetFactory.specFor(directive.type);
    // A sliver must stay a sliver, so it never takes a box stand-in.
    final form = pending && spec?.produces != LayoutProtocol.sliver
        ? spec?.skeleton
        : null;
    final resolved = pending
        ? _resolveLeniently(directive.props, env)
        : ExpressionEvaluator.resolveMap(directive.props, env);
    if (form == SkeletonForm.text) {
      resolved['value'] = _placeholderText(
        directive.props['value'],
        resolved['max_lines'],
      );
    }
    Map<String, Object?> props = resolved;
    _PropAudit? audit;
    // Property reads become the debug-only schema, avoiding a second catalog
    // that could drift from widget builders. The assertion removes all release cost.
    assert(() {
      audit = _PropAudit(resolved);
      props = audit!;
      return true;
    }());
    // A stand-in skips the spec builder, so its unread props say nothing.
    final standIn = form == SkeletonForm.circle || form == SkeletonForm.box;
    final widget = switch (spec) {
      _ when form == SkeletonForm.circle => SizedBox.square(
        dimension:
            PropsResolver.size(context, props['size']) ??
            IconTheme.of(context).size ??
            24,
      ),
      _ when form == SkeletonForm.box => _box(context, directive, props),
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
      ], held ? null : Scope.actionHost(context)),
      null => throw StateError('Unknown widget type: "${directive.type}".'),
    };
    assert(() {
      if (!standIn) audit?.warnUnread(directive.type, directive.path);
      return true;
    }());
    return _layers(
      context,
      directive,
      spec!,
      env,
      props,
      widget,
      isolate: isolate,
      held: held,
      pending: pending,
    );
  }

  /// Wraps the [core] widget of [directive] in its layers, outermost first:
  ///
  /// 1. `ValueKey(directive.key)` — the node's identity among its siblings.
  /// 2. The parent-data widget (`positioned`, `expanded`, ...) the spec
  ///    built, which must stay the direct widget of its parent; every
  ///    further layer goes around its child ([_inside]).
  /// 3. Pointer and focus guard (once held: a leaf, or a widget that acts on
  ///    its own) — outside every event layer, so a held node takes nothing.
  /// 4. [SkeletonMask] (once pending, box leaves only).
  /// 5. Hold layer (once held, decorated): the decorations below see no
  ///    action host while held, so an event layer that resolves
  ///    [Scope.actionHost] fires nothing even without its own held check.
  /// 6. Decorations ([_decorate]): motion, interaction, scroll events and
  ///    the repaint boundary — present only once the node is not pending.
  /// 7. Restore layer (once held, decorated): the real action host again,
  ///    so the node's children keep firing.
  /// 8. The core key (once pending, or held with motions) around [core]
  ///    alone, so gaining decorations on reveal reparents the core instead
  ///    of remounting it.
  ///
  /// The guard, mask, hold and restore layers stay for the element's life
  /// once added, so a reveal never changes the tree above the core key. A
  /// sliver ([WidgetSpec.produces]) gets a sliver guard and no box layers.
  /// The code builds them innermost first. The hold layer only covers
  /// wrappers that dispatch through [Scope.actionHost] and count toward
  /// `decorated`; an action widget gets no host from [assemble] while held,
  /// and a guarded node applies the autofocus its exclusion dropped on
  /// release.
  static Widget _layers(
    BuildContext context,
    PlainDirective directive,
    WidgetSpec spec,
    Environment env,
    Map<String, Object?> props,
    Widget core, {
    required bool isolate,
    required bool held,
    required bool pending,
  }) {
    // A sliver must stay the direct render child of its viewport, so it never
    // gets a (box) repaint boundary or bones.
    final box = spec.produces != LayoutProtocol.sliver;
    final interactive = directive.on.keys.any(
      InteractionWrapper.events.contains,
    );
    final scrolls = directive.on.keys.any(ScrollEventWrapper.events.contains);
    final decorated =
        directive.motions.isNotEmpty || interactive || scrolls || isolate;
    if (pending) {
      _anyWasPending = true;
      _wasPending[context] = true;
    }
    if (held) {
      _anyWasPending = true;
      _wasHeld[context] = true;
    }
    if (pending || (held && directive.motions.isNotEmpty)) {
      _coreKeys[context] ??= GlobalKey();
    }
    final coreKey = _anyWasPending ? _coreKeys[context] : null;
    final leaf = _isLeaf(directive, spec);
    final masked =
        _anyWasPending && _wasPending[context] != null && leaf && box;
    final wasHeld = _anyWasPending && _wasHeld[context] != null;
    final holding = wasHeld && decorated;
    // A node that acts on its own (dismiss, page, refresh, input) takes no
    // input while held, children included, so it never acts on bones.
    final guarded =
        wasHeld && (leaf || spec is ActionSpec || spec is BoundSpec);
    Widget widget = core;
    if (decorated || masked || guarded) {
      widget = _inside(widget, (child) {
        if (coreKey != null && decorated) {
          child = KeyedSubtree(key: coreKey, child: child);
        }
        final host = holding ? Scope.actionHost(context) : null;
        if (holding) child = Scope.provideActions(host: host, child: child);
        if (!pending && decorated) {
          child = _decorate(
            context,
            directive,
            env,
            props,
            child,
            interactive: interactive,
            scrolls: scrolls,
            isolate: isolate && box,
            box: box,
            held: held,
          );
        }
        if (holding) {
          child = Scope.provideActions(host: held ? null : host, child: child);
        }
        if (masked) {
          child = SkeletonMask(
            pending: pending,
            circle: spec.skeleton == SkeletonForm.circle,
            child: child,
          );
        }
        if (!guarded) return child;
        if (held) {
          _focusHeld[context] = true;
        } else if (_focusHeld[context] != null) {
          _focusHeld[context] = null;
          _autofocusOnRelease(context);
        }
        return ExcludeFocus(
          excluding: held,
          child: box
              ? IgnorePointer(ignoring: held, child: child)
              : SliverIgnorePointer(ignoring: held, sliver: child),
        );
      });
    }
    final key = directive.key;
    return key == null
        ? widget
        : KeyedSubtree(key: ValueKey(key), child: widget);
  }

  /// After the frame that releases a guarded node, asks its scope to
  /// autofocus each `autofocus` text field below [context] — the request their
  /// first build made while focus was excluded and the manager dropped. The
  /// scope applies at most one, and only when nothing in it has focus.
  static void _autofocusOnRelease(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      void visit(Element element) {
        final widget = element.widget;
        if (widget is EditableText && widget.autofocus) {
          widget.focusNode.enclosingScope?.autofocus(widget.focusNode);
        }
        element.visitChildren(visit);
      }

      context.visitChildElements(visit);
    });
  }

  /// Whether a pending [directive] draws its own bones: content leaves (and
  /// specs drawn as their declared box) do, layout nodes leave that to their
  /// children.
  static bool _isLeaf(PlainDirective directive, WidgetSpec spec) =>
      spec.skeleton == SkeletonForm.box ||
      (directive.children.isEmpty && directive.slots.isEmpty);

  /// Resolves each value on its own, so one expression failing on missing
  /// data drops only that value instead of the node's whole geometry.
  static Map<String, Object?> _resolveLeniently(
    Map<String, Object?> props,
    Environment env,
  ) {
    Object? resolve(Object? value) {
      if (value is Map) {
        return {for (final e in value.entries) e.key: resolve(e.value)};
      }
      if (value is List) return [for (final v in value) resolve(v)];
      try {
        return ExpressionEvaluator.resolveValue(value, env);
      } on FormatException {
        return null;
      } on StateError {
        return null;
      }
    }

    return {for (final e in props.entries) e.key: resolve(e.value)};
  }

  static const _placeholderWord = '000000';

  /// Stand-in text for a pending `text` [value]: each binding becomes a
  /// placeholder word and literal fragments (and their line breaks) stay. A
  /// value whose lines come from data spans [maxLines] lines (or one).
  static String _placeholderText(Object? value, Object? maxLines) {
    final text = value is Interpolation
        ? value.parts
              .map((part) => part is Expression ? _placeholderWord : '$part')
              .join()
        : _placeholderWord;
    if (text.contains('\n')) return text;
    final lines = PropsResolver.integer(maxLines) ?? 1;
    return List.filled(lines < 1 ? 1 : lines, text).join('\n');
  }

  /// A pending [SkeletonForm.box] node's declared box; an unsized one has
  /// nothing to hold.
  static Widget _box(
    BuildContext context,
    PlainDirective directive,
    Map<String, Object?> props,
  ) {
    final width = PropsResolver.size(context, props['width']);
    final height = PropsResolver.size(context, props['height']);
    if (width == null && height == null && _warnedUnsized[directive] == null) {
      _warnedUnsized[directive] = true;
      EngineLog.warn(
        '${directive.type} @${directive.path} has no width/height — its '
        'automatic skeleton bone collapses until it loads.',
        tag: 'widget',
      );
    }
    return SizedBox(width: width, height: height);
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
  /// repaint-boundary layers. Only a [box] node gets repaint boundaries; a
  /// [held] node's event layers fire nothing and its motions wait, since
  /// their parameters may still miss the awaited data.
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
    required bool held,
  }) {
    final off = _offMotions[context];
    for (final (index, motion) in directive.motions.indexed) {
      if (held || (off != null && off.contains(index))) continue;
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
        // means nothing in the scope that declares the action. A held node
        // fires nothing, so its payloads may still miss the awaited data.
        payloads: held
            ? _resolveLeniently(directive.onEvent, env)
            : ExpressionEvaluator.resolveMap(directive.onEvent, env),
        feedback: directive.tapFeedback,
        onPressed: directive.pressedAs == null ? null : PressScope.of(context),
        held: held,
        child: widget,
      );
    }
    if (scrolls) {
      widget = ScrollEventWrapper(
        on: directive.on,
        timing: directive.timing,
        endThreshold: PropsResolver.number(props['end_threshold']),
        startThreshold: PropsResolver.number(props['start_threshold']),
        held: held,
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
