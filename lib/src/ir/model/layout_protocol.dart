import 'directive/_base.dart';

/// Identifies the render protocol produced by a widget or layout strategy.
///
/// Box and sliver children must match their parent's protocol. The template
/// validator tracks this value so incompatible placement fails at mount time
/// instead of triggering a Flutter render assertion outside node isolation.
enum LayoutProtocol { box, sliver }

/// What one `_loop._wrap` strategy is: the protocol it builds, the
/// registered widget it lays its items in ([widget], whose accepted parent
/// data the items get; `null` when it lays them in a widget of its own,
/// which takes none), whether it builds items lazily or as slivers ([lazy]),
/// and whether it takes input or runs actions ([interactive]).
typedef LoopWrap = ({
  LayoutProtocol produces,
  String? widget,
  bool lazy,
  bool interactive,
});

/// Every `_loop._wrap` strategy the engine has, by name. The validator's
/// known names, [loopWrapProduces], [loopWrapWidget] and the skeleton's
/// lazy and interactive wraps all read this; the runtime's dispatch handles
/// exactly these names (`loop_wrap_table_test.dart`).
const Map<String, LoopWrap> loopWraps = {
  'column': (
    produces: LayoutProtocol.box,
    widget: 'column',
    lazy: false,
    interactive: false,
  ),
  'row': (
    produces: LayoutProtocol.box,
    widget: 'row',
    lazy: false,
    interactive: false,
  ),
  'wrap': (
    produces: LayoutProtocol.box,
    widget: 'wrap',
    lazy: false,
    interactive: false,
  ),
  'serpentine': (
    produces: LayoutProtocol.box,
    widget: 'serpentine',
    lazy: false,
    interactive: false,
  ),
  'serpentine_row': (
    produces: LayoutProtocol.box,
    widget: 'serpentine_row',
    lazy: false,
    interactive: false,
  ),
  'spin_grid': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: false,
    interactive: true,
  ),
  'auto_scroll': (
    produces: LayoutProtocol.box,
    widget: 'auto_scroll',
    lazy: false,
    interactive: true,
  ),
  'swipe': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: false,
    interactive: true,
  ),
  'list': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: true,
    interactive: false,
  ),
  'sliver_list': (
    produces: LayoutProtocol.sliver,
    widget: null,
    lazy: true,
    interactive: false,
  ),
  'grid': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: true,
    interactive: false,
  ),
  'sliver_grid': (
    produces: LayoutProtocol.sliver,
    widget: null,
    lazy: true,
    interactive: false,
  ),
  'reorderable': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: false,
    interactive: true,
  ),
  'dismissible': (
    produces: LayoutProtocol.box,
    widget: null,
    lazy: false,
    interactive: true,
  ),
};

/// The protocol a `_loop._wrap` strategy builds; it does not depend on the
/// widget registered under the same name.
LayoutProtocol loopWrapProduces(String wrap) =>
    loopWraps[wrap]?.produces ?? LayoutProtocol.box;

/// The protocol [directive] builds, with each widget type's own protocol
/// given by [widget]. A cond or switch builds what every body builds, its
/// fallback included, and `null` when they differ; one with no body builds
/// nothing, read as a box.
LayoutProtocol? producesOf(
  Directive directive,
  LayoutProtocol Function(String type) widget,
) => switch (directive) {
  PlainDirective node => widget(node.type),
  LoopDirective loop => loopWrapProduces(loop.wrap),
  ConditionDirective cond => _bodiesProduce([
    for (final branch in cond.branches) branch.body,
    ?cond.fallback,
  ], widget),
  SwitchDirective sw => _bodiesProduce([
    for (final branch in sw.cases) branch.branch,
    ?sw.fallback,
  ], widget),
  MorphDirective morph => producesOf(morph.child, widget),
  ScopeDirective scope => producesOf(scope.child, widget),
  SkeletonDirective skeleton => producesOf(skeleton.child, widget),
  MergedBonesDirective() => LayoutProtocol.box,
};

LayoutProtocol? _bodiesProduce(
  List<Directive> bodies,
  LayoutProtocol Function(String type) widget,
) {
  if (bodies.isEmpty) return LayoutProtocol.box;
  final first = producesOf(bodies.first, widget);
  for (final body in bodies.skip(1)) {
    if (producesOf(body, widget) != first) return null;
  }
  return first;
}

/// The parent data a widget's output carries, and the parent data a parent
/// takes on its children: a child carrying [flex] belongs directly in a
/// flex (`Expanded`, `Flexible`, `Spacer`), one carrying [stack] directly
/// in a stack (`Positioned`).
enum ParentDataKind { none, flex, stack }

