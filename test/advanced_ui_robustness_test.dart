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
      for (final name in ['sin', 'cos', 'pow', 'remap']) {
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
