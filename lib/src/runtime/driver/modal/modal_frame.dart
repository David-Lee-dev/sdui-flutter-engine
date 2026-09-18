import 'package:flutter/material.dart';
import 'package:sdui_engine/src/engine_runner.dart';

import '../../engine_host.dart';
import '../../motion/_base.dart';
import '../../motion/composite/presets.dart';
import '../../motion/motion_factory.dart';
import '../../telemetry/telemetry.dart';
import '../../wrapper/motion.dart';

/// Selects the modal layout and its default entrance behavior.
///
/// Dialogs fade in. Bottom sheets slide their full height from below the screen
/// without fading their content, while the backdrop still fades. A command's
/// `motion` preset replaces the native sheet slide with the preset plus fade.
/// Dialogs own overflow scrolling. Bottom-sheet templates own it within the 80%
/// cap so pinned footers can put a Flexible scroll area in a min-sized Column.
enum ModalVariant { dialog, bottomSheet }

/// Allows a modal stack entry to request an animated close.
class ModalCloseController {
  void Function(Object? result)? _onClose;

  void requestClose([Object? result]) => _onClose?.call(result);
}

/// Renders modal content in an isolated engine root with backdrop and exit handling.
class ModalFrame extends StatefulWidget {
  const ModalFrame({
    super.key,
    required this.content,
    this.data,
    this.host,
    this.modalId,
    this.screenId,
    required this.variant,
    this.align,
    this.motion,
    this.dismissible = true,
    required this.controller,
    required this.onClosed,
  });

  final Object content;
  final Map<String, Object?>? data;

  final EngineHost? host;

  /// The template-facing id of the modal being shown (TELEMETRY.md §2).
  final String? modalId;

  /// The screen that opened this modal, which its events belong to.
  ///
  /// Together with [modalId] this is what makes the frame an observable
  /// surface; with either missing the frame records nothing, which is what a
  /// bare frame built directly in a test does.
  final String? screenId;

  final ModalVariant variant;

  final String? align;

  final String? motion;
  final bool dismissible;
  final ModalCloseController controller;
  final void Function(Object? result, bool dismissed) onClosed;

  @override
  State<ModalFrame> createState() => _ModalFrameState();
}

