import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sdui_engine/src/contract/error_observer.dart';
import '../../engine_errors.dart';
import '../../engine_presentation.dart';

/// Isolates expected template runtime failures at a single node boundary.
///
/// [FormatException] and [StateError] become compact diagnostics in debug builds
/// and empty layout in release. Other errors remain visible as engine defects.
final class NodeGuard {
  const NodeGuard._();

  static Widget run(String path, Widget Function() build) {
    try {
      return build();
    } on FormatException catch (e, s) {
      return _degrade(path, e, s);
    } on StateError catch (e, s) {
      return _degrade(path, e, s);
    }
  }

  static Widget _degrade(String path, Object error, StackTrace stack) {
    EngineErrors.report(
      SduiError(
        scope: SduiErrorScope.nodeBuild,
        error: error,
        stack: stack,
        nodePath: path,
      ),
    );
    return Builder(
      builder: (context) {
        // Surface is app-replaceable; the fallback keeps the classic policy —
        // a compact diagnostic in debug, empty layout in release.
        final builder = EnginePresentation.value.nodeErrorBuilder;
        if (builder != null) return builder(context, path, error);
        if (kReleaseMode) return const SizedBox.shrink();
        return _ErrorTag(path: path, message: '$error');
      },
    );
  }
}

class _ErrorTag extends StatelessWidget {
  const _ErrorTag({required this.path, required this.message});

  final String path;
  final String message;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: Color(0x22FF3B30)),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        'SDUI error @ $path\n$message',
        style: const TextStyle(color: Color(0xFFD70015), fontSize: 10),
      ),
    ),
  );
}
