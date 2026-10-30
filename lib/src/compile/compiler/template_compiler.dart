import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/engine_curve.dart';
import 'package:sdui_engine/src/ir/model/engine_spring.dart';
import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/ir/model/lifecycle_hook.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/ir/compiled_value.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/model/ui_node.dart';
import '../invalid_template_exception.dart';
import '../schema/builtin_language.dart';
import '../template_parser.dart';
import 'action_compiler.dart';
import 'value_compiler.dart';

/// Compiles parsed [UiNode] trees into directives for the rendering runtime.
///
/// Reserved markers become typed structural wrappers, while properties and
/// parameters become compiled values. Marker shape and expression syntax fail
/// here so the runtime only interprets a structurally valid directive tree.
final class TemplateCompiler {
  const TemplateCompiler._();

  static const _switchType = 'switch';
  static const _condType = 'cond';

  static const _allMarkers = {
    '_if',
    '_loop',
    '_morph',
    '_scope',
    '_on',
    '_motion',
    '_provides',
  };

  static const _condAllowedKeys = {'_if', '_loop', '_scope'};
  static const _switchAllowedKeys = {'_value', '_if', '_loop', '_scope'};

  static const _knownEvents = InteractionEvents.all;

  static const _condMarkers = {'_if', '_else'};

  static const _switchMarkers = {'_case', '_default'};

  /// Engine features a template root may declare under `_requires`.
  ///
  /// Engines that predate `_requires` reject it as an unknown reserved key,
  /// so a template that needs a feature fails to compile on an engine
  /// without it instead of rendering partially.
  static const knownFeatures = {
    // 0.7.0
    'spring_v1',
    'shape_v1',
    'math_v1',
    'align_xy_v1',
    // 0.9.0: `_morph._velocity`.
    'spring_v2',
    // 0.9.0: cubic-bezier lists, Material 3 and spring curve names.
    'curve_v2',
    // 0.9.0: `_motion` `repeat: <count>` and `repeat_delay`.
    'motion_repeat_v1',
    // 0.9.0: `_on.tap.pressed_as`.
    'press_v1',
    // 0.9.0: `transform: { offset: [x, y] }`.
    'transform_offset_v1',
    // 0.9.0: `smoothstep`, `sign`.
    'math_v2',
    // 0.9.0: `_motion` / `_on` on positioned, expanded and flexible nodes.
    'parent_data_motion_v1',
    // 0.9.0: `shape` op, per-item smooth, `at`, gradient fill/rim, shadow,
    // backdrop.
    'shape_v2',
    // 0.9.0: the `semantics` widget.
    'semantics_v1',
    // 0.9.0: the `layout_builder` widget.
    'layout_builder_v1',
    // 0.13.0: `_motion` `start: "mount"`.
    'motion_start_v1',
  };

  /// Builds the directive tree for a template root.
  ///
  /// Checks and consumes the root-only `_requires` declaration, then builds
  /// the tree like [buildDirectiveTree]. Throws [InvalidTemplateException]
  /// when `_requires` is not a list of known feature names.
  static Directive buildRoot(UiNode node) {
    if (!node.reserved.containsKey('_requires')) {
      return buildDirectiveTree(node);
    }
    final raw = node.reserved['_requires'];
    if (raw is! List) {
      throw InvalidTemplateException(
        node.path,
        '"_requires" must be a list of feature names.',
      );
    }
    for (final feature in raw) {
      if (!knownFeatures.contains(feature)) {
        throw InvalidTemplateException(
          node.path,
          'unknown "_requires" feature "$feature" '
          '(supported: ${knownFeatures.join(", ")}).',
        );
      }
    }
    return buildDirectiveTree(
      UiNode(
        type: node.type,
        props: node.props,
        reserved: {
          for (final entry in node.reserved.entries)
            if (entry.key != '_requires') entry.key: entry.value,
        },
        children: node.children,
        slots: node.slots,
        key: node.key,
        path: node.path,
      ),
    );
  }

