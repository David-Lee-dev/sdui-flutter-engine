import 'package:sdui_engine/src/ir/model/engine_curve.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';

import 'invalid_template_exception.dart';
import 'schema/language_catalog.dart';

/// Decodes the root-only `_transition` declaration into immutable IR.
final class PageTransitionDecoder {
  const PageTransitionDecoder._();

  static const _keys = {
    'type',
    'duration',
    'reverse_duration',
    'curve',
    'content_timing',
    'params',
  };

  static PageTransitionSpec decode(
    Object? raw, {
    required LanguageCatalog catalog,
  }) {
    if (raw is! Map) {
      throw InvalidTemplateException('root', '"_transition" must be a map.');
    }

    final config = <String, Object?>{};
    for (final entry in raw.entries) {
      if (entry.key is! String) {
        throw InvalidTemplateException(
          'root',
          '"_transition" keys must be strings.',
        );
      }
      final key = entry.key as String;
      if (!_keys.contains(key)) {
        throw InvalidTemplateException(
          'root',
          'unknown "_transition" key "$key" '
              '(allowed: ${_keys.join(", ")}).',
        );
      }
      config[key] = _literal(entry.value, 'root/_transition.$key');
    }

    final type = config['type'];
    if (type is! String || type.isEmpty) {
      throw InvalidTemplateException(
        'root',
        '"_transition.type" must be a non-empty string.',
      );
    }
    if (!catalog.transitions.contains(type)) {
      throw InvalidTemplateException(
        'root',
        'Unknown page transition type "$type".',
      );
    }

    final durationMs = config.containsKey('duration')
        ? _duration(config['duration'], 'duration')
        : null;
    final reverseDurationMs = config.containsKey('reverse_duration')
        ? _duration(config['reverse_duration'], 'reverse_duration')
        : null;
    final curve = config['curve'];
    if (config.containsKey('curve') &&
        (curve is! String || !EngineCurveNames.all.contains(curve))) {
      throw InvalidTemplateException(
        'root',
        '"_transition.curve" must be an EngineCurve name.',
      );
    }

    final timing = switch (config['content_timing']) {
      'during_shared' => PageTransitionContentTiming.duringShared,
      'after_shared' => PageTransitionContentTiming.afterShared,
      null when !config.containsKey('content_timing') =>
        PageTransitionContentTiming.duringShared,
      _ => throw InvalidTemplateException(
        'root',
        '"_transition.content_timing" must be '
            '"during_shared" or "after_shared".',
      ),
    };
    final params = config['params'];
    if (config.containsKey('params') && params is! Map) {
      throw InvalidTemplateException(
        'root',
        '"_transition.params" must be a map.',
      );
    }

    return PageTransitionSpec(
      type: type,
      durationMs: durationMs,
      reverseDurationMs: reverseDurationMs,
      curve: curve as String?,
      contentTiming: timing,
      params: params is Map ? params.cast<String, Object?>() : const {},
    );
  }

  static int? _duration(Object? value, String key) {
    if (value is num && value.isFinite && value >= 0) return value.round();
    throw InvalidTemplateException(
      'root',
      '"_transition.$key" must be a finite, non-negative number in ms.',
    );
  }

  static Object? _literal(Object? value, String path) {
    if (value is String) {
      if (value.contains(r'${')) {
        throw InvalidTemplateException(
          path,
          '"_transition" only accepts static literal values, not expressions.',
        );
      }
      return value;
    }
    if (value is num) {
      if (!value.isFinite) {
        throw InvalidTemplateException(
          path,
          '"_transition" numbers must be finite.',
        );
      }
      return value;
    }
    if (value is bool || value == null) return value;
    if (value is List) {
      return List.unmodifiable([
        for (var i = 0; i < value.length; i++) _literal(value[i], '$path[$i]'),
      ]);
    }
    if (value is Map) {
      final result = <String, Object?>{};
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw InvalidTemplateException(
            path,
            '"_transition" map keys must be strings.',
          );
        }
        result[entry.key as String] = _literal(
          entry.value,
          '$path.${entry.key}',
        );
      }
      return Map.unmodifiable(result);
    }
    throw InvalidTemplateException(
      path,
      '"_transition" values must be JSON literals.',
    );
  }
}
