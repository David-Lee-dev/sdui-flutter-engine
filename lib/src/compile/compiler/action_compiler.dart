import 'package:sdui_engine/src/ir/model/action/command.dart';
import '../invalid_template_exception.dart';
import 'value_compiler.dart';

/// Compiles template action definitions into driver-agnostic command flows.
///
/// Driver types remain unresolved for the runtime registry, while parameter
/// expressions are compiled eagerly through [ValueCompiler].
class ActionCompiler {
  const ActionCompiler._();

  static const _commandReserved = {
    '_type',
    '_then',
    '_error',
    '_dismiss',
    '_always',
    '_background',
    '_when',
  };

  /// Compiles [def] into an [Action].
  ///
  /// An action is either a **single command** (a map with `_type`) or a **flow**
  /// (a list of batches run in order; a nested list runs its commands
  /// concurrently via `Future.wait`). No `_steps` wrapper — the value shape is
  /// the flow. Action-level `_dedupe` (optional, defaults true) only rides on
  /// the single-command map form.
  ///
  /// Throws [InvalidTemplateException] when the flow shape, command metadata,
  /// or an embedded expression is invalid. [path] identifies the definition in
  /// diagnostics.
  static Action compile(Object? def, String path) {
    if (def is Map && def.containsKey('_dedupe')) {
      final command = {
        for (final entry in def.entries)
          if ('${entry.key}' != '_dedupe') '${entry.key}': entry.value,
      };
      return Action(
        steps: _flow(command, path),
        dedupe: _dedupe(def['_dedupe'], path),
      );
    }
    return Action(steps: _flow(def, path), dedupe: true);
  }

  static bool _dedupe(Object? raw, String path) {
    if (raw == null) return true;
    if (raw is! bool) {
      throw InvalidTemplateException(path, '"_dedupe" must be a bool.');
    }
    return raw;
  }

  static Flow _flow(Object? raw, String path) {
    if (raw is Map) {
      return [
        [_command(raw.cast(), path)],
      ];
    }
    if (raw is! List) {
      throw InvalidTemplateException(
        path,
        'flow must be a command map or a list of batches.',
      );
    }
    return [for (var i = 0; i < raw.length; i++) _batch(raw[i], '$path[$i]')];
  }

  static Batch _batch(Object? raw, String path) {
    if (raw is Map) return [_command(raw.cast(), path)];
    if (raw is! List) {
      throw InvalidTemplateException(
        path,
        'batch must be a command map or a list of commands.',
      );
    }
    return [
      for (var j = 0; j < raw.length; j++)
        if (raw[j] is Map)
          _command((raw[j] as Map).cast(), '$path[$j]')
        else
          throw InvalidTemplateException('$path[$j]', 'command must be a map.'),
    ];
  }

  static Command _command(Map<String, Object?> node, String path) {
    final type = node['_type'];
    if (type is! String || type.isEmpty) {
      throw InvalidTemplateException(
        path,
        'command needs a non-empty string "_type".',
      );
    }
    // The underscore prefix belongs to engine metadata, so an unknown name is
    // a malformed command rather than a driver parameter.
    for (final key in node.keys) {
      if (key.startsWith('_') && !_commandReserved.contains(key)) {
        throw InvalidTemplateException(
          path,
          'unknown command key "$key" (engine keys are a fixed set; '
          'driver params must not start with "_").',
        );
      }
    }
    final background = node['_background'] ?? false;
    if (background is! bool) {
      throw InvalidTemplateException(path, '"_background" must be a bool.');
    }
    // A fire-and-forget invocation cannot produce a result for any handler.
    if (background) {
      for (final handler in const ['_then', '_error', '_dismiss', '_always']) {
        if (node.containsKey(handler)) {
          throw InvalidTemplateException(
            path,
            '"$handler" on a "_background" command never runs '
            '(background is fire-and-forget).',
          );
        }
      }
    }
    final rawWhen = node['_when'];
    if (node.containsKey('_when') && rawWhen is! String) {
      throw InvalidTemplateException(
        '$path/_when',
        '"_when" must be a single "\${…}" expression string.',
      );
    }
    return Command(
      type: type,
      params: _params(node, path),
      when: node.containsKey('_when')
          ? ValueCompiler.wholeExpression(rawWhen as String, '$path/_when')
          : null,
      then: node.containsKey('_then')
          ? _flow(node['_then'], '$path/_then')
          : null,
      onError: _parseOnError(node['_error'], path),
      dismiss: node.containsKey('_dismiss')
          ? _flow(node['_dismiss'], '$path/_dismiss')
          : null,
      always: node.containsKey('_always')
          ? _flow(node['_always'], '$path/_always')
          : null,
      background: background,
    );
  }

  static Map<String, Flow>? _parseOnError(Object? raw, String path) {
    if (raw == null) return null;
    if (raw is! Map) {
      throw InvalidTemplateException(
        path,
        '"_error" must be a map of {code: flow}.',
      );
    }
    return {
      for (final entry in raw.entries)
        '${entry.key}': _flow(entry.value, '$path/_error/${entry.key}'),
    };
  }

  static Map<String, Object?> _params(Map<String, Object?> node, String path) {
    return ValueCompiler.map({
      for (final entry in node.entries)
        if (!_commandReserved.contains(entry.key)) entry.key: entry.value,
    }, path);
  }
}
