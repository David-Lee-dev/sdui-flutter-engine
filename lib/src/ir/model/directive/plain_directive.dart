part of '_base.dart';

/// Renders a terminal widget of [type] with its compiled descendants.
///
/// Expressions in [props] are compiled before this stage, so runtime resolution
/// does not reparse strings. Compiler-owned markers have already been removed.
/// [on] maps interaction events to named actions in the surrounding scope.
final class PlainDirective extends Directive {
  const PlainDirective({
    required this.type,
    required this.props,
    required this.children,
    required this.roots,
    this.on = const {},
    this.timing = const {},
    this.onEvent = const {},
    this.tapFeedback = true,
    this.motions = const [],
    this.provides = const {},
    this.slots = const {},
    this.key,
    this.path = '',
  });

  /// The catalog type used to build the widget.
  final String type;

  /// The compiled widget properties with engine markers removed.
  final Map<String, Object?> props;

  final List<Directive> children;

  /// The compiled named children, mutually exclusive with [children].
  final Map<String, Directive> slots;

  /// All binding roots used for both reactivity and declaration validation.
  ///
  /// This includes properties and motion parameters so changes re-resolve every
  /// compiled layer and undeclared dependencies fail consistently.
  final Set<String> roots;

  /// Maps `_on` event names to actions resolved by the action host.
  final Map<String, String> on;

  /// Per-event dispatch timing (throttle / debounce) declared in `_on` options.
  final Map<String, EventTiming> timing;

  /// Per-event payloads declared as `_on: { tap: { do, event: <expr> } }`.
  ///
  /// Resolved in the node's own environment, so a loop item can hand its value
  /// to an action declared above it — actions run in the scope that declares
  /// them and cannot see the item frame otherwise.
  final Map<String, Object?> onEvent;

  /// Whether a `tap` plays the press feedback. `_on: { tap: { do, ripple: false } }`
  /// suppresses it (default true).
  ///
  /// The template key stays `ripple` for compatibility with shipped screens; what
  /// it switches is the press tint and inset, not an ink ripple.
  final bool tapFeedback;

  /// The ordered `_motion` layers and their compiled parameters.
  ///
  /// Each layer retains an independent wrapper and controller; later entries
  /// wrap earlier entries.
  final List<({String type, Map<String, Object?> params})> motions;

  /// Names injected into the child scope by this node.
  ///
  /// Validation treats these names as child declarations but not parent state.
  final Set<String> provides;

  /// The stable reconciliation key supplied by `_key`, if any.
  final String? key;

  /// The source node's tree path for diagnostics.
  final String path;
}
