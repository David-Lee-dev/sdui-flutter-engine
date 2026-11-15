import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_model_filament/sdui_model_filament.dart';

import 'showcase.dart';
// Bench only: Filament's own render count.
// ignore: implementation_imports
import 'package:thermion_flutter/src/platform/src/frame_scheduler.dart';

/// Sample models bundled under `assets/` with their clips.
const _models = {
  'Fox': ['Survey', 'Walk', 'Run'],
  'RobotExpressive': ['Idle', 'Wave', 'Dance', 'Yes', 'Walking'],
  'Xbot': ['idle', 'walk', 'run', 'agree'],
  'XbotWalk': ['walk'],
  'AnimatedMorphCube': ['Square'],
};

/// What the model does while measured.
enum Mode { still, play, rotate, ticker, outfit }

/// `--dart-define=BENCH_AUTO=true` steps through the [_suite] scenarios on its own,
/// [_step] per scenario, so a run needs no taps.
const _auto = bool.fromEnvironment('BENCH_AUTO');
const _step = Duration(
  seconds: int.fromEnvironment("BENCH_STEP", defaultValue: 25),
);

/// `--dart-define=BENCH_SUITE=<name>` picks the scenario list ([_suites]).
const _suite = String.fromEnvironment('BENCH_SUITE', defaultValue: 'base');

/// One measured scenario: model, motion, view count and extra template props.
typedef Scenario = (String, Mode, int, Map<String, Object?>);

const _contact = {'shadow': 'contact'};
const _high = {
  'quality': 'high',
  'shadow': 'cast',
  'lighting': {
    'light': {'yaw': 40, 'pitch': 50, 'intensity': 1},
  },
};

const _planet = {
  'scene': [
    {
      'src': 'assets/Planet.glb',
      'position': [0, -2, 0],
      'spin': {'axis': 'x', 'speed': 25},
    },
  ],
  'camera': {'zoom': 0.6, 'pitch': 15},
};

const _motion = {
  'morphs': {'Surprised': 1},
  'blink': {'target': 'Angry', 'every': 1500, 'duration': 300},
  'look_at': {'bone': 'Head', 'target': 'camera', 'max_yaw': 70},
  'layer': {'clip': 'Wave', 'loop': true},
};

const Map<String, List<Scenario>> _suites = {
  'base': [
    ('none', Mode.still, 1, {}),
    ('Fox', Mode.play, 1, {}),
    ('RobotExpressive', Mode.play, 1, {}),
    ('RobotExpressive', Mode.rotate, 1, {}),
    ('Xbot', Mode.play, 1, {}),
    ('Xbot', Mode.play, 4, {}),
  ],
  'probe': [
    ('Fox', Mode.play, 1, {}),
    ('Fox', Mode.ticker, 1, {}),
    ('Fox', Mode.rotate, 1, {}),
  ],
  'vis': [
    ('RobotExpressive', Mode.still, 1, {}),
    ('RobotExpressive', Mode.play, 1, {}),
    ('Xbot', Mode.still, 1, {}),
    (
      'AnimatedMorphCube',
      Mode.still,
      1,
      {
        'camera': {'zoom': 0.5},
      },
    ),
  ],
  'scene': [
    ('RobotExpressive', Mode.still, 1, {}),
    (
      'Xbot',
      Mode.still,
      1,
      {
        'camera': {'target': 'mixamorig:Head', 'zoom': 3},
      },
    ),
    ('XbotWalk', Mode.play, 1, _planet),
    ('XbotWalk', Mode.rotate, 1, {..._planet, ..._contact}),
  ],
  'outfit': [
    ('RobotExpressive', Mode.outfit, 1, {}),
    ('RobotExpressive', Mode.outfit, 1, {'outfit_transition': 'drop'}),
  ],
  'motion': [
    ('RobotExpressive', Mode.play, 1, {}),
    ('RobotExpressive', Mode.play, 1, _motion),
    ('RobotExpressive', Mode.rotate, 1, _motion),
  ],
  'look': [
    ('RobotExpressive', Mode.play, 1, {}),
    ('RobotExpressive', Mode.play, 1, _contact),
    ('RobotExpressive', Mode.play, 1, {'quality': 'low'}),
    ('RobotExpressive', Mode.play, 1, _high),
    ('Xbot', Mode.play, 1, {}),
    ('Xbot', Mode.play, 1, _contact),
    ('Xbot', Mode.play, 1, _high),
    ('Xbot', Mode.rotate, 1, _high),
  ],
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Engine.initialize(
    networkClient: _NoNetwork(),
    imageSource: const AssetImageSource(),
    videoSource: const AssetVideoSource(),
    model3dSource: FilamentModel3dSource(
      client: http.Client(),
      baseUrl: Uri.parse('https://invalid.local'),
      diskCache: false,
      debugOverlay: _auto,
    ),
    appStorage: _MemoryStorage(),
    secureStorage: _MemorySecureStorage(),
  );
  _FrameLog.start();
  runApp(MaterialApp(home: _auto ? const BenchPage() : const ShowcasePage()));
}

