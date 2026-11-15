import 'package:flutter/widgets.dart';

import '../../../../../contract/model_3d_source.dart';
import '../../../../util/props_resolver.dart';
import '../../../../log/engine_log.dart';

/// Parses finite coordinates, preserving each caller's string-coercion policy.
(double, double, double)? parseModel3dPoint(
  Object? raw, {
  bool coerceStrings = false,
}) {
  if (raw is! List || raw.length != 3) return null;
  if (!coerceStrings && raw.any((value) => value is! num)) return null;
  final x = PropsResolver.number(raw[0]);
  final y = PropsResolver.number(raw[1]);
  final z = PropsResolver.number(raw[2]);
  if (x == null || y == null || z == null) return null;
  return (x, y, z);
}

Model3dOutfit parseModel3dOutfit(Object? raw) {
  final map = raw is Map ? raw : const {};
  List<String> names(Object? value) => value is List
      ? value.whereType<String>().where((s) => s.trim().isNotEmpty).toList()
      : const [];
  final colors = <String, Color>{};
  if (map['colors'] case final Map values) {
    for (final entry in values.entries) {
      final color = PropsResolver.color(entry.value);
      if (entry.key is String && color != null) {
        colors[entry.key as String] = color;
      }
    }
  }
  final attach = <String, String?>{};
  if (map['attach'] case final Map values) {
    for (final entry in values.entries) {
      if (entry.key is! String) continue;
      final value = entry.value;
      if (value == null || value is String && value.trim().isNotEmpty) {
        attach[entry.key as String] = value as String?;
      }
    }
  }
  final duration = PropsResolver.number(map['transition_duration']);
  return Model3dOutfit(
    show: names(map['show']),
    hide: names(map['hide']),
    colors: colors,
    attach: attach,
    transition: switch (map['transition']) {
      'cut' => Model3dOutfitTransition.cut,
      'drop' => Model3dOutfitTransition.drop,
      'dissolve' => Model3dOutfitTransition.dissolve,
      _ => Model3dOutfitTransition.pop,
    },
    duration: Duration(
      milliseconds: duration != null && duration >= 0 ? duration.round() : 300,
    ),
  );
}

List<Model3dSceneItem> parseModel3dScene(Object? raw) {
  if (raw is! List) return const [];
  final scene = <Model3dSceneItem>[];
  double? number(Object? value) =>
      value is num ? PropsResolver.number(value) : null;
  for (final item in raw) {
    if (item is! Map) continue;
    final src = item['src'];
    if (src is! String || src.trim().isEmpty) continue;
    final position = parseModel3dPoint(item['position'] ?? const [0, 0, 0]);
    if (position == null) continue;
    final rotation = item['rotation'] ?? const {};
    if (rotation is! Map) continue;
    final yaw = number(rotation['yaw'] ?? 0);
    final pitch = number(rotation['pitch'] ?? 0);
    final roll = number(rotation['roll'] ?? 0);
    final scale = number(item['scale'] ?? 1);
    if (yaw == null ||
        pitch == null ||
        roll == null ||
        scale == null ||
        scale <= 0) {
      continue;
    }
    final rawSpin = item['spin'];
    ({String axis, double speed})? spin;
    if (rawSpin != null) {
      if (rawSpin is! Map || !const ['x', 'y', 'z'].contains(rawSpin['axis'])) {
        continue;
      }
      final speed = number(rawSpin['speed']);
      if (speed == null) continue;
      spin = (axis: rawSpin['axis'] as String, speed: speed);
    }
    scene.add(
      Model3dSceneItem(
        src: src,
        position: position,
        rotation: (yaw: yaw, pitch: pitch, roll: roll),
        scale: scale,
        clip: item['clip'] is String ? item['clip'] as String : null,
        spin: spin,
      ),
    );
  }
  return List.unmodifiable(scene);
}

Model3dLook parseModel3dLook(Map<String, Object?> props) {
  final lighting = props['lighting'] is Map
      ? props['lighting'] as Map
      : const {};
  final rawLight = lighting['light'];
  final shadow = props['shadow'];
  final shadowMap = shadow is Map ? shadow : const {};
  final shadowType = shadow is String ? shadow : shadowMap['type'];
  final environment = PropsResolver.number(lighting['environment']);
  final intensity = rawLight is Map
      ? PropsResolver.number(rawLight['intensity'])
      : null;
  final opacity = PropsResolver.number(shadowMap['opacity']);
  return Model3dLook(
    environment: environment != null && environment >= 0 ? environment : 1,
    environmentRotation:
        PropsResolver.number(lighting['environment_rotation']) ?? 0,
    light: rawLight is Map
        ? Model3dLight(
            yaw: PropsResolver.number(rawLight['yaw']) ?? 45,
            pitch: PropsResolver.number(rawLight['pitch']) ?? 45,
            intensity: intensity != null && intensity >= 0 ? intensity : 1,
            color:
                PropsResolver.color(rawLight['color']) ??
                const Color(0xFFFFFFFF),
          )
        : null,
    shadow: Model3dShadow(
      type: switch (shadowType) {
        'contact' => Model3dShadowType.contact,
        'cast' => Model3dShadowType.cast,
        _ => Model3dShadowType.none,
      },
      opacity: opacity != null && opacity >= 0 && opacity <= 1 ? opacity : 0.5,
    ),
    quality: switch (props['quality']) {
      'low' => Model3dQuality.low,
      'high' => Model3dQuality.high,
      _ => Model3dQuality.medium,
    },
    exposure: PropsResolver.number(props['exposure']) ?? 0,
  );
}

Map<String, Model3dStateEntry> parseModel3dStates(Object? raw) {
  if (raw is! Map) return const {};
  final states = <String, Model3dStateEntry>{};
  for (final MapEntry(:key, :value) in raw.entries) {
    if (key is! String || value is! Map) continue;
    final clip = PropsResolver.text(value['clip']);
    if (clip == null || clip.isEmpty) {
      EngineLog.warn('model state "$key" has no clip', tag: 'model_3d');
      continue;
    }
    states[key] = Model3dStateEntry(
      clip: clip,
      loop: PropsResolver.flag(value['loop']) ?? false,
      next: PropsResolver.text(value['next']),
    );
  }
  return states;
}

final class Model3dStateEntry {
  const Model3dStateEntry({
    required this.clip,
    required this.loop,
    required this.next,
  });

  final String clip;
  final bool loop;
  final String? next;
}
