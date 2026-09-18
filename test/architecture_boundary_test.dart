import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the engine's layer architecture at the import level.
///
/// Two guarantees, both over the *complete* resolved import graph of
/// `lib/` (not a sampled subset — a rule that scans nothing passes nothing):
///
/// 1. **No import cycles anywhere.** Every strongly connected component of
///    more than one file fails the suite, whatever layers it spans.
/// 2. **Layer edges only in the allowed direction** (see [allowed] below).
///
/// This keeps the compile stage free of the widget runtime so compilation can
/// move to build time or the server, and keeps low-level runtime modules from
/// reaching up into the top-level runner. A violation here means a boundary
/// is leaking again — fix the dependency, do not relax this file.
void main() {
  const libRoot = 'lib';

  final importRe = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  /// Repo-relative path of the engine file [import] resolves to, or null for
  /// dart:/third-party imports.
  String? resolve(String import, File from) {
    String abs;
    if (import.startsWith('package:sdui_engine/')) {
      abs = 'lib/${import.substring('package:sdui_engine/'.length)}';
    } else if (import.startsWith('dart:') || import.startsWith('package:')) {
      return null;
    } else {
      final parts = <String>[
        ...from.parent.path.split('/'),
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
    return abs.startsWith('$libRoot/') ? abs : null;
  }

  // ── Build the full graph (lazily, inside the test zone) ──────────────────
  Map<String, Set<String>> buildGraph() {
    final files = Directory(libRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    expect(files.length, greaterThan(100), reason: 'scan found too few files');

    final graph = <String, Set<String>>{};
    for (final file in files) {
      graph[file.path] = importRe
          .allMatches(file.readAsStringSync())
          .map((m) => resolve(m.group(1)!, file))
          .whereType<String>()
          .toSet();
    }
    return graph;
  }

  group('architecture', () {
    test('no cross-module import cycles anywhere in lib/', () {
      // One deliberate exception: `interpreter/building/**` is a single
      // recursive-descent builder — NodeBuilder and its observers are
      // mutually recursive over a recursive IR, which is the algorithm, not
      // a boundary leak. Files there collapse into one graph node; every
      // OTHER cycle (across modules) still fails.
      const cohesiveModules = ['lib/src/runtime/interpreter/building/'];
      String node(String path) {
        for (final module in cohesiveModules) {
          if (path.startsWith(module)) return module;
        }
        return path;
      }

      final fileGraph = buildGraph();
      final graph = <String, Set<String>>{};
      fileGraph.forEach((path, imports) {
        final from = node(path);
        final targets = graph.putIfAbsent(from, () => <String>{});
        for (final target in imports) {
          final to = node(target);
          if (to != from) targets.add(to);
        }
      });
      // Tarjan SCC over the module-collapsed graph.
      var index = 0;
      final indices = <String, int>{};
      final lowlink = <String, int>{};
      final onStack = <String>{};
      final stack = <String>[];
      final cycles = <List<String>>[];

      void strongconnect(String v) {
        indices[v] = index;
        lowlink[v] = index;
        index += 1;
        stack.add(v);
        onStack.add(v);
        for (final w in graph[v] ?? const <String>{}) {
          if (!graph.containsKey(w)) continue;
          if (!indices.containsKey(w)) {
            strongconnect(w);
            if (lowlink[w]! < lowlink[v]!) lowlink[v] = lowlink[w]!;
          } else if (onStack.contains(w)) {
            if (indices[w]! < lowlink[v]!) lowlink[v] = indices[w]!;
          }
        }
        if (lowlink[v] == indices[v]) {
          final component = <String>[];
          String w;
          do {
            w = stack.removeLast();
            onStack.remove(w);
            component.add(w);
          } while (w != v);
          if (component.length > 1) cycles.add(component);
        }
      }

      for (final v in graph.keys) {
        if (!indices.containsKey(v)) strongconnect(v);
      }

      expect(
        cycles,
        isEmpty,
        reason:
            'import cycles found:\n${cycles.map((c) => c.join(' <-> ')).join('\n')}',
      );
    });

    test('layer edges only point in the allowed direction', () {
      final graph = buildGraph();
      /// First matching prefix wins; files outside every entry (barrels,
      /// engine root) are unrestricted importers but still valid targets.
      String? layerOf(String path) {
        const layers = [
          'lib/src/shell/',
          'lib/src/impl/',
          'lib/src/compile/',
          'lib/src/runtime/',
          'lib/src/ir/',
          'lib/src/dependency/',
          'lib/src/contract/',
        ];
        for (final layer in layers) {
          if (path.startsWith(layer)) return layer;
        }
        if (path == 'lib/src/engine.dart' || path == 'lib/src/engine_runner.dart') {
          return 'root';
        }
        return null;
      }

      /// What each layer may import (its own layer is always allowed).
      /// `root` = engine.dart / engine_runner.dart, the top-level assemblers.
      const allowed = <String, Set<String>>{
        'lib/src/shell/': {
          'root',
          'lib/src/runtime/',
          'lib/src/compile/',
          'lib/src/ir/',
          'lib/src/dependency/',
          'lib/src/contract/',
          'lib/src/impl/',
        },
        'lib/src/impl/': {'lib/src/dependency/'},
        'root': {
          'lib/src/compile/',
          'lib/src/runtime/',
          'lib/src/ir/',
          'lib/src/dependency/',
          'lib/src/contract/',
        },
        // runtime compiles on device today; engine_subtree keeps it from
        // importing the root runner. TODO(catalog-split): drop compile/ here
        // once nested templates are compiled ahead of widget construction.
        'lib/src/runtime/': {
          'lib/src/compile/',
          'lib/src/ir/',
          'lib/src/dependency/',
          'lib/src/contract/',
        },
        'lib/src/compile/': {'lib/src/ir/'},
        'lib/src/ir/': <String>{},
        'lib/src/dependency/': <String>{},
        'lib/src/contract/': <String>{},
      };

      final violations = <String>[];
      graph.forEach((path, imports) {
        final from = layerOf(path);
        if (from == null) return; // barrels: unrestricted importers
        final permitted = allowed[from];
        expect(permitted, isNotNull, reason: 'no rule for layer $from');
        for (final target in imports) {
          final to = layerOf(target);
          if (to == null || to == from) continue;
          if (!permitted!.contains(to)) {
            violations.add('$path -> $target  ($from may not import $to)');
          }
        }
      });

      expect(
        violations,
        isEmpty,
        reason: 'forbidden layer edges:\n${violations.join('\n')}',
      );
    });
  });
}
