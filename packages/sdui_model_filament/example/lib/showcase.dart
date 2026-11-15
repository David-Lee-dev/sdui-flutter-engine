import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

/// Manual check of every model_3d feature: one template, all props bound to
/// root data, so a chip changes a value without recompiling or reloading.
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

const _robotClips = ['Idle', 'Walking', 'Dance', 'Wave', 'Yes', 'Running'];
const _xbotClips = ['idle', 'walk', 'run', 'agree'];

const _template = {
  '_type': 'model_3d',
  'src': r'${src}',
  'interactive': true,
  'controls': r'${controls}',
  'state': r'${state}',
  'states': r'${states}',
  'camera': r'${camera}',
  'auto_rotate': r'${auto_rotate}',
  'lighting': r'${lighting}',
  'shadow': r'${shadow}',
  'quality': r'${quality}',
  'scene': r'${scene}',
  'outfit': r'${outfit}',
  'morphs': r'${morphs}',
  'blink': r'${blink}',
  'look_at': r'${look_at}',
  'layer': r'${layer}',
};

class _ShowcasePageState extends State<ShowcasePage> {
  bool robot = true;
  String clip = 'Idle';
  String shadow = 'contact';
  String quality = 'medium';
  bool light = false;
  bool rotate = false;
  bool planet = false;
  bool face = false;
  int outfit = 0;
  String transition = 'pop';
  String morph = 'none';
  bool blink = false;
  String lookAt = 'off';
  bool wave = false;

  Map<String, Object?> get _data {
    final clips = robot ? _robotClips : _xbotClips;
    final current = clips.contains(clip) ? clip : clips.first;
    return {
      'src': robot ? 'assets/RobotExpressive.glb' : 'assets/Xbot.glb',
      'controls': {
        'rotate': 'free',
        'min_zoom': 0.4,
        'max_zoom': 4,
        'pan': true,
      },
      'state': current,
      'states': {
        for (final c in clips) c: {'clip': c, 'loop': true},
      },
      'camera': {
        'zoom': planet ? 0.6 : (face ? 3 : 1),
        'pitch': planet ? 15 : 0,
        'target': face ? (robot ? 'Head' : 'mixamorig:Head') : null,
        'duration': 600,
      },
      'auto_rotate': rotate ? 30 : 0,
      'lighting': light
          ? {
              'light': {'yaw': 40, 'pitch': 50, 'intensity': 1},
            }
          : <String, Object?>{},
      'shadow': shadow,
      'quality': quality,
      'scene': planet
          ? [
              {
                'src': 'assets/Planet.glb',
                'position': [0, -2, 0],
                'spin': {'axis': 'x', 'speed': 25},
              },
            ]
          : <Object?>[],
      'outfit': robot ? _outfits[outfit] : <String, Object?>{},
      'morphs': robot && morph != 'none' ? {morph: 1} : <String, Object?>{},
      'blink': robot && blink
          ? {'target': 'Surprised', 'every': 2500, 'duration': 250}
          : false,
      'look_at': lookAt == 'off'
          ? null
          : {
              'bone': robot ? 'Head' : 'mixamorig:Head',
              'target': lookAt,
              'max_yaw': 70,
              'max_pitch': 35,
              'duration': 300,
            },
      'layer': wave && robot ? {'clip': 'Wave', 'loop': true} : null,
    };
  }

  Map<String, Object?> get _outfitsTransition => {'transition': transition};

  List<Map<String, Object?>> get _outfits => [
    {..._outfitsTransition},
    {
      'colors': {'Main': '#3B82F6'},
      'attach': {'Head': 'assets/HatRobot.glb'},
      ..._outfitsTransition,
      'transition_duration': 500,
    },
    {
      'hide': ['Arm.L', 'Arm.R'],
      'colors': {'Main': '#F59E0B'},
      ..._outfitsTransition,
      'transition_duration': 500,
    },
  ];

  Widget _chips<T>(
    String label,
    List<T> values,
    T selected,
    void Function(T) on, {
    String Function(T)? name,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          for (final v in values)
            ChoiceChip(
              visualDensity: VisualDensity.compact,
              label: Text(name?.call(v) ?? '$v'),
              selected: v == selected,
              onSelected: (_) => setState(() => on(v)),
            ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, void Function(bool) on) =>
      FilterChip(
        visualDensity: VisualDensity.compact,
        label: Text(label),
        selected: value,
        onSelected: (v) => setState(() => on(v)),
      );

  @override
  Widget build(BuildContext context) {
    final clips = robot ? _robotClips : _xbotClips;
    return Scaffold(
      appBar: AppBar(title: const Text('model_3d showcase')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: EngineRunner(template: _template, rootData: _data),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chips(
                  '모델',
                  [true, false],
                  robot,
                  (v) => robot = v,
                  name: (v) => v ? 'Robot' : 'Xbot',
                ),
                _chips(
                  '클립',
                  clips,
                  clips.contains(clip) ? clip : clips.first,
                  (v) => clip = v,
                ),
                _chips(
                  '그림자',
                  ['none', 'contact', 'cast'],
                  shadow,
                  (v) => shadow = v,
                ),
                _chips(
                  '화질',
                  ['low', 'medium', 'high'],
                  quality,
                  (v) => quality = v,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _toggle('방향광', light, (v) => light = v),
                      _toggle('자동 회전', rotate, (v) => rotate = v),
                      _toggle('행성', planet, (v) => planet = v),
                      _toggle('얼굴 클로즈업', face, (v) => face = v),
                    ],
                  ),
                ),
                if (robot) ...[
                  _chips(
                    '옷',
                    [0, 1, 2],
                    outfit,
                    (v) => outfit = v,
                    name: (v) => ['기본', '파랑+모자', '주황+팔 숨김'][v],
                  ),
                  _chips(
                    '전환',
                    ['cut', 'pop', 'drop', 'dissolve'],
                    transition,
                    (v) => transition = v,
                  ),
                  _chips(
                    '표정',
                    ['none', 'Angry', 'Surprised', 'Sad'],
                    morph,
                    (v) => morph = v,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 6,
                      children: [
                        _toggle('깜박임', blink, (v) => blink = v),
                        _toggle('손 흔들기 겹치기', wave, (v) => wave = v),
                      ],
                    ),
                  ),
                ],
                _chips(
                  '시선',
                  ['off', 'camera', 'pointer'],
                  lookAt,
                  (v) => lookAt = v,
                ),
                const SizedBox(height: 8),
                const Text(
                  '드래그: 회전 · 핀치: 확대 · 두 손가락 드래그: 이동',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
