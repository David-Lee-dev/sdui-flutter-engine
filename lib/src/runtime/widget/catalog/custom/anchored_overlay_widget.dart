import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../engine_registries.dart';
import '../../../motion/_base.dart';
import '../../../motion/atom/fade.dart';
import '../../../util/props_resolver.dart';
import '../../../wrapper/motion.dart';
import '../../../wrapper/presence.dart';
import '../../contract/action_sink.dart';

/// `anchored_overlay` — Dims the app in the nearest Overlay and lays its children over the dim.
///
/// The node itself takes no space. While it is in the tree its layer sits in
/// the nearest [Overlay] (a route's navigator), above everything that route
/// shows, a bar drawn beside the screen included. The layer is the dim,
/// which takes every tap outside the children and blocks the page beneath,
/// and then the children in order. Children read the screen's state and
/// dispatch its actions like any other node; `anchored` children are placed
/// at the measured rect of the `anchor` named by `anchor`.
///
/// Show it with `_if` and `_presence: true`: the layer then stays until every
/// `on: exit|both` motion inside it has finished, the dim's included.
/// Without presence it goes at once.
///
/// ```yaml
/// _type: anchored_overlay
/// _if: ${open}
/// _presence: true
/// anchor: badge
/// on_dismiss: close
/// _children:
///   - _type: anchored
///     placement: below
///     _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `anchor` (`text`, default `null`) — id of the `anchor` the `anchored` children are placed against.
/// - `on_dismiss` (`text`, default `null`) — action dispatched by a tap on the dim or a system back.
/// - `barrier_color` (`color`, default `#8A000000`) — color of the dim.
/// - `barrier_duration` (`number`, default `200`) — milliseconds the dim fades in and out.
/// - `barrier_exit_delay` (`number`, default `0`) — milliseconds the dim waits before it fades out.
///
/// Children: `_children`.
final class AnchoredOverlayWidget {
  const AnchoredOverlayWidget._();

  static const _barrier = Color(0x8A000000);

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
    ActionSink? dispatch,
  ) {
    final id = PropsResolver.text(props['anchor']);
    final registry = EngineRegistryScope.of(context)?.anchors;
    return _AnchoredOverlayHost(
      anchor: id == null || registry == null
          ? null
          : (registry: registry, id: id),
      onDismiss: PropsResolver.text(props['on_dismiss']),
      dispatch: dispatch,
      barrierColor: PropsResolver.color(props['barrier_color']) ?? _barrier,
      barrierMotion: MotionParams({
        'duration': props['barrier_duration'] ?? 200,
        'exit_delay': props['barrier_exit_delay'] ?? 0,
      }),
      children: children,
    );
  }
}

/// The anchor `anchored` children are placed against.
typedef _AnchorRef = ({AnchorRegistry registry, String id});

class _AnchoredOverlayHost extends StatefulWidget {
  const _AnchoredOverlayHost({
    required this.anchor,
    required this.onDismiss,
    required this.dispatch,
    required this.barrierColor,
    required this.barrierMotion,
    required this.children,
  });

  final _AnchorRef? anchor;
  final String? onDismiss;
  final ActionSink? dispatch;
  final Color barrierColor;
  final MotionParams barrierMotion;
  final List<Widget> children;

  @override
  State<_AnchoredOverlayHost> createState() => _AnchoredOverlayHostState();
}

class _AnchoredOverlayHostState extends State<_AnchoredOverlayHost> {
  final OverlayPortalController _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.onDismiss;
    final dispatch = widget.dispatch;
    // A leaving layer no longer dismisses: the action already ran, and
    // running it again could open the layer back.
    final VoidCallback? dismiss =
        action == null || dispatch == null || PresenceScope.exitingOf(context)
        ? null
        : () => dispatch.handle(action);
    return PopScope(
      canPop: dismiss == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) dismiss?.call();
      },
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => _AnchorSource(
          anchor: widget.anchor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dismiss,
                child: MotionWrapper(
                  motion: const FadeMotion(),
                  params: widget.barrierMotion,
                  phase: MotionPhase.both,
                  child: ColoredBox(color: widget.barrierColor),
                ),
              ),
              ...widget.children,
            ],
          ),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

/// Hands the overlay's anchor to the `anchored` children in its layer.
class _AnchorSource extends InheritedWidget {
  const _AnchorSource({required this.anchor, required super.child});

  final _AnchorRef? anchor;

  static _AnchorSource? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnchorSource>();

  @override
  bool updateShouldNotify(_AnchorSource oldWidget) =>
      anchor != oldWidget.anchor;
}

