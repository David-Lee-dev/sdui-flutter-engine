import 'telemetry.dart';

/// One screen visit's telemetry identity.
///
/// The page that owns a screen's lifecycle issues the visit: [begin] mints a
/// fresh `screen_view_id`, records `screen_view`, and the id is handed to the
/// mount (`EngineRunner.screenViewId`), which measures dwell/scroll and emits
/// the matching `screen_leave`. `SduiScreenPage` does this for the facade;
/// apps that skip the facade own it themselves:
///
/// ```dart
/// final visit = ScreenVisit.begin('home');
/// EngineRunner(screenId: 'home', screenViewId: visit.id, ...);
/// ```
final class ScreenVisit {
  const ScreenVisit._(this.id, this.screenId);

  /// The `screen_view_id` every event of this visit carries.
  final String id;

  final String screenId;

  /// Issues a fresh visit for [screenId] and records its `screen_view`.
  static ScreenVisit begin(String screenId) {
    final id = Telemetry.newId();
    Telemetry.record(
      'screen_view',
      screenId: screenId,
      screenViewId: id,
      properties: {'surface_type': 'screen'},
    );
    return ScreenVisit._(id, screenId);
  }
}
