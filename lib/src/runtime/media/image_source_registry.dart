import 'package:sdui_engine/src/contract/image_source.dart';

import '../../runtime/media/asset_image_source.dart';

/// Defines the process-wide policy for turning image requests into widgets.
///
/// The policy can be installed during startup and frozen so mounted templates
/// retain stable image-resolution semantics.
final class ImageSourceRegistry {
  const ImageSourceRegistry._();

  static ImageSource _current = const AssetImageSource();

  /// Returns the currently installed image policy.
  static ImageSource get current => _current;

  static bool _frozen = false;

  /// Installs [source], or throws [StateError] after [freeze] has been called.
  static void install(ImageSource source) {
    if (_frozen) throw StateError('ImageSource is frozen');
    _current = source;
  }

  /// Prevents subsequent image-policy installation.
  static void freeze() => _frozen = true;

  /// Restores the network fallback and permits installation again.
  static void reset() {
    _current = const AssetImageSource();
    _frozen = false;
  }
}
