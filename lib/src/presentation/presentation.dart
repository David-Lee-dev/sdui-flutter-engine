import 'package:flutter/widgets.dart';

import '../contract/tap_feedback.dart';
import 'modal_style.dart';
import 'scaling.dart';
import 'typography.dart';

/// Presents a template `toast` command — the app's chance to replace the
/// default SnackBar with its own component. [variant] is the command's
/// normalized variant string (`info`/`warn`/`error`/...), or `null`.
typedef SduiToastPresenter =
    void Function(BuildContext context, String message, String? variant);

/// Builds the surface shown when a screen template fails to compile and the
/// mount supplied no local `errorBuilder`.
typedef SduiScreenErrorBuilder =
    Widget Function(BuildContext context, Object error);

/// Builds the surface shown when a screen failed to *load* (the
/// [ScreenLoader] threw) and the page supplied no local `errorBuilder`.
/// Unlike a compile failure, a load failure is retryable.
typedef SduiLoadErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// Builds the in-place surface for a degraded node ([SduiErrorScope.nodeBuild]
/// isolation). `null` keeps the classic policy: compact diagnostic in debug,
/// empty layout in release.
typedef SduiNodeErrorBuilder =
    Widget Function(BuildContext context, String nodePath, Object error);

/// App-owned static configuration for the surfaces the engine draws itself.
///
/// The engine owns the *behavior* (when feedback plays, how a modal mounts,
/// when the error surface shows); the app owns the *look* — one value object
/// injected at boot configures all of it. Values only: anything that makes a
/// decision is an implementation and lives behind a contract instead
/// ([TapFeedback] is the example — this object merely carries which one).
final class SduiPresentation {
  const SduiPresentation({
    this.tapFeedback,
    this.modal = const ModalStyle(),
    this.typography = const SduiTypography(),
    this.scaling = const SduiScaling(),
    this.screenErrorBuilder,
    this.loadErrorBuilder,
    this.nodeErrorBuilder,
    this.loadingBuilder,
  });

  /// Press feedback implementation; `null` uses the package default
  /// (Flutter's stock ink ripple).
  final TapFeedback? tapFeedback;

  final ModalStyle modal;
  final SduiTypography typography;
  final SduiScaling scaling;

  /// Global default for the compile-failure surface; a mount-local
  /// `errorBuilder` still wins.
  final SduiScreenErrorBuilder? screenErrorBuilder;

  /// Global default for the facade's load-failure surface; a page-local
  /// `errorBuilder` still wins.
  final SduiLoadErrorBuilder? loadErrorBuilder;

  /// Replaces the degraded-node surface (debug tag / release empty box).
  final SduiNodeErrorBuilder? nodeErrorBuilder;

  /// Global default for the facade's loading surface; a page-local
  /// `loadingBuilder` still wins.
  final WidgetBuilder? loadingBuilder;
}
