import 'package:flutter/material.dart';

import '../contract/tap_feedback.dart';

/// Package default [TapFeedback]: Flutter's stock ink ripple.
///
/// Wrapped in a transparent [Material] so it works in template trees that
/// carry no Material ancestor of their own.
final class InkTapFeedback extends TapFeedback {
  const InkTapFeedback();

  @override
  Widget wrap(
    BuildContext context,
    Widget child, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
  }) => Material(
    type: MaterialType.transparency,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: child,
    ),
  );
}
