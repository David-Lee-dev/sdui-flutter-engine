import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/media/shader_registry.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/util/props_resolver.dart';

/// Untrusted-input property checks for spring and tween morphs, `_motion`
/// params, math functions, and `shape` props: 1000 fixed-seed rounds of
/// hostile values, zero uncaught exceptions (and, for morphs and motions,
/// zero error reports).
const _rounds = 1000;

const _hostileNumbers = <num>[
  1e308,
  -1e308,
  1e-308,
  5e-324,
  -1,
  -0.0,
  0,
  1,
  10,
  16385,
  -16385,
];

final _hostile = <Object?>[
  ..._hostileNumbers,
  double.nan,
  double.infinity,
  double.negativeInfinity,
  'x',
  '',
  '1e308',
  null,
  true,
  <Object?>[],
  <Object?>[double.nan],
  <Object?>[1, 2, 3],
  <Object?>[double.infinity, -1],
  <String, Object?>{},
  <String, Object?>{'x': 1},
];

/// JSON-safe hostile values (rootData must be JSON-encodable): non-finite
/// numbers are produced inside the template instead.
final _jsonHostile = _hostile.where(_jsonSafe).toList();

bool _jsonSafe(Object? v) => switch (v) {
  final double d => d.isFinite,
  final List<Object?> l => l.every(_jsonSafe),
  _ => true,
};

