import 'package:flutter/widgets.dart';

/// [optional seam] Visual feedback for tappable template nodes.
///
/// The engine owns *when* feedback applies (which nodes are tappable, the
/// template's `feedback: false` opt-out, semantics); an implementation owns
/// *how it looks*. The package default is [InkTapFeedback] (Flutter's stock
/// ripple); apps replace it via `SduiPresentation(tapFeedback: ...)` — the
/// starter kit ships an advanced tint + press-inset implementation.
abstract class TapFeedback {
  const TapFeedback();

  /// Wraps a tappable subtree. The implementation must invoke the callbacks
  /// (they carry the template's actions) and render its press feedback.
  Widget wrap(
    BuildContext context,
    Widget child, {
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
  });
}
