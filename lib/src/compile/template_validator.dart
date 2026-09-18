import 'package:meta/meta.dart';

import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'schema/language_catalog.dart';
import 'schema/widget_schema.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'invalid_template_exception.dart';

/// Validates template declarations and structural contracts before mounting.
///
/// Every referenced top-level binding root must exist in its lexical declaration
/// chain, including root data, enclosing scope state, and loop frames. Nested
/// properties remain nullable at runtime. Validation covers inactive branches so
/// template defects cannot remain hidden until a branch is selected.
final class TemplateValidator {
  const TemplateValidator._();

  /// The recognized `_loop._wrap` strategies.
  static const Set<String> _knownWraps = {
    'column',
    'row',
    'wrap',
    'serpentine',
    'serpentine_row',
    'spin_grid',
    'auto_scroll',
    'swipe',
    'list',
    'sliver_list',
    'grid',
    'sliver_grid',
    'reorderable',
    'dismissible',
  };

  /// The recognized `_loop._wrap` strategies, for cross-checking against
  /// [LoopObserver]'s dispatch in tests.
  ///
  /// Compile-time validation and runtime expansion are two separate sources
  /// of truth over the same strategy names; without this seam a name added
  /// here with no matching case in the observer's switch degrades silently
  /// into a bare column instead of failing loudly.
  @visibleForTesting
  static const Set<String> knownWraps = _knownWraps;

  /// Returns the render protocol produced by [wrap].
  static LayoutProtocol _wrapProduces(String wrap) =>
      (wrap == 'sliver_list' || wrap == 'sliver_grid')
      ? LayoutProtocol.sliver
      : LayoutProtocol.box;

  /// Validates [root] using [declared] as the outermost binding declarations.
  ///
  /// Throws [InvalidTemplateException] for undeclared references, invalid action
  /// references, unknown catalog entries, or incompatible structural contracts.
  /// The catalog for the current [validate] call. Compilation is synchronous
  /// and single-isolate, so a call-scoped static avoids threading the catalog
  /// through every private helper.
  static LanguageCatalog _catalog = LanguageCatalog(
    widgets: const {},
    commands: const {},
  );

  static void validate(
    Directive root,
    Set<String> declared, {
    LanguageCatalog? catalog,
  }) {
    _catalog = catalog ?? LanguageCatalog.fromRegistries();
    // Root data is writable through the root scope. An engine root is mounted
    // under a box parent, so a bare sliver is structurally invalid.
    _walk(root, declared, declared, const {}, LayoutProtocol.box);
  }

  /// Validates one directive within its lexical environment.
  ///
  /// [declared] controls reads, [writable] controls direct bindings, [actions]
  /// contains visible named actions, and [expected] is the parent's required
  /// layout protocol. Frame variables are readable but not writable.
  static void _walk(
    Directive directive,
    Set<String> declared,
    Set<String> writable,
    Set<String> actions,
    LayoutProtocol? expected,
  ) {
    switch (directive) {
      case PlainDirective node:
        // Resolve widget types before any branch can defer the failure to runtime.
        final schema = _catalog.widgets[node.type];
        if (schema == null) {
          throw InvalidTemplateException(
            node.path,
            'unknown widget type "${node.type}" — not a registered widget (typo?).',
          );
        }
        // The produced render protocol must satisfy the parent contract.
        _checkProtocol(node.path, '"${node.type}"', schema.produces, expected);
        _checkChildShape(schema, node);
        // Bound inputs write directly, so their keys must be validated before a
        // user interaction can throw outside node isolation.
        if (schema.kind == WidgetKind.bound) _checkBind(node, writable);
        _checkMotions(node);
        _check(node.roots, declared, node.path);
        _checkCalls(CompiledValue.callsOf(node.props), node.path);
        _checkInteractions(node.on, actions, node.path, schema);
        // Builder-provided variables are declarations only for descendants.
        final childDeclared = node.provides.isEmpty
            ? declared
            : {...declared, ...node.provides};
        // A null child protocol permits widgets with mixed child protocols.
        final childExpected = schema.childProtocol;
        for (final child in node.children) {
          _walk(child, childDeclared, writable, actions, childExpected);
        }
        for (final slot in node.slots.values) {
          _walk(slot, childDeclared, writable, actions, childExpected);
        }
      case ConditionDirective cond:
        // Transparent directives pass the parent's protocol requirement to each
        // possible rendered branch.
        _check(cond.roots, declared, cond.path);
        for (final branch in cond.branches) {
          _walk(branch.body, declared, writable, actions, expected);
        }
        final fallback = cond.fallback;
        if (fallback != null) {
          _walk(fallback, declared, writable, actions, expected);
        }
      case SwitchDirective sw:
        _check(sw.roots, declared, sw.path);
        for (final branch in sw.cases) {
          _walk(branch.branch, declared, writable, actions, expected);
        }
        final fallback = sw.fallback;
        if (fallback != null) {
          _walk(fallback, declared, writable, actions, expected);
        }
      case LoopDirective loop:
        // Wrap names pass through compilation, so validate them before observer
        // dispatch can encounter an unknown strategy.
        if (!_knownWraps.contains(loop.wrap)) {
          throw InvalidTemplateException(
            loop.path,
            'unknown loop layout "${loop.wrap}" — not a registered _wrap strategy (typo?).',
          );
        }
        // The container must match its parent; repeated items always use the box
        // protocol inside the selected container.
        _checkProtocol(
          loop.path,
          '_loop._wrap "${loop.wrap}"',
          _wrapProduces(loop.wrap),
          expected,
        );
        _check(loop.roots, declared, loop.path);
        // Loop frame variables are readable only within the repeated child.
        _walk(
          loop.child,
          {...declared, loop.as, loop.index},
          writable,
          actions,
          LayoutProtocol.box,
        );
      case MorphDirective morph:
        _check(morph.roots, declared, morph.path);
        // A morph variable is readable by its child but is not mutable state.
        _walk(
          morph.child,
          {...declared, morph.as},
          writable,
          actions,
          expected,
        );
      case ScopeDirective scope:
        // Scope state and actions extend the child's lexical environment.
        final stateKeys = scope.config.state.keys.toSet();
        final scopeDeclared = {...declared, ...stateKeys};
        // `set` targets only the defining scope, while `bind` walks to the nearest
        // declaring scope; their writable sets therefore differ deliberately.
        _checkActions(scope.actions, scopeDeclared, stateKeys, scope.path);
        _walk(
          scope.child,
          scopeDeclared,
          {...writable, ...stateKeys},
          {...actions, ...scope.actions.keys},
          expected, // A scope is transparent to the parent's layout protocol.
        );
    }
  }