class BenchPage extends StatefulWidget {
  const BenchPage({super.key});

  @override
  State<BenchPage> createState() => _BenchPageState();
}

class _BenchPageState extends State<BenchPage> {
  String _model = 'RobotExpressive';
  Mode _mode = Mode.play;
  int _count = 1;
  Map<String, Object?> _props = const {};

  void _set(VoidCallback change) {
    setState(change);
    _FrameLog.scenario = '$_model ${_mode.name} x$_count ${_label(_props)}';
  }

  @override
  void initState() {
    super.initState();
    _FrameLog.scenario = '$_model ${_mode.name} x$_count';
    if (_auto) unawaited(_runSequence());
  }

  Future<void> _runSequence() async {
    for (final (model, mode, count, props) in _suites[_suite]!) {
      if (!mounted) return;
      _set(() {
        _model = model;
        _mode = mode;
        _count = count;
        _props = props;
      });
      await Future<void>.delayed(_step);
    }
    debugPrint('[bench] done');
  }

  @override
  Widget build(BuildContext context) {
    final key = ValueKey('$_model/$_mode/$_count/${_label(_props)}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('model_3d bench'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Wrap(
            spacing: 6,
            children: [
              for (final m in _models.keys)
                ChoiceChip(
                  label: Text(m),
                  selected: m == _model,
                  onSelected: (_) => _set(() => _model = m),
                ),
              for (final m in Mode.values)
                ChoiceChip(
                  label: Text(m.name),
                  selected: m == _mode,
                  onSelected: (_) => _set(() => _mode = m),
                ),
              for (final n in [1, 4])
                ChoiceChip(
                  label: Text('x$n'),
                  selected: n == _count,
                  onSelected: (_) => _set(() => _count = n),
                ),
            ],
          ),
        ),
      ),
      body: _count == 1
          ? _view(key)
          : GridView.count(
              crossAxisCount: 2,
              children: [
                for (var i = 0; i < _count; i++) _view(ValueKey('$key#$i')),
              ],
            ),
    );
  }

  Widget _view(Key key) {
    if (_model == 'none') return const SizedBox.expand();
    if (_mode == Mode.outfit) {
      return _OutfitCycler(
        key: key,
        template: {..._template(_model, Mode.play), ..._props},
      );
    }
    final runner = EngineRunner(
      key: key,
      template: {..._template(_model, _mode), ..._props},
    );
    if (_mode != Mode.ticker) return runner;
    return Stack(children: [runner, const _IdleTicker()]);
  }
}

String _label(Map<String, Object?> props) => props.isEmpty
    ? 'default'
    : props.entries
          .map(
            (e) => e.key == 'shadow' || e.key == 'quality'
                ? '${e.key}=${e.value}'
                : e.key,
          )
          .join('+');

/// A `model_3d` template: `play` and `rotate` chain every clip forever.
Map<String, Object?> _template(String model, Mode mode) {
  final clips = _models[model]!;
  return {
    '_type': 'model_3d',
    'src': 'assets/${model == 'XbotWalk' ? 'Xbot' : model}.glb',
    'interactive': true,
    if (mode != Mode.still) ...{
      'state': clips.first,
      'states': {
        for (var i = 0; i < clips.length; i++)
          clips[i]: {'clip': clips[i], 'next': clips[(i + 1) % clips.length]},
      },
    },
    if (mode == Mode.rotate) 'auto_rotate': 30,
  };
}