void main() {
  final random = math.Random(20261030);
  T pick<T>(List<T> from) => from[random.nextInt(from.length)];

  setUp(() {
    ShaderRegistry.reset();
    EngineLog.configure(output: (_) {});
  });
  tearDown(() {
    ShaderRegistry.reset();
    EngineLog.configure(output: debugPrint);
  });

  test('함수와 정렬 해석은 어떤 입력에도 던지지 않고 유한수나 null만 낸다', () {
    for (var i = 0; i < _rounds; i++) {
      for (final name in ['sin', 'cos', 'pow', 'remap', 'smoothstep', 'sign']) {
        final args = [
          for (var n = random.nextInt(7); n > 0; n--) pick(_hostile),
        ];
        final result = FunctionRegistry.resolve(name)!(args);
        expect(
          result == null || (result is num && result.isFinite),
          isTrue,
          reason: '$name$args -> $result',
        );
      }
      final align = PropsResolver.alignment([pick(_hostile), pick(_hostile)]);
      if (align != null) {
        expect(align.x.abs() <= 4 && align.y.abs() <= 4, isTrue);
      }
    }
  });

  testWidgets('spring 목표와 shape props에 적대적 값을 1000번 넣어도 예외가 없다', (
    tester,
  ) async {
    final data = ValueNotifier<Map<String, Object?>>(const {});
    addTearDown(data.dispose);
    Map<String, Object?> round() => {
      'k': random.nextInt(4),
      'a': pick(_hostileNumbers),
      'b': pick(_hostileNumbers),
      'c': pick(_hostileNumbers),
      'kind': pick(<Object?>['circle', 'capsule', 'rrect', 'star', null, 3]),
      'r': pick(_jsonHostile),
      'o': pick(_jsonHostile),
      'i': pick(_jsonHostile),
      'w': pick(_jsonHostile),
      'al': pick(_jsonHostile),
      'sm': pick(_jsonHostile),
      'rw': pick(_jsonHostile),
      'shapes': pick(<Object?>[null, <Object?>[], 'x', 1]),
    };
    data.value = round();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<Map<String, Object?>>(
            valueListenable: data,
            builder: (context, root, _) => EngineRunner(
              rootData: root,
              template: const {
                '_type': 'sizedbox',
                'width': 200,
                'height': 100,
                '_child': {
                  '_type': 'stack',
                  '_morph': {
                    // k picks ±Infinity (a·b overflow), NaN (∞ - ∞), an
                    // evaluation error (c / 0) or a plain hostile number.
                    '_to':
                        r'${k == 0 ? a * b : (k == 1 ? a * b - a * b : '
                        r'(k == 2 ? c / b : c))}',
                    '_as': 'm',
                    '_spring': 'spatial_fast',
                  },
                  '_children': [
                    {
                      '_type': 'positioned_fill',
                      '_child': {
                        '_type': 'shape',
                        'shapes': [
                          {
                            'kind': r'${kind}',
                            'radius': r'${r}',
                            'offset': r'${o}',
                            'inset': r'${i}',
                            'width': r'${w}',
                            'height': r'${w}',
                            'align': r'${al}',
                          },
                          {
                            'kind': 'circle',
                            'radius': r'${m}',
                            'offset': r'${[m, m]}',
                          },
                        ],
                        'smooth': r'${sm}',
                        'rim': {'color': '#FFFFFFFF', 'width': r'${rw}'},
                      },
                    },
                    {'_type': 'shape', 'shapes': r'${shapes}'},
                    {'_type': 'text', 'value': r'${m}'},
                  ],
                },
              },
            ),
          ),
        ),
      ),
    );

    // First half paints the Path fallback, second half the shader.
    for (var i = 0; i < _rounds; i++) {
      if (i == _rounds ~/ 2) {
        await tester.runAsync(ShaderRegistry.warmUp);
        expect(ShaderRegistry.available, isTrue);
      }
      data.value = round();
      await tester.pump(Duration(milliseconds: random.nextInt(40)));
      expect(tester.takeException(), isNull, reason: 'round $i ${data.value}');
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('tween morph와 _motion 인자에 적대적 값을 1000번 넣어도 예외·보고가 없다', (
    tester,
  ) async {
    final errors = <SduiError>[];
    EngineErrors.observer = _Capture(errors);
    MotionFactory.register(const _FlakyMotion());
    // boom(x): 0이면 FormatException 밖의 오류를 던진다.
    FunctionRegistry.register(
      'boom',
      (args) => args.first == 0 ? throw ArgumentError('boom') : args.first,
    );
    addTearDown(() {
      EngineErrors.reset();
      MotionFactory.reset();
      FunctionRegistry.reset();
    });

    final data = ValueNotifier<Map<String, Object?>>(const {});
    addTearDown(data.dispose);
    Map<String, Object?> round() => {
      'k': random.nextInt(5),
      'a': pick(_hostileNumbers),
      'b': pick(_hostileNumbers),
      'c': pick(_hostileNumbers),
      for (final key in [
        'f',
        'g',
        'd',
        'e',
        'cv',
        'rp',
        'rv',
        'bg',
        'en',
        'al',
        'ax',
        'dr',
        'x',
      ])
        key: pick(_jsonHostile),
    };
    Map<String, Object?> layer(String type) => {
      'type': type,
      'duration': r'${d}',
      'delay': r'${e}',
      'curve': r'${cv}',
      'repeat': r'${rp}',
      'reverse': r'${rv}',
      'trigger': r'${g}',
      'begin': r'${bg}',
      'end': r'${en}',
      'align': r'${al}',
      'axis': r'${ax}',
      'direction': r'${dr}',
      'blend': r'${x}',
      'base': r'${x}',
      'highlight': r'${x}',
    };
    data.value = round();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<Map<String, Object?>>(
            valueListenable: data,
            builder: (context, root, _) => EngineRunner(
              rootData: root,
              template: {
                '_type': 'text',
                'value': r'${m}',
                '_morph': {
                  // k picks ±Infinity, NaN, a FormatException (c / 0), a
                  // non-Format error (boom(0)) or a plain hostile number.
                  '_to':
                      r'${k == 0 ? a * b : (k == 1 ? a * b - a * b : '
                      r'(k == 2 ? c / b : (k == 3 ? boom(c) : c)))}',
                  '_from': r'${f}',
                  '_trigger': r'${g}',
                  '_as': 'm',
                  '_duration': 30,
                  '_curve': 'linear',
                },
                '_motion': [
                  for (final type in [
                    'fade',
                    'move',
                    'scale',
                    'rotate',
                    'reveal',
                    'tint',
                    'blur',
                    'shimmer',
                    'saturate',
                    'pop_in',
                    'shake',
                    'flaky',
                  ])
                    layer(type),
                  {'type': 'fade_in', 'duration': r'${boom(k)}'},
                  {'type': 'move', 'begin': r'${[m, m]}', 'end': r'${m}'},
                ],
              },
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < _rounds; i++) {
      data.value = round();
      await tester.pump(Duration(milliseconds: random.nextInt(40)));
      expect(tester.takeException(), isNull, reason: 'round $i ${data.value}');
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(errors, isEmpty);
  });

  testWidgets('0.9.0 인자(곡선·repeat·_velocity·offset·pressed_as·새 함수)에 '
      '적대적 값을 1000번 넣어도 예외·보고가 없다', (tester) async {
    final errors = <SduiError>[];
    EngineErrors.observer = _Capture(errors);
    addTearDown(EngineErrors.reset);

    final curves = <Object?>[
      ..._jsonHostile,
      'emphasized',
      'standard_accelerate',
      'spatial_fast',
      'effect_default',
      'bogus',
    ];
    Object? curve() => random.nextInt(3) == 0
        ? [for (var i = 0; i < 4; i++) pick(_hostileNumbers)]
        : pick(curves);
    final repeats = <Object?>[..._jsonHostile, 1, 2, 1000, 1001, 2.5];

    final data = ValueNotifier<Map<String, Object?>>(const {});
    final reduce = ValueNotifier<bool>(false);
    addTearDown(data.dispose);
    addTearDown(reduce.dispose);
    Map<String, Object?> round() => {
      'k': random.nextInt(4),
      'a': pick(_hostileNumbers),
      'b': pick(_hostileNumbers),
      'cv': curve(),
      'rp': pick(repeats),
      'rd': pick(_jsonHostile),
      'd': pick(_jsonHostile),
      'rv': pick(_jsonHostile),
      'o': pick(_jsonHostile),
      'x': pick(_jsonHostile),
      'y': pick(_jsonHostile),
      'z': pick(_jsonHostile),
    };
    Map<String, Object?> layer(String type) => {
      'type': type,
      'curve': r'${cv}',
      'repeat': r'${rp}',
      'repeat_delay': r'${rd}',
      'duration': r'${d}',
      'reverse': r'${rv}',
    };
    // k picks ±Infinity (a·b overflow), NaN (∞ - ∞) or a plain number.
    const target = r'${k == 0 ? a * b : (k == 1 ? a * b - a * b : a)}';
    data.value = round();

    await tester.pumpWidget(
      ValueListenableBuilder<bool>(
        valueListenable: reduce,
        builder: (context, reduced, _) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: ValueListenableBuilder<Map<String, Object?>>(
              valueListenable: data,
              builder: (context, root, _) => EngineRunner(
                rootData: root,
                template: {
                  '_type': 'column',
                  '_scope': {
                    '_state': {'n': 0},
                    '_action': {
                      'inc': {'_type': 'set', 'n': r'${n + 1}'},
                    },
                  },
                  '_children': [
                    {
                      '_type': 'sizedbox',
                      'width': 200,
                      'height': 120,
                      '_child': {
                        '_type': 'stack',
                        '_children': [
                          {
                            '_type': 'positioned',
                            'left': 0,
                            'top': 0,
                            '_motion': [
                              for (final t in [
                                'fade',
                                'move',
                                'shimmer',
                                'pulse',
                              ])
                                layer(t),
                            ],
                            '_on': {
                              'tap': {'do': 'inc', 'pressed_as': 'down'},
                            },
                            '_morph': {
                              '_to': target,
                              '_as': 'm',
                              '_velocity': 'mv',
                              '_spring': 'spatial_fast',
                            },
                            '_child': {
                              '_type': 'container',
                              'width': 100,
                              'height': 60,
                              'transform': {'offset': r'${o}'},
                              'color': r'${down ? "#FF000000" : "#FFFFFFFF"}',
                              '_child': {
                                '_type': 'text',
                                'value':
                                    r'${m}|${mv}|${smoothstep(x, y, z)}'
                                    r'|${sign(x)}|${sign(a * b)}',
                              },
                            },
                          },
                        ],
                      },
                    },
                    {
                      '_type': 'row',
                      '_children': [
                        {
                          '_type': 'expanded',
                          '_motion': layer('fade'),
                          '_morph': {
                            '_to': target,
                            '_as': 't',
                            '_velocity': 'tv',
                            '_curve': 'spatial_default',
                            '_repeat': true,
                            '_reverse': true,
                          },
                          '_child': {
                            '_type': 'transform',
                            'offset': r'${[t, tv]}',
                            '_child': {'_type': 'text', 'value': r'${tv}'},
                          },
                        },
                        {'_type': 'spacer', '_motion': layer('scale')},
                      ],
                    },
                  ],
                },
              ),
            ),
          ),
        ),
      ),
    );

    final button = tester.getCenter(find.byType(Positioned).first);
    for (var i = 0; i < _rounds; i++) {
      data.value = round();
      if (random.nextInt(10) == 0) reduce.value = !reduce.value;
      if (random.nextInt(8) == 0) {
        final gesture = await tester.startGesture(button);
        await tester.pump(Duration(milliseconds: random.nextInt(40)));
        await (random.nextBool() ? gesture.up() : gesture.cancel());
      }
      await tester.pump(Duration(milliseconds: random.nextInt(40)));
      expect(tester.takeException(), isNull, reason: 'round $i ${data.value}');
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(errors, isEmpty);
  });

  testWidgets('0.9.0 shape v2·semantics·layout_builder 인자에 적대적 값을 '
      '1000번 넣어도 예외·보고가 없다', (tester) async {
    final errors = <SduiError>[];
    EngineErrors.observer = _Capture(errors);
    addTearDown(EngineErrors.reset);

    final ops = <Object?>['union', 'subtract', 'intersect', 'bogus', null, 3];
    final colors = <Object?>[..._jsonHostile, '#FFFFFFFF', '#00000000'];
    Object? gradient() => pick(<Object?>[
      ..._jsonHostile,
      {
        'colors': [pick(colors), pick(colors), pick(colors)],
        'stops': [pick(_jsonHostile), pick(_jsonHostile)],
        'type': pick(<Object?>['linear', 'radial', 'sweep', 'x', null]),
      },
    ]);
    final data = ValueNotifier<Map<String, Object?>>(const {});
    final width = ValueNotifier<double>(240);
    addTearDown(data.dispose);
    addTearDown(width.dispose);
    Map<String, Object?> round() => {
      'op': pick(ops),
      'at': pick(_jsonHostile),
      'ism': pick(_jsonHostile),
      'sm': pick(_jsonHostile),
      'fill': random.nextBool() ? gradient() : pick(colors),
      'rg': gradient(),
      'rw': pick(_jsonHostile),
      'sh': pick(<Object?>[
        ..._jsonHostile,
        {
          'color': pick(colors),
          'blur': pick(_jsonHostile),
          'offset': pick(_jsonHostile),
        },
      ]),
      'bd': pick(_jsonHostile),
      'label': pick(<Object?>[..._jsonHostile, 'Home']),
      'button': pick(_jsonHostile),
      'selected': pick(_jsonHostile),
      'hidden': pick(_jsonHostile),
      'a': pick(_hostileNumbers),
    };
    data.value = round();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<double>(
            valueListenable: width,
            builder: (context, w, _) => Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: w,
                child: ValueListenableBuilder<Map<String, Object?>>(
                  valueListenable: data,
                  builder: (context, root, _) => EngineRunner(
                    rootData: root,
                    template: const {
                      '_type': 'column',
                      '_children': [
                        {
                          '_type': 'sizedbox',
                          'height': 100,
                          '_child': {
                            '_type': 'shape',
                            'shapes': [
                              {
                                'kind': 'capsule',
                                'inset': [0, 30],
                              },
                              {
                                'kind': 'circle',
                                'op': r'${op}',
                                'at': r'${at}',
                                'smooth': r'${ism}',
                                'radius': 20,
                              },
                              {
                                'kind': 'circle',
                                'at': [0.2, 0.5],
                                'radius': 10,
                                'op': 'intersect',
                              },
                            ],
                            'smooth': r'${sm}',
                            'fill': r'${fill}',
                            'rim': {'gradient': r'${rg}', 'width': r'${rw}'},
                            'shadow': r'${sh}',
                            'backdrop': {'blur': r'${bd}'},
                          },
                        },
                        {
                          '_type': 'semantics',
                          'label': r'${label}',
                          'button': r'${button}',
                          'selected': r'${selected}',
                          'hidden': r'${hidden}',
                          '_child': {'_type': 'text', 'value': 'tab'},
                        },
                        {
                          '_type': 'sizedbox',
                          'height': 40,
                          '_child': {
                            '_type': 'layout_builder',
                            '_provides': ['max_width', 'max_height'],
                            '_child': {
                              '_type': 'sizedbox',
                              'width':
                                  r'${max_width == null ? 1 : max_width / 2}',
                              '_child': {
                                '_type': 'text',
                                'value': r'${max_width}|${max_height}|${a}',
                              },
                            },
                          },
                        },
                      ],
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // First half paints the Path fallback, second half the shader.
    for (var i = 0; i < _rounds; i++) {
      if (i == _rounds ~/ 2) {
        await tester.runAsync(ShaderRegistry.warmUp);
        expect(ShaderRegistry.available, isTrue);
      }
      data.value = round();
      if (random.nextInt(10) == 0) width.value = 120.0 + random.nextInt(300);
      await tester.pump(Duration(milliseconds: random.nextInt(40)));
      expect(tester.takeException(), isNull, reason: 'round $i ${data.value}');
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(errors, isEmpty);
  });
}

/// A custom motion that fails in `frame()` whenever its `begin` is `1`, as an
/// app-registered motion with a bug would.
class _FlakyMotion extends Motion {
  const _FlakyMotion();

  @override
  String get type => 'flaky';

  @override
  MotionPlan plan(MotionParams params) => MotionPlan.from(params);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) {
    if (p.raw('begin') == 1) throw StateError('flaky frame');
    return Opacity(opacity: t.clamp(0, 1), child: child);
  }
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}