  /// Builds the directive tree rooted at [node].
  ///
  /// Structural wrappers are applied from the node outward as morph, scope,
  /// condition, and loop boundaries. Throws [InvalidTemplateException] when a
  /// marker, control-flow branch, or embedded expression is invalid.
  static Directive buildDirectiveTree(UiNode node) {
    Directive directive;
    if (node.type == _condType) {
      _rejectControlResiduals(node, _condAllowedKeys);
      directive = _buildCond(node);
    } else if (node.type == _switchType) {
      _rejectControlResiduals(node, _switchAllowedKeys);
      directive = _buildSwitch(node);
    } else {
      _rejectUnknownReserved(node);
      final motions = _parseMotion(node);
      final props = ValueCompiler.map(node.props, node.path);
      final onSpec = _parseOn(node);
      directive = PlainDirective(
        type: node.type,
        props: props,
        key: node.key,
        path: node.path,
        on: onSpec.actions,
        timing: onSpec.timing,
        onEvent: onSpec.payloads,
        tapFeedback: onSpec.tapFeedback,
        pressedAs: onSpec.pressedAs,
        motions: motions,
        provides: _parseProvides(node),
        roots: {
          ...CompiledValue.rootsOf(props),
          ...CompiledValue.rootsOf(onSpec.payloads),
          for (final m in motions) ...CompiledValue.rootsOf(m.params),
        },
        children: [
          for (final child in node.children) buildDirectiveTree(child),
        ],
        slots: {
          for (final entry in node.slots.entries)
            entry.key: buildDirectiveTree(entry.value),
        },
      );
    }
    // This order defines lexical visibility and execution order: morph is the
    // innermost boundary and loop is the outermost boundary.
    directive = _wrapMorph(node, directive);
    directive = _wrapScope(node, directive);
    directive = _wrapIf(node, directive);
    directive = _wrapLoop(node, directive);
    return directive;
  }

  static Directive _buildCond(UiNode node) {
    final branches = <({Expression predicate, Directive body})>[];
    Directive? fallback;
    for (final child in node.children) {
      final hasIf = child.reserved.containsKey('_if');
      final hasElse = child.reserved.containsKey('_else');
      if (hasIf == hasElse) {
        throw InvalidTemplateException(
          child.path,
          'cond child needs exactly one of "_if"/"_else".',
        );
      }
      final body = buildDirectiveTree(_without(child, _condMarkers));
      if (hasElse) {
        if (child.reserved['_else'] != true) {
          throw InvalidTemplateException(
            child.path,
            'cond "_else" must be literally true.',
          );
        }
        if (fallback != null) {
          throw InvalidTemplateException(
            child.path,
            'cond has multiple "_else" branches.',
          );
        }
        fallback = body;
        continue;
      }
      final predicate = child.reserved['_if'];
      if (predicate is! String || predicate.isEmpty) {
        throw InvalidTemplateException(
          child.path,
          'cond "_if" must be a non-empty string.',
        );
      }
      branches.add((
        predicate: _compileExpr(predicate, child.path),
        body: body,
      ));
    }
    if (branches.isEmpty && fallback == null) {
      throw InvalidTemplateException(
        node.path,
        'cond needs at least one "_if" branch or an "_else" fallback.',
      );
    }
    return ConditionDirective(
      branches: branches,
      fallback: fallback,
      path: node.path,
    );
  }