/// `anchored` — Places its child against the anchor of the `anchored_overlay` it is in.
///
/// The child keeps its own size and sits at the anchor's current on-screen
/// rect: `over` it, or `above`, `below`, before (`start`) or after (`end`)
/// it, `gap` away. `align` lines the child up with the anchor across that
/// side (both axes for `over`). While the anchor is not mounted the child is
/// not drawn, hit or announced. Outside an `anchored_overlay` it draws nothing.
///
/// Put `_motion` on the child: the node itself fills the layer.
///
/// ```yaml
/// _type: anchored
/// placement: below
/// align: start
/// gap: 8
/// _child: { _type: text, value: hi }
/// ```
///
/// Props:
/// - `placement` (`text`, default `'over'`) — side of the anchor the child sits on. Values: over | above | below | start | end.
/// - `align` (`text`, default `'center'`) — how the child lines up with the anchor across that side. Values: start | center | end.
/// - `gap` (`offset`, default `0.0`) — distance between the anchor and the child; unused for `over`.
///
/// Child: `_child`.
final class AnchoredWidget {
  const AnchoredWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final placement = switch (props['placement']) {
      'above' => _Placement.above,
      'below' => _Placement.below,
      'start' => _Placement.start,
      'end' => _Placement.end,
      _ => _Placement.over,
    };
    final align = switch (props['align']) {
      'start' => 0.0,
      'end' => 1.0,
      _ => 0.5,
    };
    final gap = PropsResolver.offset(context, props['gap']) ?? 0.0;
    final source = _AnchorSource.maybeOf(context);
    if (source == null) return const SizedBox.shrink();
    return _Anchored(
      anchor: source.anchor,
      placement: placement,
      align: align,
      gap: gap,
      direction: Directionality.maybeOf(context) ?? TextDirection.ltr,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}

enum _Placement { over, above, below, start, end }

class _Anchored extends SingleChildRenderObjectWidget {
  const _Anchored({
    required this.anchor,
    required this.placement,
    required this.align,
    required this.gap,
    required this.direction,
    required super.child,
  });

  final _AnchorRef? anchor;
  final _Placement placement;
  final double align;
  final double gap;
  final TextDirection direction;

  @override
  _RenderAnchored createRenderObject(BuildContext context) => _RenderAnchored(
    anchor: anchor,
    placement: placement,
    align: align,
    gap: gap,
    direction: direction,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderAnchored renderObject) {
    renderObject
      ..anchor = anchor
      ..placement = placement
      ..align = align
      ..gap = gap
      ..direction = direction;
  }
}

/// Fills its parent and paints its child at the anchor's rect.
///
/// The anchor lies in another subtree whose layout this one cannot depend
/// on, so the child is placed when painting, after every layout of the
/// frame. After each frame the anchor is measured again, and a move (a
/// scroll beneath the layer) repaints at the new rect.
class _RenderAnchored extends RenderShiftedBox {
  _RenderAnchored({
    required _AnchorRef? anchor,
    required _Placement placement,
    required double align,
    required double gap,
    required TextDirection direction,
  }) : _anchor = anchor,
       _placement = placement,
       _align = align,
       _gap = gap,
       _direction = direction,
       super(null);

  _AnchorRef? _anchor;
  set anchor(_AnchorRef? value) {
    if (value == _anchor) return;
    _anchor = value;
    markNeedsPaint();
  }

  _Placement _placement;
  set placement(_Placement value) {
    if (value == _placement) return;
    _placement = value;
    markNeedsPaint();
  }

  double _align;
  set align(double value) {
    if (value == _align) return;
    _align = value;
    markNeedsPaint();
  }

  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsPaint();
  }

  TextDirection _direction;
  set direction(TextDirection value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsPaint();
  }

  /// The anchor rect the child was last painted against, `null` when the
  /// anchor was not mounted.
  Rect? _painted;

  bool _watching = false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    size = constraints.biggest.isFinite
        ? constraints.biggest
        : constraints.smallest;
    child?.layout(BoxConstraints.loose(size), parentUsesSize: true);
  }

  /// The anchor's rect in this box, or `null` while it is not laid out.
  Rect? _anchorRect() {
    final anchor = _anchor;
    final box = anchor?.registry
        .keyFor(anchor.id)
        ?.currentContext
        ?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize || !attached) {
      return null;
    }
    final global = MatrixUtils.transformRect(
      box.getTransformTo(null),
      Offset.zero & box.size,
    );
    return global.shift(-localToGlobal(Offset.zero));
  }

  /// Where a child of size [child] goes against [anchor].
  Offset _place(Rect anchor, Size child) {
    final rtl = _direction == TextDirection.rtl;
    final x =
        anchor.left +
        (anchor.width - child.width) * (rtl ? 1 - _align : _align);
    final y = anchor.top + (anchor.height - child.height) * _align;
    final before = anchor.left - _gap - child.width;
    final after = anchor.right + _gap;
    return switch (_placement) {
      _Placement.over => Offset(x, y),
      _Placement.above => Offset(x, anchor.top - _gap - child.height),
      _Placement.below => Offset(x, anchor.bottom + _gap),
      _Placement.start => Offset(rtl ? after : before, y),
      _Placement.end => Offset(rtl ? before : after, y),
    };
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final shown = _painted != null;
    final rect = _painted = _anchorRect();
    if (shown != (rect != null)) markNeedsSemanticsUpdate();
    _watch();
    final child = this.child;
    if (child == null || rect == null) return;
    // The child's semantics rect follows its offset, which only paint moves.
    final placed = _place(rect, child.size);
    final parentData = child.parentData! as BoxParentData;
    if (parentData.offset != placed) {
      parentData.offset = placed;
      markNeedsSemanticsUpdate();
    }
    context.paintChild(child, offset + placed);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      _painted != null && super.hitTestChildren(result, position: position);

  /// A child not drawn is not announced either.
  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_painted != null) super.visitChildrenForSemantics(visitor);
  }

  /// Measures the anchor after the next frame, repainting when it moved.
  /// A post-frame callback schedules no frame of its own, so a still layer
  /// costs nothing between frames.
  void _watch() {
    if (_watching) return;
    _watching = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _watching = false;
      if (!attached) return;
      if (_anchorRect() != _painted) {
        markNeedsPaint();
      } else {
        _watch();
      }
    });
  }
}
