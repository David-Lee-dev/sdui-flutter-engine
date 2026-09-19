import 'package:flutter/widgets.dart';

/// Typography defaults for template text.
///
/// Templates always win — these fill only what a template's `style` omits,
/// so a server-driven screen keeps full authority while the app supplies its
/// brand font and baseline once.
final class SduiTypography {
  const SduiTypography({this.fontFamily, this.baseStyle});

  /// Default font family for text the template does not give one.
  final String? fontFamily;

  /// Base text style merged *under* every template style (template values
  /// override field by field).
  final TextStyle? baseStyle;
}