/// The registered widget a `_loop._wrap` strategy lays its items in, whose
/// accepted parent data the items get; `null` for a strategy that lays them
/// in a widget of its own, which takes none.
String? loopWrapWidget(String wrap) => loopWraps[wrap]?.widget;

/// What parent data a widget or directive builds, for the wrappers the
/// engine puts around it.
enum ParentDataOutput {
  /// Not parent data: a wrapper can go around it.
  none,

  /// Parent data whose child the engine wraps instead (a built-in
  /// `expanded`, `positioned`, ...).
  decoratable,

  /// Parent data the engine cannot see into: no wrapper can go around or
  /// inside it.
  opaque,
}

/// Decides from a node's compiled props whether its widget passes its single
/// child through: it builds no render object of its own around that child's
/// parent data.
typedef PassesChild = bool Function(Map<String, Object?> props);

/// The built-in `container` props each of which makes Flutter's `Container`
/// build a widget between itself and its child (`Align`, `Padding`,
/// `ColoredBox`, `DecoratedBox`, `ConstrainedBox`, `Transform`, ...).
/// `container_widget_test.dart` checks this against every prop the builder
/// reads.
const Set<String> containerWrapperProps = {
  'decoration',
  'width',
  'height',
  'padding',
  'margin',
  'alignment',
  'constraints',
  'color',
  'foreground_decoration',
  'transform',
};

/// The built-in `container`: Flutter's `Container` returns its child itself
/// when none of [containerWrapperProps] is set and it does not clip. A bound
/// value may resolve to anything, so only an absent or literal `null` prop
/// (and an absent or literal `none` clip) passes the child through.
bool containerPassesChild(Map<String, Object?> props) =>
    containerWrapperProps.every((prop) => props[prop] == null) &&
    (props['clip_behavior'] ?? 'none') == 'none';

/// The built-in `visibility`: Flutter's `Visibility` returns its child itself
/// unless it maintains state or size. A bound flag may turn on, so only an
/// absent or literal `false` one passes the child through.
bool visibilityPassesChild(Map<String, Object?> props) =>
    _off(props['maintain_state']) && _off(props['maintain_size']);

bool _off(Object? flag) => flag == null || flag == false;

/// The child [node] hands to its parent, when its widget type passes its
/// single child through by [passesChild] (`null`: never).
Directive? passThrough(
  PlainDirective node,
  PassesChild? Function(String type) passesChild,
) => switch (node) {
  PlainDirective(children: [final child])
      when passesChild(node.type)?.call(node.props) ?? false =>
    child,
  _ => null,
};

/// The parent data [directive] builds, with each widget type's own
/// declaration given by [widget] and whether it passes its child through by
/// [passesChild]. A pass-through node around parent data hides it; a cond
/// or switch builds the most hidden of its bodies'; a morph, scope or
/// skeleton builds its child's; a loop builds none.
ParentDataOutput parentDataOf(
  Directive directive,
  ParentDataOutput Function(String type) widget,
  PassesChild? Function(String type) passesChild,
) => switch (directive) {
  PlainDirective node => switch (passThrough(node, passesChild)) {
    final child?
        when parentDataOf(child, widget, passesChild) !=
            ParentDataOutput.none =>
      ParentDataOutput.opaque,
    _ => widget(node.type),
  },
  ConditionDirective cond => _bodiesParentData(
    [for (final branch in cond.branches) branch.body, ?cond.fallback],
    widget,
    passesChild,
  ),
  SwitchDirective sw => _bodiesParentData(
    [for (final branch in sw.cases) branch.branch, ?sw.fallback],
    widget,
    passesChild,
  ),
  MorphDirective morph => parentDataOf(morph.child, widget, passesChild),
  ScopeDirective scope => parentDataOf(scope.child, widget, passesChild),
  SkeletonDirective skeleton => parentDataOf(
    skeleton.child,
    widget,
    passesChild,
  ),
  LoopDirective() => ParentDataOutput.none,
  MergedBonesDirective() => ParentDataOutput.none,
};

ParentDataOutput _bodiesParentData(
  List<Directive> bodies,
  ParentDataOutput Function(String type) widget,
  PassesChild? Function(String type) passesChild,
) {
  var output = ParentDataOutput.none;
  for (final body in bodies) {
    final each = parentDataOf(body, widget, passesChild);
    if (each.index > output.index) output = each;
  }
  return output;
}