  static Directive _buildSwitch(UiNode node) {
    final rawSelector = node.reserved['_value'];
    if (rawSelector is! String || rawSelector.isEmpty) {
      throw InvalidTemplateException(
        node.path,
        'switch needs a non-empty string "_value" selector.',
      );
    }
    final selector = _compileExpr(rawSelector, node.path);
    final cases = <({Object? value, Directive branch})>[];
    final seen = <Object?>{};
    Directive? fallback;
    for (final child in node.children) {
      final hasCase = child.reserved.containsKey('_case');
      final hasDefault = child.reserved.containsKey('_default');
      if (hasCase == hasDefault) {
        throw InvalidTemplateException(
          child.path,
          'switch child needs exactly one of "_case"/"_default".',
        );
      }
      final body = buildDirectiveTree(_without(child, _switchMarkers));
      if (hasDefault) {
        if (child.reserved['_default'] != true) {
          throw InvalidTemplateException(
            child.path,
            'switch "_default" must be literally true.',
          );
        }
        if (fallback != null) {
          throw InvalidTemplateException(
            child.path,
            'switch has multiple "_default" branches.',
          );
        }
        fallback = body;
        continue;
      }
      final label = child.reserved['_case'];
      if (label is! String && label is! num && label is! bool) {
        throw InvalidTemplateException(
          child.path,
          '"_case" must be a String, num, or bool (got ${label.runtimeType}).',
        );
      }
      if (label is String && label.contains(r'${')) {
        throw InvalidTemplateException(
          child.path,
          '"_case" must be a literal, not an expression ("$label").',
        );
      }
      if (!seen.add(label)) {
        throw InvalidTemplateException(
          child.path,
          'switch has a duplicate case "$label".',
        );
      }
      cases.add((value: label, branch: body));
    }
    if (cases.isEmpty) {
      throw InvalidTemplateException(
        node.path,
        'switch needs at least one "_case".',
      );
    }
    return SwitchDirective(
      selector: selector,
      cases: cases,
      fallback: fallback,
      path: node.path,
    );
  }

  static Expression _compileExpr(String source, String path) =>
      ValueCompiler.wholeExpression(source, path);

  static void _rejectReserved(String name, String what, String path) {
    if (name.startsWith('_')) {
      throw InvalidTemplateException(
        path,
        '$what "$name" must not start with "_" (reserved for engine keys).',
      );
    }
  }

  static final _identifier = RegExp(r'^[A-Za-z][A-Za-z0-9_]*$');

  static void _requireBindableName(String name, String what, String path) {
    if (!_identifier.hasMatch(name)) {
      throw InvalidTemplateException(
        path,
        '$what "$name" must be a bindable identifier '
        r'([A-Za-z][A-Za-z0-9_]*) — referenced as "$'
        '$name".',
      );
    }
  }

  static void _rejectUnknownReserved(UiNode node) {
    for (final key in node.reserved.keys) {
      if (!_allMarkers.contains(key)) {
        throw InvalidTemplateException(
          node.path,
          'unknown reserved key "$key" (engine keys are a fixed set; '
          'widget props must not start with "_").',
        );
      }
    }
  }

  static void _rejectControlResiduals(
    UiNode node,
    Set<String> allowedReserved,
  ) {
    if (node.props.isNotEmpty) {
      throw InvalidTemplateException(
        node.path,
        '"${node.type}" is a control node and takes no widget props '
        '(got "${node.props.keys.first}").',
      );
    }
    for (final key in node.reserved.keys) {
      if (!allowedReserved.contains(key)) {
        throw InvalidTemplateException(
          node.path,
          '"${node.type}" node does not support key "$key" '
          '(allowed: ${allowedReserved.join(", ")}).',
        );
      }
    }
  }

  static UiNode _without(UiNode node, Set<String> keys) {
    if (!node.reserved.keys.any(keys.contains)) return node;
    return UiNode(
      type: node.type,
      props: node.props,
      reserved: {
        for (final entry in node.reserved.entries)
          if (!keys.contains(entry.key)) entry.key: entry.value,
      },
      children: node.children,
      key: node.key,
      path: node.path,
    );
  }

  static const _scopeAllowedKeys = {
    '_state',
    '_action',
    '_lifecycle',
    '_skeleton',
  };

  static const _morphAllowedKeys = {
    '_from',
    '_to',
    '_as',
    '_duration',
    '_curve',
    '_delay',
    '_trigger',
    '_repeat',
    '_reverse',
    '_spring',
    '_velocity',
  };

  /// `_morph` keys that configure the tween and so conflict with `_spring`.
  static const _tweenOnlyKeys = {'_duration', '_curve', '_repeat', '_reverse'};