  /// Verifies that [produced] satisfies the parent's [expected] layout protocol.
  ///
  /// A `null` expectation permits mixed protocols. Mismatches throw before
  /// Flutter can raise a render assertion outside node isolation. [what]
  /// identifies the producer in diagnostics.
  static void _checkProtocol(
    String path,
    String what,
    LayoutProtocol produced,
    LayoutProtocol? expected,
  ) {
    if (expected == null || produced == expected) return;
    final need = expected == LayoutProtocol.sliver ? 'sliver' : 'box';
    final got = produced == LayoutProtocol.sliver ? 'sliver' : 'box';
    throw InvalidTemplateException(
      path,
      'layout protocol mismatch: $what produces $got but its parent requires a $need child '
      '($need is valid only ${need == 'sliver' ? 'inside a sliver viewport (custom_scroll_view, etc.)' : 'inside a box parent'} '
      '— a box↔sliver misplacement crashes at render time).',
    );
  }

  /// Verifies that a bound input targets a writable declared state key.
  ///
  /// Input callbacks write directly and execute outside node error isolation, so
  /// invalid literal keys must fail at mount time. Nonliteral bind values cannot
  /// be checked statically and are skipped.
  static void _checkBind(PlainDirective node, Set<String> writable) {
    final bind = node.props['bind'];
    if (bind is! String || bind.isEmpty) return;
    if (!writable.contains(bind)) {
      throw InvalidTemplateException(
        node.path,
        'bind writes to undeclared state key "$bind" — not found in the enclosing _scope._state (or rootData) '
        '(an input writes that key directly, so an undeclared key crashes on the first input; typo?).',
      );
    }
  }

  /// Verifies that a node's child shape matches its [WidgetSchema].
  ///
  /// The building layer reads only the child form supported by the specification;
  /// rejecting mismatches prevents unsupported children from being discarded.
  static void _checkChildShape(WidgetSchema schema, PlainDirective node) {
    final hasChildren = node.children.isNotEmpty;
    final hasSlots = node.slots.isNotEmpty;
    // Exhaustiveness requires every new widget specification to define its child
    // shape here as well as in assembly.
    switch (schema.kind) {
      // Positional specifications do not consume named slots.
      case WidgetKind.eager:
      case WidgetKind.builder:
      case WidgetKind.action:
        if (hasSlots) {
          throw InvalidTemplateException(
            node.path,
            'widget "${node.type}" was given `_slots` but is not a slot widget — the building layer never reads them, so they are silently dropped.',
          );
        }
      // Slot specifications do not consume positional children.
      case WidgetKind.slot:
        if (hasChildren) {
          throw InvalidTemplateException(
            node.path,
            'widget "${node.type}" was given positional children (`_child`/`_children`) — a slot widget reads only `_slots`, so they are silently dropped.',
          );
        }
      // Self-binding inputs do not consume either child form.
      case WidgetKind.bound:
        if (hasChildren || hasSlots) {
          throw InvalidTemplateException(
            node.path,
            'widget "${node.type}" was given children/`_slots` but an input widget takes no children — they are silently dropped.',
          );
        }
    }
  }

