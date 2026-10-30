import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../log/engine_log.dart';
import '../../../util/props_resolver.dart';
import '../../contract/child_builder.dart';

/// `layout_builder` — Builds its child with the space its parent offers.
///
/// The child is built lazily with `max_width` and `max_height`: the parent's
/// maximum constraints in template units (logical pixels divided by the
/// `EngineMetrics` scale), or `null` on an unbounded axis. Declare them with
/// `_provides: [max_width, max_height]`.
///
/// ```yaml
/// _type: layout_builder
/// _provides: [max_width, max_height]
/// _child: { _type: text, value: '${max_width > 400 ? "wide" : "narrow"}' }
/// ```
///
/// No props.
///
/// The child cannot be measured by intrinsic size. Inside `intrinsic_width`
/// or `intrinsic_height` the template fails to compile; under an app-side
/// parent that asks for intrinsic sizes the node answers `0` and logs once.
///
/// Child: lazily built `_child`.
final class LayoutBuilderWidget {
  const LayoutBuilderWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    int childCount,
    ChildBuilder buildChild,
  ) => _NoIntrinsics(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final scale = PropsResolver.scaleOf(context);
        final child = buildChild(
          0,
          vars: {
            'max_width': constraints.hasBoundedWidth
                ? constraints.maxWidth / scale
                : null,
            'max_height': constraints.hasBoundedHeight
                ? constraints.maxHeight / scale
                : null,
          },
        );
        return child ?? const SizedBox.shrink();
      },
    ),
  );
}

/// Answers intrinsic and dry-layout queries with zero, which
/// [LayoutBuilder] cannot answer at all.
class _NoIntrinsics extends SingleChildRenderObjectWidget {
  const _NoIntrinsics({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderNoIntrinsics();
}

class _RenderNoIntrinsics extends RenderProxyBox {
  bool _warned = false;

  double _zero() {
    if (!_warned) {
      _warned = true;
      EngineLog.warn(
        'layout_builder: a parent asked for its intrinsic size, which it '
        'cannot measure; it answers 0. Keep it out of intrinsic_width, '
        'intrinsic_height and other intrinsic-sizing parents.',
        tag: 'widget',
      );
    }
    return 0;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _zero();
  @override
  double computeMaxIntrinsicWidth(double height) => _zero();
  @override
  double computeMinIntrinsicHeight(double width) => _zero();
  @override
  double computeMaxIntrinsicHeight(double width) => _zero();

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    _zero();
    return constraints.smallest;
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => null;
}
