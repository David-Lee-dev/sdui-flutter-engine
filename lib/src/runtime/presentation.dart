import 'package:flutter/widgets.dart';

/// Look-and-feel of the engine's built-in tap feedback (tint + press inset).
///
/// Defaults mirror the engine's tuned values; apps replace the whole style
/// via [SduiPresentation] — the renderer stays engine-owned, its constants
/// don't.
final class TapEffectStyle {
  const TapEffectStyle({
    this.tint = const Color(0xFFEDEDED),
    this.tintOpacity = 0.10,
    this.inset = 3.5,
    this.inDuration = const Duration(milliseconds: 110),
    this.outDuration = const Duration(milliseconds: 240),
  });

  /// Overlay color blended over the pressed subtree.
  final Color tint;

  final double tintOpacity;

  /// Press "sink" in logical pixels along the longest side.
  final double inset;

  final Duration inDuration;
  final Duration outDuration;
}

/// Chrome of the modal frame the `modal` command presents.
final class ModalStyle {
  const ModalStyle({
    this.barrierColor = const Color(0x8A000000),
    this.borderRadius = 16,
    this.sheetMaxHeightFactor = 0.8,
    this.dialogMaxHeightFactor = 0.9,
    this.dialogWidthFactor = 0.9,
  });

  final Color barrierColor;

  /// Corner radius of the body surface (sheet: top corners, dialog: all).
  final double borderRadius;

  /// Height budget as a fraction of what the keyboard leaves visible.
  final double sheetMaxHeightFactor;
  final double dialogMaxHeightFactor;

  final double dialogWidthFactor;
}

/// Presents a template `toast` command — the app's chance to replace the
/// default SnackBar with its own component. [variant] is the command's
/// normalized variant string (`info`/`warn`/`error`/...), or `null`.
typedef SduiToastPresenter =
    void Function(BuildContext context, String message, String? variant);

/// App-owned look-and-feel for the engine's built-in presentation surfaces.
///
/// The engine owns the *behavior* (when feedback plays, how a modal mounts);
/// the app owns the *look* — inject a presentation at boot to rebrand both
/// without forking a renderer:
///
/// ```dart
/// Sdui.initialize(
///   presentation: const SduiPresentation(
///     tapEffect: TapEffectStyle(tintOpacity: 0.2),
///     modal: ModalStyle(borderRadius: 24),
///   ),
/// );
/// ```
final class SduiPresentation {
  const SduiPresentation({
    this.tapEffect = const TapEffectStyle(),
    this.modal = const ModalStyle(),
  });

  final TapEffectStyle tapEffect;
  final ModalStyle modal;
}

/// Process-wide holder the runtime reads; installed once at boot.
abstract final class EnginePresentation {
  static SduiPresentation value = const SduiPresentation();

  /// Restores defaults for test isolation.
  static void reset() => value = const SduiPresentation();
}
