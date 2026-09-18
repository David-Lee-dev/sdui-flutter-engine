import '../dependency/screen_loader.dart';

/// Mutable facade state, held outside [Sdui] so that resetting it stays out
/// of the app-facing API (`testing.dart` reaches it; the app barrel does not).
final class SduiState {
  const SduiState._();

  static ScreenLoader? screenLoader;

  static void reset() => screenLoader = null;
}
