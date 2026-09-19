import '../contract/screen_loader.dart';
import '../presentation/presentation.dart';

/// Mutable facade state, held outside [Sdui] so that resetting it stays out
/// of the app-facing API (`testing.dart` reaches it; the app barrel does not).
final class SduiState {
  const SduiState._();

  static ScreenLoader? screenLoader;

  /// App-owned toast presentation; `null` falls back to a SnackBar.
  static SduiToastPresenter? toastPresenter;

  static void reset() {
    screenLoader = null;
    toastPresenter = null;
  }
}
