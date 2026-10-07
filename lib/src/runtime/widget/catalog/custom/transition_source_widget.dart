import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../transition/transition_origin.dart';

final class TransitionSourceWidget {
  const TransitionSourceWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    final radius = props['radius'];
    return TransitionSource(
      radius: radius is num && radius.isFinite && radius >= 0
          ? radius.toDouble()
          : 0,
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}

/// Marks exactly the box captured by a container transform.
class TransitionSource extends StatefulWidget {
  const TransitionSource({super.key, this.radius = 0, required this.child});

  final double radius;
  final Widget child;

  @override
  State<TransitionSource> createState() => _TransitionSourceState();
}

class _TransitionSourceState extends State<TransitionSource> {
  final _boundary = GlobalKey();
  final _hidden = ValueNotifier(false);
  TransitionOrigin? _origin;
  TransitionOrigins? _registry;

  Rect? _rect() {
    if (!mounted) return null;
    final boundary = _boundary.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary ||
        !boundary.attached ||
        !boundary.hasSize ||
        boundary.size.isEmpty ||
        !boundary.size.isFinite) {
      return null;
    }
    return MatrixUtils.transformRect(
      boundary.getTransformTo(null),
      Offset.zero & boundary.size,
    );
  }

  void _arm(PointerDownEvent event) {
    final navigator = Navigator.maybeOf(context);
    final route = ModalRoute.of(context);
    final rect = _rect();
    if (navigator == null ||
        route?.isCurrent != true ||
        rect == null ||
        !TickerMode.of(context)) {
      return;
    }
    final registry = TransitionOrigins.of(navigator);
    _registry = registry;
    registry.pointerDown(event);
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    var painted = true;
    assert(() {
      painted = !boundary.debugNeedsPaint;
      return true;
    }());
    if (!painted) return;
    var platformView = false;
    void inspect(RenderObject object) {
      if (object is PlatformViewRenderBox ||
          object is RenderDarwinPlatformView) {
        platformView = true;
      }
      object.visitChildren(inspect);
    }

    inspect(boundary);
    if (platformView) return;
    final tags = <Object>{};
    void collect(Element element) {
      if (element.widget case Hero(:final tag)) tags.add(tag);
      element.visitChildren(collect);
    }

    _boundary.currentContext!.visitChildElements(collect);
    try {
      final image = boundary.toImageSync();
      _origin = TransitionOrigin(
        rect: rect,
        radius: widget.radius,
        image: image,
        currentRect: _rect,
        hidden: _hidden,
        tags: tags,
      );
      registry.arm(_origin!);
    } catch (_) {
      // Decorative capture failures leave navigation on its fade fallback.
    }
  }

  @override
  void dispose() {
    // A destination can retain the image after this source leaves the tree.
    final origin = _origin;
    if (origin != null) {
      _registry?.disarm(origin);
      origin.setHidden(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _arm,
    child: _SourceVisibility(
      hidden: _hidden,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        clipBehavior: widget.radius > 0 ? Clip.antiAlias : Clip.none,
        child: RepaintBoundary(key: _boundary, child: widget.child),
      ),
    ),
  );
}

/// Hiding changes painting only: the box and live descendants stay mounted,
/// and route animation callbacks never rebuild the source during navigation.
class _SourceVisibility extends SingleChildRenderObjectWidget {
  const _SourceVisibility({required this.hidden, required super.child});
  final ValueNotifier<bool> hidden;

  @override
  RenderObject createRenderObject(BuildContext context) => _SourcePaint(hidden);

  @override
  void updateRenderObject(BuildContext context, _SourcePaint renderObject) {
    renderObject.hidden = hidden;
  }
}

class _SourcePaint extends RenderProxyBox {
  _SourcePaint(this._hidden);
  ValueNotifier<bool> _hidden;
  set hidden(ValueNotifier<bool> value) {
    if (identical(value, _hidden)) return;
    if (attached) _hidden.removeListener(markNeedsPaint);
    _hidden = value;
    if (attached) _hidden.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _hidden.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _hidden.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_hidden.value) super.paint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      !_hidden.value && super.hitTest(result, position: position);
}
