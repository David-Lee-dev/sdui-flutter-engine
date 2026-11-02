import 'package:sdui_engine/src/contract/model_source.dart';

/// Defines the process-wide policy for creating model controllers.
final class ModelSourceRegistry {
  const ModelSourceRegistry._();

  static ModelSource? _current;

  /// Returns the installed model policy, or null when the app installed none
  /// (the `model` widget then renders its poster only).
  static ModelSource? get current => _current;

  static bool _frozen = false;

  /// Installs [source], or throws [StateError] after [freeze] has been called.
  static void install(ModelSource source) {
    if (_frozen) throw StateError('ModelSource is frozen');
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
