import 'package:flutter/widgets.dart';
import 'package:sdui_engine/src/contract/image_source.dart';

import '../../../util/props_resolver.dart';
import '../../../media/image_source_registry.dart';
import '../../../media/loading_image.dart';

/// `image` — Resolves an `image` node through the installed [ImageSource].
///
/// Named `loading` and `error` slots are presented while the installed image
/// source handles asset selection and image construction.
///
/// ```yaml
/// _type: image
/// src: example
/// _slots: { error: { _type: text, value: error }, loading: { _type: text, value: loading } }
/// ```
///
/// Props:
/// - `src` (`text`, default `null`) — media source path or URL.
/// - `width` (`size` (scaled by EngineMetrics), default `null`) — sets the box width.
/// - `height` (`size` (scaled by EngineMetrics), default `null`) — sets the box height.
/// - `fit` (`boxFit`, default `null`) — content fitting mode. Values: fill | contain | cover | fit_width | fit_height | none | scale_down.
/// - `color` (`color`, default `null`) — color or tint.
/// - `alignment` (`alignment`, default `null`) — positions the child or children within the available space. Values: top_left | top_center | top_right | center_left | center | center_right | bottom_left | bottom_center | bottom_right.
/// - `color_blend_mode` (`blendMode`, default `null`) — operation used to blend the tint with image pixels. Values: src_over | src_atop | src_in | dst_in | modulate | multiply | screen | overlay | darken | lighten | color | hue | saturation | luminosity | difference | exclusion | plus | clear.
/// - `repeat` (`imageRepeat`, default `null`) — tiles the image along the selected axes. Values: no_repeat | repeat | repeat_x | repeat_y.
/// - `semantic_label` (`text`, default `null`) — accessibility label.
/// - `cache_width` (`integer`, default `null`) — target decoded image width in physical pixels.
/// - `cache_height` (`integer`, default `null`) — target decoded image height in physical pixels.
///
/// Child: `_slots: { error, loading }`.
///
/// Rendering delegates to the app-installed bundled-first policy; `.svg` is
/// detected by extension, and `color` applies a tint.
final class ImageWidget {
  const ImageWidget._();

  static Widget build(
    BuildContext context,
    Map<String, Object?> props,
    Map<String, Widget> slots,
  ) {
    final src = props['src'];
    if (src is! String || src.isEmpty) return const SizedBox.shrink();
    final width = PropsResolver.size(context, props['width']);
    final height = PropsResolver.size(context, props['height']);
    final result = ImageSourceRegistry.current.resolve(
      ImageRequest(
        src: src,
        width: width,
        height: height,
        fit: PropsResolver.boxFit(props['fit']),
        color: PropsResolver.color(props['color']),
        alignment: PropsResolver.alignment(props['alignment']),
        colorBlendMode: PropsResolver.blendMode(props['color_blend_mode']),
        repeat: PropsResolver.imageRepeat(props['repeat']),
        semanticLabel: PropsResolver.text(props['semantic_label']),
        cacheWidth: PropsResolver.integer(props['cache_width']),
        cacheHeight: PropsResolver.integer(props['cache_height']),
        loading: slots['loading'],
        error: slots['error'],
      ),
    );
    return switch (result) {
      NoImage() => const SizedBox.shrink(),
      ReadyImage(:final image) => image,
      PendingImage(:final image) => FutureBuilder<Widget?>(
        future: image,
        builder: (context, snapshot) {
          final done = snapshot.connectionState == ConnectionState.done;
          final image = snapshot.data;
          final loaded = done && image != null;
          final placeholder = done
              ? slots['error'] ?? const SizedBox.shrink()
              : slots['loading'] ??
                    shimmerPlaceholder(width: width, height: height);
          return loadingImageTransition(
            loaded: loaded,
            placeholder: placeholder,
            image: image ?? const SizedBox.shrink(),
          );
        },
      ),
    };
  }
}
