import 'package:flutter/widgets.dart';

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
