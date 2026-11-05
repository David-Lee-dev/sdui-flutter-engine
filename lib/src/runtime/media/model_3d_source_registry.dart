import 'package:sdui_engine/src/contract/model_3d_source.dart';

/// Defines the process-wide policy for creating model controllers.
final class Model3dSourceRegistry {
  const Model3dSourceRegistry._();

  static Model3dSource? _current;

  /// Returns the installed model policy, or null when the app installed none
  /// (the `model_3d` widget then renders its poster only).
  static Model3dSource? get current => _current;

  static bool _frozen = false;

  /// Installs [source], or throws [StateError] after [freeze] has been called.
  static void install(Model3dSource source) {
    if (_frozen) throw StateError('Model3dSource is frozen');
    _current = source;
  }

  /// Prevents subsequent model-policy installation.
  static void freeze() => _frozen = true;

  /// Removes the installed policy and permits installation again.
  static void reset() {
    _current = null;
    _frozen = false;
  }
}