const _outfits = [
  {
    'colors': {'Main': '#3B82F6'},
    'attach': {'Head': 'assets/HatRobot.glb'},
  },
  {
    'hide': ['Arm.L', 'Arm.R'],
    'colors': {'Main': '#F59E0B'},
  },
];

/// Feeds a new `outfit` into the template's root data every 2 seconds, so
/// swaps animate without recompiling or reloading the model.
class _OutfitCycler extends StatefulWidget {
  const _OutfitCycler({super.key, required this.template});

  final Map<String, Object?> template;

  @override
  State<_OutfitCycler> createState() => _OutfitCyclerState();
}

class _OutfitCyclerState extends State<_OutfitCycler> {
  int _i = 0;
  late final Timer _timer = Timer.periodic(
    const Duration(seconds: 2),
    (_) => setState(() => _i++),
  );

  late final Map<String, Object?> _template = {
    ...widget.template,
    'outfit': {
      'show': r'${o.show}',
      'hide': r'${o.hide}',
      'colors': r'${o.colors}',
      'attach': r'${o.attach}',
      'transition': widget.template['outfit_transition'] ?? 'pop',
      'transition_duration': 500,
    },
  }..remove('outfit_transition');

  @override
  void initState() {
    super.initState();
    _timer;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = _outfits[_i % _outfits.length];
    return EngineRunner(
      template: _template,
      rootData: {
        'o': {
          'show': o['show'] ?? const <String>[],
          'hide': o['hide'] ?? const <String>[],
          'colors': o['colors'] ?? const <String, String>{},
          'attach': o['attach'] ?? const <String, String>{},
        },
      },
    );
  }
}

/// Requests a Flutter frame on every vsync and changes nothing, like a camera
/// rig ticking: isolates the cost of display-rate Flutter frames.
class _IdleTicker extends StatefulWidget {
  const _IdleTicker();

  @override
  State<_IdleTicker> createState() => _IdleTickerState();
}

class _IdleTickerState extends State<_IdleTicker>
    with SingleTickerProviderStateMixin {
  late final _ticker = createTicker((_) {});

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Logs Flutter frame times and app RSS every 5 seconds, tagged with the
/// scenario on screen, so runs can be compared from `flutter logs`.
abstract final class _FrameLog {
  static String scenario = '';
  static final _build = <int>[];
  static final _raster = <int>[];
  static int _renders = 0;

  static void start() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        _build.add(t.buildDuration.inMicroseconds);
        _raster.add(t.rasterDuration.inMicroseconds);
      }
    });
    Timer.periodic(const Duration(seconds: 5), (_) => _flush());
  }

  static void _flush() {
    final rss = (ProcessInfo.currentRss / (1 << 20)).round();
    final frames = _build.length;
    final renders = FrameScheduler.instance.dispatchedFrameCount;
    final filament = renders - _renders;
    _renders = renders;
    String p(List<int> v, double q) {
      if (v.isEmpty) return '-';
      final s = [...v]..sort();
      return (s[((s.length - 1) * q).round()] / 1000).toStringAsFixed(1);
    }

    debugPrint(
      '[bench] $scenario frames=$frames/5s filament=$filament/5s '
      'build p50=${p(_build, .5)} p90=${p(_build, .9)} '
      'raster p50=${p(_raster, .5)} p90=${p(_raster, .9)} ms rss=${rss}MB',
    );
    _build.clear();
    _raster.clear();
  }
}

class _NoNetwork implements NetworkClient {
  @override
  Future<NetworkResult> send(NetworkRequest request) async =>
      const NetworkResult(errorCode: 'OFFLINE');
}

class _MemoryStorage implements AppStorage {
  final _values = <String, Object?>{};

  @override
  Object? get(String key) => _values[key];

  @override
  Future<void> set(String key, Object? value) async => _values[key] = value;
}

class _MemorySecureStorage implements SecureStorage {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