  /// Builds the `_morph` directive around [child].
  ///
  /// Only typos fail compilation: an unknown key, an unbindable `_as` or
  /// `_velocity` name, an unknown spring preset or spring key. Other misuse
  /// degrades: without a map or an `_as` name the morph is dropped, a
  /// non-string or empty `_velocity` drops that variable, and a malformed
  /// value or a conflicting or out-of-range `_spring` yields a morph without
  /// animation, whose variable takes `_to` at once.
  static Directive _wrapMorph(UiNode node, Directive child) {
    if (!node.reserved.containsKey('_morph')) return child;
    final raw = node.reserved['_morph'];
    if (raw is! Map) return child;
    for (final key in raw.keys) {
      if (!_morphAllowedKeys.contains(key)) {
        throw InvalidTemplateException(
          node.path,
          'unknown "_morph" key "$key" '
          '(allowed: ${_morphAllowedKeys.join(", ")}).',
        );
      }
    }
    final as = raw['_as'];
    if (as is! String || as.isEmpty) return child;
    _requireBindableName(as, 'morph "_as" name', node.path);
    final velocity = raw['_velocity'];
    final velocityAs = velocity is String && velocity.isNotEmpty
        ? velocity
        : null;
    if (velocityAs != null) {
      _requireBindableName(velocityAs, 'morph "_velocity" name', node.path);
    }

    var malformed = false;
    Expression? expression(String key) {
      if (!raw.containsKey(key)) return null;
      final source = switch (raw[key]) {
        String value when value.isNotEmpty => value,
        num value => '\${$value}',
        bool value => '\${$value}',
        _ => null,
      };
      if (source == null) {
        malformed = true;
        return null;
      }
      return _compileExpr(source, node.path);
    }

    final to = expression('_to');
    final from = expression('_from');
    final trigger = expression('_trigger');
    final curve = raw['_curve'] ?? 'ease_out';
    // A spring curve without `_duration` runs for its settle time, which the
    // runtime derives (null).
    final duration =
        raw['_duration'] ??
        (EngineCurveNames.spring.contains(curve) ? null : 400);
    final delay = raw['_delay'] ?? 0;
    final repeat = raw['_repeat'] ?? false;
    final reverse = raw['_reverse'] ?? false;
    final hasSpring = raw.containsKey('_spring');
    final spring = hasSpring ? _morphSpring(raw['_spring'], node.path) : null;
    final springMisused =
        hasSpring && (spring == null || raw.keys.any(_tweenOnlyKeys.contains));
    final target = to ?? _compileExpr(r'${null}', node.path);

    if (malformed ||
        to == null ||
        springMisused ||
        (duration != null && (duration is! int || duration < 0)) ||
        (curve is! String && curve is! List) ||
        delay is! int ||
        delay < 0 ||
        repeat is! bool ||
        reverse is! bool ||
        (repeat && duration == 0)) {
      return MorphDirective(
        to: target,
        from: from,
        as: as,
        durationMs: 0,
        curve: 'linear',
        trigger: trigger,
        velocityAs: velocityAs,
        child: child,
        path: node.path,
      );
    }
    return MorphDirective(
      to: target,
      from: from,
      as: as,
      durationMs: duration as int?,
      curve: curve,
      delayMs: delay,
      repeat: repeat,
      reverse: reverse,
      trigger: trigger,
      spring: spring,
      velocityAs: velocityAs,
      child: child,
      path: node.path,
    );
  }