  /// Verifies that `_on` events and their named actions are valid at this node.
  ///
  /// Resolving references before mount prevents misspelled actions from failing
  /// only when the user triggers an interaction.
  static void _checkInteractions(
    Map<String, String> on,
    Set<String> actions,
    String path,
    WidgetSchema schema,
  ) {
    for (final entry in on.entries) {
      final event = entry.key;
      final name = entry.value;
      if (InteractionEvents.input.contains(event) &&
          schema.kind != WidgetKind.bound) {
        throw InvalidTemplateException(
          path,
          '"_on.$event" works only on input widgets (text_field/checkbox/…) — this widget does not support it.',
        );
      }
      if (!actions.contains(name)) {
        throw InvalidTemplateException(
          path,
          'interaction references unknown action "$name" '
          '(not defined in the _action of the enclosing scope).',
        );
      }
    }
  }

  /// Validates action parameter reads and writes within their runtime environments.
  ///
  /// Driver semantics are opaque, but compiled binding roots remain checkable.
  /// The built-in `set` command may write only the defining scope's state. Handler
  /// shadows mirror runtime exactly: `_then` adds `$data`, `_error` adds
  /// `$error`, and `_always` adds neither; all are read-only.
  static void _checkActions(
    Map<String, Action> actions,
    Set<String> declared,
    Set<String> writable,
    String path,
  ) {
    for (final action in actions.values) {
      // `$event` is an optional read-only runtime shadow available throughout an
      // invoked action. Without a payload, normal nullable resolution applies.
      _checkFlow(action.steps, {...declared, 'event'}, writable, path);
    }
  }

  static void _checkFlow(
    Flow flow,
    Set<String> declared,
    Set<String> writable,
    String path,
  ) {
    for (final batch in flow) {
      for (final command in batch) {
        _checkCommand(command, declared, writable, path);
      }
    }
  }

  /// Rejects `_motion` names absent from the catalog (when it enumerates them).
  static void _checkMotions(PlainDirective node) {
    final known = _catalog.motions;
    if (known == null) return;
    for (final motion in node.motions) {
      if (!known.contains(motion.type)) {
        throw InvalidTemplateException(
          node.path,
          'unknown motion "${motion.type}" — not a registered motion or preset (typo?).',
        );
      }
    }
  }

  /// Rejects expression function calls absent from the catalog (when it
  /// enumerates them).
  static void _checkCalls(Set<String> calls, String path) {
    final known = _catalog.functions;
    if (known == null) return;
    for (final name in calls) {
      if (!known.contains(name)) {
        throw InvalidTemplateException(
          path,
          'unknown function "$name(...)" — not a registered expression function (typo?).',
        );
      }
    }
  }

  static void _checkCommand(
    Command command,
    Set<String> declared,
    Set<String> writable,
    String path,
  ) {
    // Resolve driver types before interaction can defer the failure to runtime.
    if (!_catalog.commands.contains(command.type)) {
      throw InvalidTemplateException(
        path,
        'unknown driver type "${command.type}" — not a registered driver (typo?).',
      );
    }
    _check(CompiledValue.rootsOf(command.params), declared, path);
    _checkCalls(CompiledValue.callsOf(command.params), path);
    final when = command.when;
    if (when != null) {
      _check(when.roots, declared, path);
      _checkCalls(when.calls, path);
    }
    if (command.type == 'set') {
      for (final key in command.params.keys) {
        if (!writable.contains(key)) {
          throw InvalidTemplateException(
            path,
            'set writes to undeclared state key "$key" — not found in the _state of this scope '
            '(writes, unlike reads, do not walk the scope chain; to target an ancestor key, define the action in that scope).',
          );
        }
      }
    }
    // Handler declarations intentionally mirror their runtime shadows.
    final then = command.then;
    if (then != null) {
      _checkFlow(then, {...declared, 'data'}, writable, path);
    }
    final onError = command.onError;
    if (onError != null) {
      for (final flow in onError.values) {
        _checkFlow(flow, {...declared, 'error'}, writable, path);
      }
    }
    final always = command.always;
    if (always != null) _checkFlow(always, declared, writable, path);
  }

  /// Throws for any root in [refs] that is absent from [declared].
  static void _check(Set<String> refs, Set<String> declared, String path) {
    for (final root in refs) {
      if (!declared.contains(root)) {
        throw InvalidTemplateException(
          path,
          'undeclared binding root "\$$root" — not declared '
          '(absent from rootData, _scope._state, and loop frames).',
        );
      }
    }
  }
}
