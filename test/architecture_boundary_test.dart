import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the compile/runtime engine boundary at the import level.
///
/// The engine is layered: `ir/` is the pure compiled artifact, `compile/`
/// turns templates into it, `runtime/` interprets it into a live Flutter tree.
/// The dependency rule is one-directional:
///   - `ir/`      must import none of `compile/`, `runtime/`, or `contract/`.
///   - `compile/` must import neither `runtime/` nor `contract/` (it may import `ir/`).
///   - `runtime/` may import `compile/` and `ir/` (it compiles on device).
///
/// This keeps the compile stage free of the widget runtime so compilation can
/// move to build time or the server. A violation here means the boundary the
/// split established is leaking again — fix the dependency, do not relax this.
void main() {
  const root = 'lib/src';

  /// Returns the engine-relative segment an [import] in [file] points to, or
  /// null when it leaves the engine (dart:, third-party, or a sibling layer's
  /// concern). Resolves both `package:sdui_engine/src/…` and relative forms.
  String? engineSegment(String import, File file) {
    String abs;
    if (import.startsWith('package:sdui_engine/src/')) {
      abs = 'lib/src/${import.substring('package:sdui_engine/src/'.length)}';
    } else if (import.startsWith('dart:') || import.startsWith('package:')) {
      return null;
    } else {
      final parts = <String>[
        ...file.parent.path.split('/'),
        ...import.split('/'),
      ];
      final stack = <String>[];
      for (final part in parts) {
        if (part == '.' || part.isEmpty) continue;
        if (part == '..') {
          if (stack.isNotEmpty) stack.removeLast();
        } else {
          stack.add(part);
        }
      }
      abs = stack.join('/');
    }
    const prefix = '$root/';
    return abs.startsWith(prefix) ? abs.substring(prefix.length) : null;
  }

  final importRe = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  Iterable<String> importsOf(File f) =>
      importRe.allMatches(f.readAsStringSync()).map((m) => m.group(1)!);

  List<File> dartFilesUnder(String layer) {
    final dir = Directory('$root/$layer');
    // A missing layer means the scan root is wrong — never pass vacuously.
    expect(dir.existsSync(), isTrue, reason: 'missing layer dir: $root/$layer');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  /// Fails if any file under [layer] imports a file under one of [forbidden].
  void assertNoDependency(String layer, Set<String> forbidden) {
    final violations = <String>[];
    for (final file in dartFilesUnder(layer)) {
      for (final import in importsOf(file)) {
        final seg = engineSegment(import, file);
        if (seg == null) continue;
        final top = seg.split('/').first;
        if (forbidden.contains(top)) {
          violations.add('${file.path}  →  $import');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          '$layer/ must not depend on ${forbidden.join('/')}:\n'
          '${violations.join('\n')}',
    );
  }

  group('engine compile/runtime boundary', () {
    test('ir/ depends on neither compile/, runtime/, nor contract/', () {
      assertNoDependency('ir', {'compile', 'runtime', 'contract'});
    });

    test('compile/ does not depend on runtime/ or contract/', () {
      assertNoDependency('compile', {'runtime', 'contract'});
    });
  });
}
