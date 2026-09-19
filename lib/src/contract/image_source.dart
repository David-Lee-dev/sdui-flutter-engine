import 'package:flutter/widgets.dart';

/// Resolves an image request into a renderable image. The engine's image widget
/// owns the loading skeleton, cross-fade, and error/loading slots — the source
/// only supplies the built image, synchronously (bundled) or after async work
/// (download).
abstract class ImageSource {
  ImageResult resolve(ImageRequest request);
}

/// Outcome of [ImageSource.resolve].
sealed class ImageResult {
  const ImageResult();
}

/// Nothing to render (empty/invalid src).
final class NoImage extends ImageResult {
  const NoImage();
}

/// The image is available now (e.g. a bundled asset) — render immediately.
final class ReadyImage extends ImageResult {
  const ReadyImage(this.image);

  final Widget image;
}

/// The image needs async work (e.g. a download) before it renders. Resolves to
/// the built image widget, or null on failure.
final class PendingImage extends ImageResult {
  const PendingImage(this.image);

  final Future<Widget?> image;
}

/// Carries resolved image props to an [ImageSource].
final class ImageRequest {
  const ImageRequest({
    required this.src,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.alignment,
    this.colorBlendMode,
    this.repeat,
    this.semanticLabel,
    this.cacheWidth,
    this.cacheHeight,
    this.loading,
    this.error,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final AlignmentGeometry? alignment;
  final BlendMode? colorBlendMode;
  final ImageRepeat? repeat;
  final String? semanticLabel;
  final int? cacheWidth;
  final int? cacheHeight;

  /// Widget shown while a self-managing source (e.g. network) loads. Deferred
  /// sources (see [PendingImage]) leave loading presentation to the widget.
  final Widget? loading;

  /// Widget shown when the image fails.
  final Widget? error;
}