  /// Decodes `_morph._spring`: a preset name or a literal parameter map.
  ///
  /// An unknown preset name or map key is a typo and throws. Any other
  /// malformed value (an expression, another type, a missing, out-of-range
  /// or non-finite parameter) returns `null`, so the morph loses animation.
  static EngineSpringSpec? _morphSpring(Object? spring, String path) {
    if (spring is String) {
      if (spring.contains(r'${')) return null;
      final preset = EngineSpringNames.presets[spring];
      if (preset == null) {
        throw InvalidTemplateException(
          path,
          'unknown "_morph._spring" preset "$spring" (a literal preset name; '
          'supported: ${EngineSpringNames.presets.keys.join(", ")}).',
        );
      }
      return preset;
    }
    if (spring is! Map) return null;
    const params = BuiltinLanguage.springParams;
    for (final key in spring.keys) {
      if (!params.containsKey(key)) {
        throw InvalidTemplateException(
          path,
          'unknown "_morph._spring" key "$key" '
          '(allowed: ${params.keys.join(", ")}).',
        );
      }
    }
    double? param(String key, {double? fallback}) {
      final value = spring[key];
      if (value == null) return fallback;
      final range = params[key]!;
      final inRange =
          value is num &&
          value.isFinite &&
          value >= range.min! &&
          value <= range.max!;
      return inRange ? value.toDouble() : null;
    }

    final stiffness = param('stiffness');
    final dampingRatio = param('damping_ratio');
    final mass = param('mass', fallback: 1);
    if (stiffness == null || dampingRatio == null || mass == null) return null;
    return EngineSpringSpec(
      stiffness: stiffness,
      dampingRatio: dampingRatio,
      mass: mass,
    );
  }

  static const _lifecycleTriggers = {
    'mount': LifecycleTrigger.mount,
    'render': LifecycleTrigger.render,
    'remount': LifecycleTrigger.remount,
    'interval': LifecycleTrigger.interval,
    'dispose': LifecycleTrigger.dispose,
  };

  static Directive _wrapScope(UiNode node, Directive child) {
    if (!node.reserved.containsKey('_scope')) return child;
    final raw = node.reserved['_scope'];
    if (raw is! Map) {
      throw InvalidTemplateException(node.path, 'Prop "_scope" must be a map.');
    }
    final config = raw.cast<String, Object?>();
    for (final key in config.keys) {
      if (!_scopeAllowedKeys.contains(key)) {
        throw InvalidTemplateException(
          node.path,
          'unknown "_scope" key "$key" '
          '(allowed: ${_scopeAllowedKeys.join(", ")}).',
        );
      }
    }
    if (config.containsKey('_state')) {
      final state = config['_state'];
      if (state is! Map) {
        throw InvalidTemplateException(
          node.path,
          '"_scope._state" must be a map.',
        );
      }
      for (final name in state.keys) {
        _requireBindableName('$name', 'state name', node.path);
      }
    }
    if (config.containsKey('_action') && config['_action'] == null) {
      throw InvalidTemplateException(
        node.path,
        '"_scope._action" must not be null.',
      );
    }
    if (config.containsKey('_lifecycle') && config['_lifecycle'] == null) {
      throw InvalidTemplateException(
        node.path,
        '"_scope._lifecycle" must not be null.',
      );
    }
    // `auto` draws the skeleton from the real tree; a map is a hand-drawn
    // override of this scope.
    final rawSkeleton = config['_skeleton'];
    final autoSkeleton = rawSkeleton == 'auto';
    Directive? skeleton;
    if (rawSkeleton != null && !autoSkeleton) {
      if (rawSkeleton is! Map) {
        throw InvalidTemplateException(
          node.path,
          '"_scope._skeleton" must be "auto" or a map.',
        );
      }
      skeleton = buildDirectiveTree(
        TemplateParser.buildUiTree(
          rawSkeleton.cast(),
          path: '${node.path}/_skeleton',
        ),
      );
    }
    return ScopeDirective(
      config: ScopeConfig.fromRaw(config),
      child: child,
      skeleton: skeleton,
      autoSkeleton: autoSkeleton,
      path: node.path,
      actions: _compileActions(config['_action'], node.path),
      lifecycle: _compileLifecycle(config['_lifecycle'], node.path),
    );
  }

