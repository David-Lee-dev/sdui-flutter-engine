import 'package:flutter/widgets.dart';

import '../../dependency/image_source.dart';

/// Default [ImageSource] — bundled asset images, the bare minimum.
///
/// Template `src` values are treated as asset paths packaged with the app
/// (declared under `flutter/assets` in pubspec). No network is involved: a
/// network-backed source needs a base URL and belongs to the app, exactly
/// like the api client and screen loader — see the starter kit's
/// `NetworkImageSource` for the reference implementation.
class AssetImageSource implements ImageSource {
  const AssetImageSource();

  @override
  ImageResult resolve(ImageRequest r) {
    final src = r.src;
    if (src.isEmpty) return const NoImage();

    return ReadyImage(
      Image.asset(
        src,
        width: r.width,
        height: r.height,
        fit: r.fit,
        color: r.color,
        alignment: r.alignment ?? Alignment.center,
        colorBlendMode: r.colorBlendMode,
        repeat: r.repeat ?? ImageRepeat.noRepeat,
        semanticLabel: r.semanticLabel,
        cacheWidth: r.cacheWidth,
        cacheHeight: r.cacheHeight,
        errorBuilder: r.error == null ? null : (ctx, e, st) => r.error!,
      ),
    );
  }
}
