import 'dart:convert';
import 'dart:typed_data';

/// The length of every animation clip in a binary glTF (`.glb`), by name.
///
/// glTF requires each animation sampler's input accessor to carry its `max`,
/// so a clip's length is the latest of those — read from the JSON chunk
/// alone, without decoding any buffer. Unnamed clips are `animation_<index>`,
/// as three.js names them. Returns an empty map for bytes that are not a
/// readable `.glb`.
Map<String, Duration> gltfClipDurations(Uint8List glb) {
  try {
    final data = ByteData.sublistView(glb);
    // Header: magic "glTF", version, length; then the JSON chunk.
    if (glb.length < 20 || data.getUint32(0, Endian.little) != 0x46546C67) {
      return const {};
    }
    final jsonLength = data.getUint32(12, Endian.little);
    if (data.getUint32(16, Endian.little) != 0x4E4F534A) return const {};
    final json = jsonDecode(utf8.decode(glb.sublist(20, 20 + jsonLength)));
    if (json is! Map) return const {};
    final accessors = json['accessors'];
    final animations = json['animations'];
    if (accessors is! List || animations is! List) return const {};
    final durations = <String, Duration>{};
    for (var i = 0; i < animations.length; i++) {
      final animation = animations[i];
      if (animation is! Map) continue;
      var seconds = 0.0;
      for (final sampler in animation['samplers'] as List? ?? const []) {
        final input = sampler is Map ? sampler['input'] : null;
        if (input is! int || input < 0 || input >= accessors.length) continue;
        final accessor = accessors[input];
        final max = accessor is Map ? accessor['max'] : null;
        if (max is List && max.isNotEmpty && max.first is num) {
          final end = (max.first as num).toDouble();
          if (end > seconds) seconds = end;
        }
      }
      final name = animation['name'];
      durations[name is String && name.isNotEmpty
          ? name
          : 'animation_$i'] = Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      );
    }
    return durations;
  } on Object {
    return const {};
  }
}
