import 'package:flutter/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _fadeDuration = Duration(milliseconds: 275);

/// Builds a themed shimmer box when both image dimensions are known.
///
/// Without a complete size the placeholder stays empty to avoid changing the
/// surrounding layout when the image arrives.
Widget shimmerPlaceholder({double? width, double? height}) {
  if (width == null || height == null) return const SizedBox.shrink();
  return Skeletonizer.zone(
    child: Bone(width: width, height: height),
  );
}

/// Cross-fades between keyed loading and loaded image states.
Widget loadingImageTransition({
  required bool loaded,
  required Widget placeholder,
  required Widget image,
}) => _LoadingImageTransition(
  loaded: loaded,
  placeholder: placeholder,
  image: image,
);

class _LoadingImageTransition extends StatefulWidget {
  const _LoadingImageTransition({
    required this.loaded,
    required this.placeholder,
    required this.image,
  });

  final bool loaded;
  final Widget placeholder;
  final Widget image;

  @override
  State<_LoadingImageTransition> createState() =>
      _LoadingImageTransitionState();
}

class _LoadingImageTransitionState extends State<_LoadingImageTransition> {
  // AnimatedSwitcher keys each child to tell inserts from removals apart, but
  // it only has two possible keys if keyed directly on `loaded` — and several
  // outgoing fades can be in flight together (each lives `_fadeDuration`, and
  // more pile up under jank), so two keys collide across four-plus live
  // entries. A generation that advances only on an actual `loaded` flip gives
  // every fade a distinct key while a same-state rebuild with a different
  // child still lands on AnimatedSwitcher's "update in place" path.
  int _generation = 0;

  @override
  void didUpdateWidget(_LoadingImageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loaded != widget.loaded) _generation++;
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: _fadeDuration,
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeOut,
    child: KeyedSubtree(
      key: ValueKey(_generation),
      child: widget.loaded ? widget.image : widget.placeholder,
    ),
  );
}

/// Fades in the first asynchronously decoded raster frame.
Widget fadeInImageFrame(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  return AnimatedOpacity(
    opacity: frame == null ? 0 : 1,
    duration: _fadeDuration,
    curve: Curves.easeOut,
    child: child,
  );
}
