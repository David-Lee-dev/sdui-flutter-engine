import 'package:sdui_engine/src/contract/tap_feedback.dart';
import 'package:sdui_engine/src/impl/ink_tap_feedback.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';

/// Process-wide presentation holder the runtime reads; installed once at boot.
abstract final class EnginePresentation {
  static SduiPresentation value = const SduiPresentation();

  /// The active tap feedback: the injected one, or the package default.
  static TapFeedback get tapFeedback =>
      value.tapFeedback ?? const InkTapFeedback();

  /// Restores defaults for test isolation.
  static void reset() => value = const SduiPresentation();
}
