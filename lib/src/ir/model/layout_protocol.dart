import 'directive/_base.dart';

/// Identifies the render protocol produced by a widget or layout strategy.
///
/// Box and sliver children must match their parent's protocol. The template
/// validator tracks this value so incompatible placement fails at mount time
/// instead of triggering a Flutter render assertion outside node isolation.
enum LayoutProtocol { box, sliver }

/// The protocol a `_loop._wrap` strategy builds; it does not depend on the
/// widget registered under the same name.
LayoutProtocol loopWrapProduces(String wrap) =>
    wrap == 'sliver_list' || wrap == 'sliver_grid'
    ? LayoutProtocol.sliver
    : LayoutProtocol.box;

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

/// The child [node] hands to its parent, when its widget type passes its
/// single child through ([passesChild]): it builds no render object of its
/// own around that child's parent data.
Directive? passThrough(
  PlainDirective node,
  bool Function(String type) passesChild,
) => switch (node) {
  PlainDirective(children: [final child]) when passesChild(node.type) => child,
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
  bool Function(String type) passesChild,
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
};

ParentDataOutput _bodiesParentData(
  List<Directive> bodies,
  ParentDataOutput Function(String type) widget,
  bool Function(String type) passesChild,
) {
  var output = ParentDataOutput.none;
  for (final body in bodies) {
    final each = parentDataOf(body, widget, passesChild);
    if (each.index > output.index) output = each;
  }
  return output;
}
