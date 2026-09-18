import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../util/adaptive_radius.dart';

/// Rebuilds [builder] with a radius computed from its rendered size.
class AdaptiveRadiusBox extends StatefulWidget {
  /// Creates a size-measuring adaptive-radius wrapper.
  const AdaptiveRadiusBox({super.key, required this.builder});

  /// Builds the subtree using the current computed radius.
  final Widget Function(double radius) builder;

  @override
  State<AdaptiveRadiusBox> createState() => _AdaptiveRadiusBoxState();
}

class _AdaptiveRadiusBoxState extends State<AdaptiveRadiusBox> {
  double _radius = AdaptiveRadius.maxRadius;

  void _onSizeChanged(Size size) {
    final radius = AdaptiveRadius.compute(size);
    if (radius != _radius) setState(() => _radius = radius);
  }

  @override
  Widget build(BuildContext context) {
    return _SizeReporter(
      onSizeChanged: _onSizeChanged,
      child: widget.builder(_radius),
    );
  }
}

class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onSizeChanged, required super.child});

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SizeReporterRenderBox(onSizeChanged: onSizeChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    _SizeReporterRenderBox renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _SizeReporterRenderBox extends RenderProxyBox {
  _SizeReporterRenderBox({required this.onSizeChanged});

  ValueChanged<Size> onSizeChanged;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _lastSize) {
      _lastSize = size;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onSizeChanged(size);
      });
    }
  }
}
