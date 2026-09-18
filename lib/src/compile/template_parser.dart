import 'package:sdui_engine/src/ir/model/ui_node.dart';
import 'invalid_template_exception.dart';

/// Parses a server template map into a [UiNode] tree.
///
/// Structural keys define the tree, bare keys become widget properties, and
/// remaining underscore-prefixed keys are reserved for compilation. This keeps
/// parsing independent of widget catalogs and marker semantics.
final class TemplateParser {
  const TemplateParser._();

  /// Maximum accepted nesting depth for a template tree.
  ///
  /// Rejecting pathological depth converts a potential stack overflow into an
  /// [InvalidTemplateException] that the mount error boundary can handle.
  static const _maxDepth = 256;

  /// Extracts a node's `_type` for path annotation, falling back to `?` when the
  /// child is malformed (the recursive call reports the real error with context).
  static String _typeTag(Object? node) =>
      (node is Map && node['_type'] is String) ? node['_type'] as String : '?';

  /// Builds a [UiNode] tree rooted at [json].
  ///
  /// [path] supplies diagnostic context and [depth] tracks recursive nesting.
  /// Throws [InvalidTemplateException] when structural keys are missing,
  /// mutually exclusive child forms are combined, or the depth limit is exceeded.
  static UiNode buildUiTree(
    Map<String, Object?> json, {
    String path = 'root',
    int depth = 0,
  }) {
    if (depth > _maxDepth) {
      throw InvalidTemplateException(
        path,
        'template nesting too deep (>$_maxDepth) — malformed template?',
      );
    }
    final type = json['_type'];
    if (type is! String) {
      throw InvalidTemplateException(path, 'Node must have a string "_type".');
    }
    final key = json['_key'];
    if (key != null && key is! String) {
      throw InvalidTemplateException(path, 'Node "_key" must be a string.');
    }

    final children = _parseChildren(json, path, depth);
    final slots = _parseSlots(json, path, depth);
    const structural = {'_type', '_child', '_children', '_key', '_slots'};
    // Structural keys are consumed above; lexical prefixes separate the
    // remaining widget properties from compiler-reserved markers.
    final props = <String, Object?>{};
    final reserved = <String, Object?>{};
    for (final entry in json.entries) {
      if (structural.contains(entry.key)) continue;
      if (entry.key.startsWith('_')) {
        reserved[entry.key] = entry.value;
      } else {
        props[entry.key] = entry.value;
      }
    }

    return UiNode(
      type: type,
      props: Map.unmodifiable(props),
      reserved: Map.unmodifiable(reserved),
      children: children,
      slots: Map.unmodifiable(slots),
      key: key as String?,
      path: path,
    );
  }

  /// Parses `_slots` into named child nodes.
  ///
  /// Slots are mutually exclusive with positional children, and every slot
  /// value must be a node map. Invalid shapes throw [InvalidTemplateException].
  static Map<String, UiNode> _parseSlots(
    Map<String, Object?> json,
    String path,
    int depth,
  ) {
    final raw = json['_slots'];
    if (raw == null) return const {};
    if (raw is! Map) {
      throw InvalidTemplateException(
        path,
        '"_slots" must be a map of {slot: node}.',
      );
    }
    if (json['_child'] != null || json['_children'] != null) {
      throw InvalidTemplateException(
        path,
        'Node cannot have both "_slots" and "_child"/"_children".',
      );
    }
    final result = <String, UiNode>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! Map) {
        throw InvalidTemplateException(
          path,
          '"_slots.${entry.key}" must be a map (node).',
        );
      }
      result['${entry.key}'] = buildUiTree(
        value.cast(),
        path: '$path/slots[${entry.key}]:${_typeTag(value)}',
        depth: depth + 1,
      );
    }
    return result;
  }

  static List<UiNode> _parseChildren(
    Map<String, Object?> json,
    String path,
    int depth,
  ) {
    final single = json['_child'];
    final many = json['_children'];
    if (single != null && many != null) {
      throw InvalidTemplateException(
        path,
        'Node cannot have both "_child" and "_children".',
      );
    }
    if (single != null) {
      if (single is! Map) {
        throw InvalidTemplateException(path, '"_child" must be a map.');
      }
      return [
        buildUiTree(
          single.cast(),
          path: '$path/child:${_typeTag(single)}',
          depth: depth + 1,
        ),
      ];
    }
    if (many != null) {
      if (many is! List) {
        throw InvalidTemplateException(path, '"_children" must be a list.');
      }
      return [
        for (var i = 0; i < many.length; i++)
          if (many[i] is Map)
            buildUiTree(
              (many[i] as Map).cast(),
              path: '$path/children[$i]:${_typeTag(many[i])}',
              depth: depth + 1,
            )
          else
            throw InvalidTemplateException(
              path,
              '"_children[$i]" must be a map.',
            ),
      ];
    }
    return const [];
  }
}
