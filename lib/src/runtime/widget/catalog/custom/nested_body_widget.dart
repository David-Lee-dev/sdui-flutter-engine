import 'package:flutter/widgets.dart';

/// `nested_body` — Wraps the first child in a marker recognized as a nested-scroll body.
///
/// ```yaml
/// _type: nested_body
/// # Internal helper; no `_type` is registered in WidgetFactory.
/// ```
///
/// Props:
/// - None.
///
/// Child: `_child` (internal helper only).
final class NestedBodyWidget {
  const NestedBodyWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    List<Widget> children,
  ) {
    return NestedBodyMarker(
      child: children.isEmpty ? const SizedBox.shrink() : children.first,
    );
  }
}

/// Marks [child] as the body of a nested scrolling composition.
class NestedBodyMarker extends StatelessWidget {
  const NestedBodyMarker({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
