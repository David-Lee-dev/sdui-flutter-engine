import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'engine',
        context: ErrorDescription('rendering SDUI node at $path'),
      ),
    );
    if (kReleaseMode) return const SizedBox.shrink();
    return _ErrorTag(path: path, message: '$error');
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
