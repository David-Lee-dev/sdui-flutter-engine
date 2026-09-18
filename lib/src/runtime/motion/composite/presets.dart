/// Expands named motion recipes into one or more independently hosted atoms.
final class MotionPresets {
  const MotionPresets._();

  static const Map<String, List<({String atom, Map<String, Object?> params})>>
  _table = {
    'fade_in': [(atom: 'fade', params: {})],
    'reveal_up': [
      (atom: 'reveal', params: {'direction': 'up'}),
    ],
    'reveal_down': [
      (atom: 'reveal', params: {'direction': 'down'}),
    ],
    'reveal_left': [
      (atom: 'reveal', params: {'direction': 'left'}),
    ],
    'reveal_right': [
      (atom: 'reveal', params: {'direction': 'right'}),
    ],
    'blur_in': [
      (atom: 'blur', params: {'begin': 8, 'end': 0}),
    ],
    'color_in': [
      (atom: 'saturate', params: {'begin': 0, 'end': 1}),
    ],
    'slide_up': [
      (
        atom: 'move',
        params: {
          'begin': [0, 24],
          'end': [0, 0],
        },
      ),
    ],
    'slide_down': [
      (
        atom: 'move',
        params: {
          'begin': [0, -24],
          'end': [0, 0],
        },
      ),
    ],
    'slide_left': [
      (
        atom: 'move',
        params: {
          'begin': [24, 0],
          'end': [0, 0],
        },
      ),
    ],
    'slide_right': [
      (
        atom: 'move',
        params: {
          'begin': [-24, 0],
          'end': [0, 0],
        },
      ),
    ],
    'drop': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [0, -40],
          'end': [0, 0],
          'curve': 'bounce_out',
          'duration': 500,
        },
      ),
    ],
    'raise': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [0, 40],
          'end': [0, 0],
          'curve': 'ease_out',
          'duration': 400,
        },
      ),
    ],
    'zoom_in': [
      (atom: 'scale', params: {'begin': 0.8, 'end': 1.0}),
    ],
    'rotate_in': [
      (atom: 'rotate', params: {'begin': -0.3, 'end': 0.0}),
    ],
    'flip_in': [
      (atom: 'rotate', params: {'axis': 'y', 'begin': 1.5708, 'end': 0.0}),
    ],
    'pop_in': [
      (
        atom: 'scale',
        params: {
          'begin': 0.0,
          'end': 1.0,
          'curve': 'elastic_out',
          'duration': 600,
        },
      ),
    ],
    'fade_slide_up': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [0, 24],
          'end': [0, 0],
        },
      ),
    ],
    'fade_slide_down': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [0, -24],
          'end': [0, 0],
        },
      ),
    ],
    'fade_slide_left': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [24, 0],
          'end': [0, 0],
        },
      ),
    ],
    'fade_slide_right': [
      (atom: 'fade', params: {}),
      (
        atom: 'move',
        params: {
          'begin': [-24, 0],
          'end': [0, 0],
        },
      ),
    ],
    'fade_scale': [
      (atom: 'fade', params: {}),
      (atom: 'scale', params: {'begin': 0.92, 'end': 1.0}),
    ],
    'flip_fade_in': [
      (atom: 'fade', params: {}),
      (atom: 'rotate', params: {'axis': 'y', 'begin': 1.2, 'end': 0.0}),
    ],
    'pulse': [
      (
        atom: 'scale',
        params: {
          'begin': 1.0,
          'end': 1.06,
          'curve': 'ease_in_out',
          'repeat': true,
          'reverse': true,
          'duration': 700,
        },
      ),
    ],
    'float': [
      (
        atom: 'move',
        params: {
          'begin': [0, 0],
          'end': [0, -8],
          'curve': 'ease_in_out',
          'repeat': true,
          'reverse': true,
          'duration': 1400,
        },
      ),
    ],
    'bounce': [
      (
        atom: 'move',
        params: {
          'begin': [0, 0],
          'end': [0, -14],
          'curve': 'ease_out',
          'repeat': true,
          'reverse': true,
          'duration': 500,
        },
      ),
    ],
    'blink': [
      (
        atom: 'fade',
        params: {
          'begin': 0.3,
          'end': 1.0,
          'repeat': true,
          'reverse': true,
          'duration': 700,
        },
      ),
    ],
    'shake': [
      (
        atom: 'move',
        params: {
          'begin': [-4, 0],
          'end': [4, 0],
          'repeat': true,
          'reverse': true,
          'duration': 70,
        },
      ),
    ],
    'wobble': [
      (
        atom: 'rotate',
        params: {
          'begin': -0.06,
          'end': 0.06,
          'repeat': true,
          'reverse': true,
          'duration': 120,
        },
      ),
    ],
    'swing': [
      (
        atom: 'rotate',
        params: {
          'begin': -0.12,
          'end': 0.12,
          'curve': 'ease_in_out',
          'repeat': true,
          'reverse': true,
          'duration': 700,
        },
      ),
    ],
    'spin': [
      (
        atom: 'rotate',
        params: {
          'begin': 0.0,
          'end': 6.2832,
          'curve': 'linear',
          'repeat': true,
          'reverse': false,
          'duration': 1200,
        },
      ),
    ],
    'tada': [
      (
        atom: 'scale',
        params: {
          'begin': 1.0,
          'end': 1.1,
          'curve': 'ease_in_out',
          'repeat': true,
          'reverse': true,
          'duration': 400,
        },
      ),
      (
        atom: 'rotate',
        params: {
          'begin': -0.05,
          'end': 0.05,
          'repeat': true,
          'reverse': true,
          'duration': 200,
        },
      ),
    ],
  };

  /// Every composite preset name (`_motion` accepts these next to atoms).
  static Set<String> names() => Set.unmodifiable(_table.keys);

  static List<({String type, Map<String, Object?> params})> expand(
    String type,
    Map<String, Object?> userParams,
  ) {
    final recipe = _table[type];
    if (recipe == null) return [(type: type, params: userParams)];
    return [
      for (final step in recipe)
        (type: step.atom, params: {...step.params, ...userParams}),
    ];
  }
}