class _ModalFrameState extends State<ModalFrame>
    with SingleTickerProviderStateMixin {
  // Lets tests distinguish the sheet slide from framework page transitions.
  static const _sheetSlideKey = ValueKey<String>('modal-sheet-slide');

  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _sheetSlide =
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _presence,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
  bool _closing = false;

  /// This showing's `surface_view_id` (TELEMETRY.md §2), or `null` when the
  /// frame has no identity to report under.
  ///
  /// A modal is a surface of its own, not a screen visit: it is an overlay, so
  /// the screen underneath keeps `ModalRoute.isCurrent` and its dwell clock
  /// keeps running. This frame owns the `screen_view` for the surface exactly
  /// as `ScreenPage` owns it for a screen; the body's [EngineRunner] owns the
  /// matching `screen_leave` because it is the one measuring dwell and scroll.
  String? _surfaceViewId;

  /// Why this modal closed, read back by the body's [EngineRunner] when it
  /// emits the surface's `screen_leave`. Set before the exit animation so it
  /// is in place by the time the body unmounts.
  String? _exitReason;

  bool get _observable => widget.modalId != null && widget.screenId != null;

  @override
  void initState() {
    super.initState();
    widget.controller._onClose = (result) => _exit(result, false);
    _presence.forward();
    if (_observable) _openSurface();
  }

  void _openSurface() {
    final surfaceViewId = Telemetry.newId();
    _surfaceViewId = surfaceViewId;
    Telemetry.record(
      'screen_view',
      screenId: widget.screenId,
      screenViewId: surfaceViewId,
      properties: {
        'surface_type': 'modal',
        'modal_id': widget.modalId,
        'from': widget.screenId,
      },
    );
  }

  void _exit(Object? result, bool dismissed) {
    if (_closing) return;
    _closing = true;
    _exitReason = dismissed ? 'dismissed' : 'closed';
    _presence.reverse().whenComplete(() => widget.onClosed(result, dismissed));
  }

  void _onBackdrop() {
    if (widget.dismissible) _exit(null, true);
  }

  @override
  void dispose() {
    widget.controller._onClose = null;
    _presence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // The keyboard overlays the viewport rather than resizing it, so a sheet
    // pinned to the physical bottom sits underneath it — its own text field
    // ends up hidden behind the keys that are typing into it.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _presence,
            child: GestureDetector(
              onTap: _onBackdrop,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Color(0x8A000000)),
            ),
          ),
        ),
        Positioned.fill(child: _positioned(size, keyboard)),
      ],
    );
  }

  Widget _positioned(Size size, double keyboard) {
    // Height budget is measured against what the keyboard leaves visible.
    final available = size.height - keyboard;
    final maxHeight =
        available * (widget.variant == ModalVariant.dialog ? 0.9 : 0.8);
    if (widget.variant == ModalVariant.dialog) {
      final box = SizedBox(
        width: size.width * 0.9,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(child: _content()),
        ),
      );
      // Centre within what the keyboard leaves visible, not the whole viewport —
      // otherwise a centred dialog's lower half sits under the keys.
      return Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SafeArea(
          child: Align(
            alignment: _dialogAlign(),
            child: FadeTransition(opacity: _presence, child: _entrance(box)),
          ),
        ),
      );
    }
    // Bottom sheets slide natively without a content fade unless a command
    // explicitly replaces that entrance with a motion preset plus fade.
    final box = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: _content(),
    );
    final content = Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(top: false, child: box),
    );
    if (widget.motion == null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          key: _sheetSlideKey,
          position: _sheetSlide,
          child: content,
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: FadeTransition(opacity: _presence, child: _entrance(content)),
    );
  }

  // Deliberately no `errorBuilder` override here: `TukErrorScreen` is a
  // full-viewport `Scaffold` (its own background fill, a fixed-size centered
  // image, SafeArea assumptions) meant to replace an entire screen, not to
  // sit inside this frame's constrained sheet/dialog box — squeezed in here
  // it would clip and look broken. Its retry button also re-fetches the
  // *screen* template via ScreenPage's loader, which has nothing to do with
  // a modal body sourced from `modalTemplates` already resolved on the
  // parent screen. A modal body that fails to compile leaves the opening
  // screen live underneath, so it stays on EngineRunner's bare-text default,
  // which never crashes and degrades gracefully inside any box size.
  Widget _content() => Material(
    type: MaterialType.transparency,
    child: EngineRunner(
      template: _template,
      rootData: widget.data ?? const {},
      host: widget.host,
      // All-or-nothing: a partially identified surface would have the body
      // reporting dwell against a visit id nobody issued.
      screenId: _observable ? widget.screenId : null,
      screenViewId: _surfaceViewId,
      surfaceType: _observable ? 'modal' : null,
      modalId: _observable ? widget.modalId : null,
      resolveExitReason: () => _exitReason,
    ),
  );

  Widget _entrance(Widget child) {
    final name = _motionName;
    if (name == null || name == 'none' || name == 'fade') return child;
    try {
      var wrapped = child;
      for (final atom in MotionPresets.expand(name, const {})) {
        wrapped = MotionWrapper(
          motion: MotionFactory.resolve(atom.type),
          params: MotionParams(atom.params),
          child: wrapped,
        );
      }
      return wrapped;
    } catch (_) {
      return child;
    }
  }

  String? get _motionName => widget.motion;

  Alignment _dialogAlign() => switch (widget.align) {
    'top' => Alignment.topCenter,
    'bottom' => Alignment.bottomCenter,
    _ => Alignment.center,
  };

  Map<String, Object?> get _template => widget.content is Map
      ? Map<String, Object?>.from(widget.content as Map)
      : const {};
}
