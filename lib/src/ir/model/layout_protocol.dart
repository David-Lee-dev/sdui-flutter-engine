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
/// given by [widget]. A cond or switch builds what its bodies build, its
/// fallback included; one with no body builds nothing, read as a box.
LayoutProtocol producesOf(
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

LayoutProtocol _bodiesProduce(
  List<Directive> bodies,
  LayoutProtocol Function(String type) widget,
) => bodies.isEmpty ? LayoutProtocol.box : producesOf(bodies.first, widget);