  static List<LifecycleHook> _compileLifecycle(Object? raw, String path) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw InvalidTemplateException(
        path,
        '"_scope._lifecycle" must be a list of {on, action, ...}.',
      );
    }
    final hooks = <LifecycleHook>[];
    for (final entry in raw) {
      if (entry is! Map) {
        throw InvalidTemplateException(
          path,
          'each "_lifecycle" entry must be a map.',
        );
      }
      final on = entry['on'];
      final trigger = on is String ? _lifecycleTriggers[on] : null;
      if (trigger == null) {
        throw InvalidTemplateException(
          path,
          'unknown "_lifecycle.on" "$on" '
          '(supported: ${_lifecycleTriggers.keys.join(", ")}).',
        );
      }
      final action = entry['action'];
      if (action is! String || action.isEmpty) {
        throw InvalidTemplateException(
          path,
          '"_lifecycle.action" must reference a non-empty action name.',
        );
      }
      final delay = _durationMs(entry['delay']) ?? Duration.zero;
      Duration? every;
      if (trigger == LifecycleTrigger.interval) {
        every = _durationMs(entry['every']);
        if (every == null || every <= Duration.zero) {
          throw InvalidTemplateException(
            path,
            '"_lifecycle" interval requires a positive "every" (ms).',
          );
        }
      } else if (entry.containsKey('every')) {
        throw InvalidTemplateException(
          path,
          '"_lifecycle.every" is only valid for the "interval" trigger.',
        );
      }
      hooks.add(
        LifecycleHook(
          trigger: trigger,
          action: action,
          delay: delay,
          every: every,
        ),
      );
    }
    return hooks;
  }

  static Duration? _durationMs(Object? raw) =>
      raw is num && raw.isFinite && raw >= 0
      ? Duration(milliseconds: raw.round())
      : null;

  static Set<String> _parseProvides(UiNode node) {
    final raw = node.reserved['_provides'];
    if (raw == null) return const {};
    if (raw is! List) {
      throw InvalidTemplateException(
        node.path,
        '"_provides" must be a list of variable names.',
      );
    }
    final names = <String>{};
    for (final item in raw) {
      if (item is! String || item.isEmpty) {
        throw InvalidTemplateException(
          node.path,
          '"_provides" entries must be non-empty strings.',
        );
      }
      _requireBindableName(item, 'provided var "$item"', node.path);
      names.add(item);
    }
    return names;
  }

  static const _onOptionKeys = {
    'do',
    'throttle',
    'debounce',
    'ripple',
    'event',
    'pressed_as',
  };

  /// Parses `_on` into event→action bindings and their optional dispatch timing.
  ///
  /// Each value is either an action name (`tap: submit`) or an options object
  /// (`scroll: { do: on_scroll, throttle: 16 }`) carrying at most one of
  /// `throttle` / `debounce` (milliseconds).
  static ({
    Map<String, String> actions,
    Map<String, EventTiming> timing,
    Map<String, Object?> payloads,
    bool tapFeedback,
    String? pressedAs,
  })
  _parseOn(UiNode node) {
    if (!node.reserved.containsKey('_on')) {
      return (
        actions: const {},
        timing: const {},
        payloads: const {},
        tapFeedback: true,
        pressedAs: null,
      );
    }
    final raw = node.reserved['_on'];
    if (raw is! Map) {
      throw InvalidTemplateException(
        node.path,
        'Prop "_on" must be a map of {event: action}.',
      );
    }
    final actions = <String, String>{};
    final timing = <String, EventTiming>{};
    final payloads = <String, Object?>{};
    var tapFeedback = true;
    String? pressedAs;
    for (final entry in raw.entries) {
      final event = '${entry.key}';
      if (!_knownEvents.contains(event)) {
        throw InvalidTemplateException(
          node.path,
          'unknown interaction event "$event" '
          '(supported: ${_knownEvents.join(", ")}).',
        );
      }
      final value = entry.value;
      if (value is String) {
        if (value.isEmpty) {
          throw InvalidTemplateException(
            node.path,
            'interaction "$event" must reference a non-empty action name.',
          );
        }
        actions[event] = value;
      } else if (value is Map) {
        actions[event] = _timingAction(node, event, value);
        final parsed = _parseTiming(node, event, value);
        if (parsed != null) timing[event] = parsed;
        if (value.containsKey('event')) {
          payloads[event] = ValueCompiler.value(
            value['event'],
            '${node.path}/_on/$event',
          );
        }
        if (_parseNoFeedback(node, event, value)) tapFeedback = false;
        if (event == 'tap') pressedAs = _parsePressedAs(node, value);
      } else {
        throw InvalidTemplateException(
          node.path,
          'interaction "$event" must be an action name or '
          '{ do, throttle | debounce }.',
        );
      }
    }
    return (
      actions: actions,
      timing: timing,
      payloads: payloads,
      tapFeedback: tapFeedback,
      pressedAs: pressedAs,
    );
  }

  /// Reads the optional `tap.pressed_as` name. An unbindable name is a typo
  /// and throws; a non-string or empty value drops the variable.
  static String? _parsePressedAs(UiNode node, Map value) {
    final name = value['pressed_as'];
    if (name is! String || name.isEmpty) return null;
    _requireBindableName(name, 'tap "pressed_as" name', node.path);
    return name;
  }

  /// Reads the optional `ripple` flag; only `tap` carries press feedback, so it is
  /// the sole event where `ripple: false` has an effect. Returns true when the
  /// feedback should be suppressed.
  static bool _parseNoFeedback(UiNode node, String event, Map value) {
    final ripple = value['ripple'];
    if (ripple == null) return false;
    if (ripple is! bool) {
      throw InvalidTemplateException(
        node.path,
        'interaction "$event": "ripple" must be a boolean.',
      );
    }
    return event == 'tap' && ripple == false;
  }

  static String _timingAction(UiNode node, String event, Map value) {
    final unknown = value.keys
        .map((key) => '$key')
        .where((key) => !_onOptionKeys.contains(key));
    if (unknown.isNotEmpty) {
      throw InvalidTemplateException(
        node.path,
        'interaction "$event" has unknown option(s) ${unknown.join(", ")} '
        '(allowed: ${_onOptionKeys.join(", ")}).',
      );
    }
    final action = value['do'];
    if (action is! String || action.isEmpty) {
      throw InvalidTemplateException(
        node.path,
        'interaction "$event" requires a non-empty "do" action name.',
      );
    }
    return action;
  }

  static EventTiming? _parseTiming(UiNode node, String event, Map value) {
    final throttle = value['throttle'];
    final debounce = value['debounce'];
    if (throttle != null && debounce != null) {
      throw InvalidTemplateException(
        node.path,
        'interaction "$event": use either "throttle" or "debounce", not both.',
      );
    }
    if (throttle != null) {
      return EventTiming.throttle(_millis(node, event, 'throttle', throttle));
    }
    if (debounce != null) {
      return EventTiming.debounce(_millis(node, event, 'debounce', debounce));
    }
    return null;
  }

  static Duration _millis(UiNode node, String event, String key, Object? raw) {
    final ms = raw is num ? raw : num.tryParse('$raw');
    if (ms == null || ms <= 0) {
      throw InvalidTemplateException(
        node.path,
        'interaction "$event": "$key" must be a positive number of milliseconds.',
      );
    }
    return Duration(microseconds: (ms * 1000).round());
  }

  /// Collects the `_motion` layers of [node].
  ///
  /// A malformed entry (neither a map nor a string, an empty name, a missing
  /// or empty `type`) is dropped and the other layers still run; an unknown
  /// motion name is a typo the validator rejects.
  static List<({String type, Map<String, Object?> params})> _parseMotion(
    UiNode node,
  ) {
    if (!node.reserved.containsKey('_motion')) return const [];
    final raw = node.reserved['_motion'];
    return [
      for (final entry in raw is List ? raw : [raw])
        ?_motionEntry(entry, node.path),
    ];
  }

  static ({String type, Map<String, Object?> params})? _motionEntry(
    Object? entry,
    String path,
  ) {
    if (entry is String) {
      return entry.isEmpty ? null : (type: entry, params: const {});
    }
    if (entry is! Map) return null;
    final type = entry['type'];
    if (type is! String || type.isEmpty) return null;
    return (
      type: type,
      params: ValueCompiler.map({
        for (final param in entry.entries)
          if (param.key != 'type') '${param.key}': param.value,
      }, path),
    );
  }

  static Map<String, Action> _compileActions(Object? raw, String path) {
    if (raw == null) return const {};
    if (raw is! Map) {
      throw InvalidTemplateException(path, 'Prop "_action" must be a map.');
    }
    final result = <String, Action>{};
    for (final entry in raw.entries) {
      final name = '${entry.key}';
      _rejectReserved(name, 'action name', path);
      // A command map or a list-of-batches flow — ActionCompiler validates it.
      final action = ActionCompiler.compile(entry.value, '$path/_action/$name');
      result[name] = Action(
        steps: action.steps,
        dedupe: action.dedupe,
        writes: _writesOf(action),
      );
    }
    return result;
  }

  /// The keys every `set` command in [action] commits, through all handler
  /// flows. Other drivers' writes cannot be read from their parameters.
  static Set<String> _writesOf(Action action) {
    final keys = <String>{};
    void flow(Flow? steps) {
      if (steps == null) return;
      for (final batch in steps) {
        for (final command in batch) {
          if (command.type == 'set') keys.addAll(command.params.keys);
          flow(command.then);
          command.onError?.values.forEach(flow);
          flow(command.dismiss);
          flow(command.always);
        }
      }
    }

    flow(action.steps);
    return keys;
  }

  static Directive _wrapIf(UiNode node, Directive child) {
    if (!node.reserved.containsKey('_if')) return child;
    final raw = node.reserved['_if'];
    if (raw is! String || raw.isEmpty) {
      throw InvalidTemplateException(
        node.path,
        'Prop "_if" must be a non-empty string.',
      );
    }
    return ConditionDirective(
      branches: [(predicate: _compileExpr(raw, node.path), body: child)],
      path: node.path,
    );
  }

  static Directive _wrapLoop(UiNode node, Directive child) {
    if (!node.reserved.containsKey('_loop')) return child;
    final raw = node.reserved['_loop'];
    if (raw is! Map) {
      throw InvalidTemplateException(node.path, 'Prop "_loop" must be a map.');
    }
    final source = raw['_in'];
    final compiledSource = source is String
        ? _compileExpr(source, node.path)
        : ValueCompiler.value(source, node.path);
    final as = raw['_as'] ?? 'item';
    final index = raw['_index'] ?? 'index';
    if (as is! String || index is! String) {
      throw InvalidTemplateException(
        node.path,
        'Props "_loop._as/_index" must be strings.',
      );
    }
    _requireBindableName(as, 'loop "_as" name', node.path);
    _requireBindableName(index, 'loop "_index" name', node.path);
    final key = raw['_key'];
    if (key is! String || key.isEmpty) {
      throw InvalidTemplateException(
        node.path,
        'Prop "_loop._key" is required and must be a non-empty string '
        '(for reconciliation/reorder stability).',
      );
    }
    final (wrap, wrapParams) = _parseWrap(node);
    final skeletonCount = raw['_skeleton'];
    if (skeletonCount != null && (skeletonCount is! int || skeletonCount < 1)) {
      throw InvalidTemplateException(
        node.path,
        'Prop "_loop._skeleton" must be a positive integer row count.',
      );
    }
    return LoopDirective(
      source: compiledSource,
      as: as,
      index: index,
      keyExpression: _compileExpr(key, node.path),
      child: child,
      path: node.path,
      wrap: wrap,
      wrapParams: wrapParams,
      skeletonCount: skeletonCount as int?,
    );
  }

  static (String, Map<String, Object?>) _parseWrap(UiNode node) {
    final raw = node.reserved['_loop'] as Map;
    final wrapRaw = raw['_wrap'] ?? 'column';
    final String wrap;
    final Map<String, Object?> params;
    if (wrapRaw is String) {
      wrap = wrapRaw;
      params = const {};
    } else if (wrapRaw is Map) {
      final type = wrapRaw['_type'];
      if (type is! String) {
        throw InvalidTemplateException(
          node.path,
          'Prop "_loop._wrap" map needs a string "_type".',
        );
      }
      wrap = type;
      params = ValueCompiler.map({
        for (final e in wrapRaw.entries)
          if (e.key != '_type') e.key as String: e.value,
      }, node.path);
    } else {
      throw InvalidTemplateException(
        node.path,
        'Prop "_loop._wrap" must be a string or a map.',
      );
    }
    return (wrap, params);
  }
}
