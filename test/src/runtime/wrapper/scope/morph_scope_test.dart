import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';

void main() {
  group('MorphScope', () {
    testWidgets('from→to 값을 subtree에 발행하고 완료 뒤 목표값에 닿는다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': 100,
                  '_as': 'n',
                  '_duration': 100,
                  '_curve': 'linear',
                },
                'value': r'${int(n)}',
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, inExclusiveRange(0, 100));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('_curve가 없으면 easeOut을 쓴다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': 100,
                  '_as': 'n',
                  '_duration': 100,
                },
                'value': r'${int(n)}',
              },
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, greaterThan(50));
      await tester.pumpAndSettle();
    });

    testWidgets('반응형 _to 변경 시 현재값에서 새 목표로 재전이한다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);

      Widget tree() => MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: score,
            builder: (context, value, child) => EngineRunner(
              template: const {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': r'${score}',
                  '_as': 'n',
                  '_duration': 100,
                  '_curve': 'linear',
                },
                'value': r'${int(n)}',
              },
              rootData: {'score': value},
            ),
          ),
        ),
      );

      await tester.pumpWidget(tree());
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);

      score.value = 200;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final midway = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(midway, inExclusiveRange(100, 200));
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // 0.7.0 spring 도입 전 tween 경로의 동작을 고정한다. spring 추가 뒤에도 그대로 통과해야 한다.
  group('MorphScope tween characterization', () {
    double value(WidgetTester tester) =>
        double.parse(tester.widget<Text>(find.byType(Text)).data!);

    Widget mount(Map<String, Object?> morph, {Map<String, Object?>? data}) =>
        MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {'_type': 'text', '_morph': morph, 'value': r'${n}'},
              rootData: data ?? const {},
            ),
          ),
        );

    for (final curve in [
      ('linear', Curves.linear),
      ('ease_out', Curves.easeOut),
      ('ease_in_out', Curves.easeInOut),
      ('fast_out_slow_in', Curves.fastOutSlowIn),
    ]) {
      testWidgets('${curve.$1} 곡선은 t마다 from + (to-from)·curve(t)', (
        tester,
      ) async {
        await tester.pumpWidget(
          mount({
            '_from': 0,
            '_to': 100,
            '_as': 'n',
            '_duration': 100,
            '_curve': curve.$1,
          }),
        );
        expect(value(tester), 0);
        for (final t in [0.25, 0.5, 0.75]) {
          await tester.pump(const Duration(milliseconds: 25));
          expect(value(tester), closeTo(100 * curve.$2.transform(t), 1e-6));
        }
        await tester.pump(const Duration(milliseconds: 25));
        expect(value(tester), 100);
      });
    }

    testWidgets('미지 곡선 이름은 easeOut으로 대체된다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_duration': 100,
          '_curve': 'nope',
        }),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(100 * Curves.easeOut.transform(0.5), 1e-6));
    });

    testWidgets('비행 중 재목표는 현재값에서 전체 duration을 다시 탄다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${score}',
              '_as': 'n',
              '_duration': 100,
              '_curve': 'linear',
            },
            data: {'score': v},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));

      score.value = 0;
      await tester.pump();
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(25, 1e-6));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), 0);
    });

    testWidgets('_delay 동안 from에 머물고 그 뒤 전이한다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_duration': 100,
          '_curve': 'linear',
          '_delay': 200,
        }),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(value(tester), 0);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pumpAndSettle();
      expect(value(tester), 100);
    });

    testWidgets('_repeat + _reverse는 to와 from 사이를 왕복한다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_duration': 100,
          '_curve': 'linear',
          '_repeat': true,
          '_reverse': true,
        }),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(value(tester), closeTo(100, 1e-6));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(0, 1e-6));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('_repeat만 있으면 끝에서 from으로 돌아가 반복한다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_duration': 100,
          '_curve': 'linear',
          '_repeat': true,
        }),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pump(const Duration(milliseconds: 75));
      expect(value(tester), closeTo(25, 1e-6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('_trigger 변화는 _from에서 다시 시작한다', (tester) async {
      final epoch = ValueNotifier<int>(0);
      addTearDown(epoch.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: epoch,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': 100,
              '_as': 'n',
              '_duration': 100,
              '_curve': 'linear',
              '_trigger': r'${epoch}',
            },
            data: {'epoch': v},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 100);

      epoch.value = 1;
      await tester.pump();
      expect(value(tester), 0);
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pumpAndSettle();
      expect(value(tester), 100);
    });

    testWidgets('같은 목표 재평가는 진행 중인 전이를 바꾸지 않는다', (tester) async {
      final other = ValueNotifier<int>(0);
      addTearDown(other.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: other,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${100 + other * 0}',
              '_as': 'n',
              '_duration': 100,
              '_curve': 'linear',
            },
            data: {'other': v},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      other.value = 1;
      await tester.pump();
      expect(value(tester), closeTo(50, 1e-6));
      await tester.pump(const Duration(milliseconds: 25));
      expect(value(tester), closeTo(75, 1e-6));
    });

    testWidgets('비유한 목표는 이전 목표를 유지한다', (tester) async {
      final score = ValueNotifier<int>(1);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${score ** 400.5}',
              '_as': 'n',
              '_duration': 100,
              '_curve': 'linear',
            },
            data: {'score': v},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 1);
      score.value = 10; // 10 ** 400.5 = Infinity
      await tester.pump();
      await tester.pumpAndSettle();
      expect(value(tester), 1);
    });
  });

  group('MorphScope spring', () {
    double value(WidgetTester tester) =>
        double.parse(tester.widget<Text>(find.byType(Text)).data!);

    SpringDescription describe(double k, double ratio, [double mass = 1]) =>
        SpringDescription.withDampingRatio(
          mass: mass,
          stiffness: k,
          ratio: ratio,
        );

    Widget mount(
      Map<String, Object?> morph, {
      Map<String, Object?>? data,
      bool reduceMotion = false,
    }) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: Scaffold(
        body: EngineRunner(
          template: {'_type': 'text', '_morph': morph, 'value': r'${n}'},
          rootData: data ?? const {},
        ),
      ),
    );

    Widget reactive(
      ValueNotifier<int> target,
      Map<String, Object?> morph, {
      bool reduceMotion = false,
    }) => ValueListenableBuilder<int>(
      valueListenable: target,
      builder: (context, v, _) => mount(
        {'_to': r'${score}', '_as': 'n', ...morph},
        data: {'score': v},
        reduceMotion: reduceMotion,
      ),
    );

    testWidgets('값은 SpringSimulation 해석해를 따르고 목표에 정확히 멈춘다', (tester) async {
      final sim = SpringSimulation(describe(100, 0.5), 0, 100, 0);
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_spring': {'stiffness': 100, 'damping_ratio': 0.5},
        }),
      );
      expect(value(tester), 0);
      var peak = 0.0;
      for (var ms = 50; ms <= 600; ms += 50) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(value(tester), closeTo(sim.x(ms / 1000), 1e-6), reason: '$ms');
        if (value(tester) > peak) peak = value(tester);
      }
      expect(peak, greaterThan(100)); // underdamped overshoot
      await tester.pumpAndSettle();
      expect(value(tester), 100);
    });

    testWidgets('프리셋 이름도 같은 해석해를 쓴다', (tester) async {
      final sim = SpringSimulation(describe(700, 0.75), 0, 1, 0);
      await tester.pumpWidget(
        mount({'_from': 0, '_to': 1, '_as': 'n', '_spring': 'spatial_default'}),
      );
      await tester.pump(const Duration(milliseconds: 40));
      expect(value(tester), closeTo(sim.x(0.04), 1e-9));
      await tester.pumpAndSettle();
      expect(value(tester), 1);
    });

    testWidgets('재목표는 현재 값과 속도를 이어받는다', (tester) async {
      final desc = describe(300, 0.6);
      final first = SpringSimulation(desc, 0, 100, 0);
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        reactive(score, {
          '_from': 0,
          '_spring': {'stiffness': 300, 'damping_ratio': 0.6},
        }),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final x1 = first.x(0.1);
      final v1 = first.dx(0.1);
      expect(value(tester), closeTo(x1, 1e-6));

      score.value = 0;
      await tester.pump();
      final second = SpringSimulation(desc, x1, 0, v1);
      await tester.pump(const Duration(milliseconds: 20));
      expect(value(tester), closeTo(second.x(0.02), 1e-6));
      await tester.pump(const Duration(milliseconds: 30));
      expect(value(tester), closeTo(second.x(0.05), 1e-6));
      await tester.pumpAndSettle();
      expect(value(tester), 0);
    });

    testWidgets('effect 프리셋은 재목표 때 속도 0에서 출발한다', (tester) async {
      final desc = describe(800, 1);
      final first = SpringSimulation(desc, 0, 100, 0);
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        reactive(score, {'_from': 0, '_spring': 'effect_default'}),
      );
      await tester.pump(const Duration(milliseconds: 30));
      final x1 = first.x(0.03);
      expect(first.dx(0.03).abs(), greaterThan(1));

      score.value = 0;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(
        value(tester),
        closeTo(SpringSimulation(desc, x1, 0, 0).x(0.02), 1e-6),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 0);
    });

    testWidgets('같은 목표 재평가는 진행 중인 시뮬레이션을 바꾸지 않는다', (tester) async {
      final sim = SpringSimulation(describe(200, 0.7), 0, 100, 0);
      final other = ValueNotifier<int>(0);
      addTearDown(other.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: other,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${100 + other * 0}',
              '_as': 'n',
              '_spring': {'stiffness': 200, 'damping_ratio': 0.7},
            },
            data: {'other': v},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      other.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), closeTo(sim.x(0.1), 1e-6));
      await tester.pumpAndSettle();
    });

    testWidgets('비유한 목표는 이전 목표를 유지한다', (tester) async {
      final score = ValueNotifier<int>(1);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${score ** 400.5}',
              '_as': 'n',
              '_spring': 'spatial_fast',
            },
            data: {'score': v},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 1);
      score.value = 10;
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(value(tester), 1);
    });

    testWidgets('목표 식이 평가 오류면 이전 목표를 유지하고 예외를 내지 않는다', (tester) async {
      final score = ValueNotifier<int>(1);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': r'${10 / score}',
              '_as': 'n',
              '_spring': 'spatial_fast',
            },
            data: {'score': v},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 10);
      score.value = 0; // division by zero
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(value(tester), 10);
    });

    testWidgets('첫 목표 식이 평가 오류이고 _from도 없으면 변수는 null', (tester) async {
      await tester.pumpWidget(
        mount(
          {'_to': r'${1 / zero}', '_as': 'n', '_spring': 'spatial_fast'},
          data: {'zero': 0},
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<Text>(find.byType(Text)).data, isEmpty);
    });

    testWidgets('5초 안에 멈추지 않으면 목표로 스냅하고 멈춘다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_spring': {'stiffness': 1, 'damping_ratio': 0.2, 'mass': 10},
        }),
      );
      await tester.pump(const Duration(milliseconds: 4900));
      expect(value(tester), isNot(100));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      expect(value(tester), 100);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('재목표마다 5초 상한이 새로 시작한다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        reactive(score, {
          '_from': 0,
          '_spring': {'stiffness': 1, 'damping_ratio': 0.2, 'mass': 10},
        }),
      );
      await tester.pump(const Duration(seconds: 3));
      score.value = 50;
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(value(tester), isNot(50));
      await tester.pump(const Duration(milliseconds: 2100));
      expect(value(tester), 50);
    });

    testWidgets('disableAnimations면 목표로 즉시 이동한다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        reactive(score, {
          '_from': 0,
          '_spring': 'spatial_default',
        }, reduceMotion: true),
      );
      expect(value(tester), 100);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      score.value = 30;
      await tester.pump();
      expect(value(tester), 30);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('_delay 동안 from에 머문 뒤 시뮬레이션을 시작한다', (tester) async {
      final sim = SpringSimulation(describe(100, 0.5), 0, 100, 0);
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_delay': 200,
          '_spring': {'stiffness': 100, 'damping_ratio': 0.5},
        }),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(value(tester), 0);
      await tester.pump(const Duration(milliseconds: 50)); // delay fires
      await tester.pump(const Duration(milliseconds: 100));
      expect(value(tester), closeTo(sim.x(0.1), 1e-6));
      await tester.pumpAndSettle();
    });

    testWidgets('_trigger 변화는 _from에서 정지 상태로 다시 시작한다', (tester) async {
      final sim = SpringSimulation(describe(100, 0.5), 0, 100, 0);
      final epoch = ValueNotifier<int>(0);
      addTearDown(epoch.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: epoch,
          builder: (context, v, _) => mount(
            {
              '_from': 0,
              '_to': 100,
              '_as': 'n',
              '_trigger': r'${epoch}',
              '_spring': {'stiffness': 100, 'damping_ratio': 0.5},
            },
            data: {'epoch': v},
          ),
        ),
      );
      await tester.pumpAndSettle();
      epoch.value = 1;
      await tester.pump();
      expect(value(tester), 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(value(tester), closeTo(sim.x(0.1), 1e-6));
      await tester.pumpAndSettle();
      expect(value(tester), 100);
    });

    testWidgets('비행 중·지연 중 dispose는 남는 ticker·timer가 없다', (tester) async {
      await tester.pumpWidget(
        mount({'_from': 0, '_to': 100, '_as': 'n', '_spring': 'spatial_slow'}),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);

      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_as': 'n',
          '_delay': 500,
          '_spring': 'spatial_slow',
        }),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('tween ↔ spring 템플릿 교체는 상태를 새로 만든다', (tester) async {
      Widget runner(Map<String, Object?> morph) => MaterialApp(
        home: Scaffold(
          body: EngineRunner(
            template: {'_type': 'text', '_morph': morph, 'value': r'${n}'},
          ),
        ),
      );
      await tester.pumpWidget(
        runner({'_from': 0, '_to': 10, '_as': 'n', '_duration': 100}),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        runner({'_from': 0, '_to': 20, '_as': 'n', '_spring': 'spatial_fast'}),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(
        value(tester),
        closeTo(SpringSimulation(describe(1400, 0.8), 0, 20, 0).x(0.02), 1e-6),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 20);
      await tester.pumpWidget(
        runner({'_from': 0, '_to': 30, '_as': 'n', '_duration': 100}),
      );
      await tester.pumpAndSettle();
      expect(value(tester), 30);
      expect(tester.takeException(), isNull);
    });
  });

  // 0.7.0: morph는 어떤 실패에도 템플릿·앱을 멈추지 않는다. 식 평가 실패는
  // 마지막 좋은 값 → 유효한 _from → null 순으로 대신하고, 아무것도 보고하지 않는다.
  group('MorphScope 실패 격리', () {
    late List<SduiError> errors;

    setUp(() {
      errors = [];
      EngineErrors.observer = _Capture(errors);
      // boom(x): x가 0이면 Format/State 밖의 오류를 던지고, 아니면 x.
      FunctionRegistry.register(
        'boom',
        (args) => args.first == 0 ? throw ArgumentError('boom') : args.first,
      );
    });
    tearDown(() {
      EngineErrors.reset();
      FunctionRegistry.reset();
    });

    String shown(WidgetTester tester) =>
        tester.widget<Text>(find.byType(Text)).data!;

    Widget mount(
      ValueNotifier<Map<String, Object?>> data,
      Map<String, Object?> morph,
    ) => ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: data,
      builder: (context, root, _) => MaterialApp(
        home: Scaffold(
          body: EngineRunner(
            template: {
              '_type': 'text',
              '_morph': {'_as': 'n', ...morph},
              'value': r"${n == null ? 'none' : int(n)}",
            },
            rootData: root,
          ),
        ),
      ),
    );

    for (final variant in <String, Map<String, Object?>>{
      'tween': {'_duration': 100, '_curve': 'linear'},
      'spring': {'_spring': 'spatial_fast'},
    }.entries) {
      ValueNotifier<Map<String, Object?>> notifier(
        WidgetTester tester,
        Map<String, Object?> value,
      ) {
        final data = ValueNotifier<Map<String, Object?>>(value);
        addTearDown(data.dispose);
        return data;
      }

      testWidgets('${variant.key}: _to가 던지면 마지막 좋은 값을 유지한다', (tester) async {
        final data = notifier(tester, {'s': 5});
        await tester.pumpWidget(
          mount(data, {'_to': r'${boom(s)}', ...variant.value}),
        );
        await tester.pumpAndSettle();
        expect(shown(tester), '5');
        data.value = {'s': 0};
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(shown(tester), '5');
        data.value = {'s': 9};
        await tester.pumpAndSettle();
        expect(shown(tester), '9');
        expect(errors, isEmpty);
      });

      testWidgets('${variant.key}: 첫 _to가 던지면 유효한 _from을 쓴다', (tester) async {
        final data = notifier(tester, {'s': 0});
        await tester.pumpWidget(
          mount(data, {'_to': r'${boom(s)}', '_from': 3, ...variant.value}),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(shown(tester), '3');
        expect(errors, isEmpty);
      });

      testWidgets('${variant.key}: 좋은 값이 한 번도 없으면 null, 뒤에 좋아지면 따라간다', (
        tester,
      ) async {
        final data = notifier(tester, {'s': 0});
        await tester.pumpWidget(
          mount(data, {
            '_to': r'${boom(s)}',
            '_from': r'${boom(s)}',
            ...variant.value,
          }),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(shown(tester), 'none');
        data.value = {'s': 7};
        await tester.pumpAndSettle();
        expect(shown(tester), '7');
        expect(errors, isEmpty);
      });

      testWidgets('${variant.key}: _trigger·_from이 던져도 예외 없이 이어간다', (
        tester,
      ) async {
        final data = notifier(tester, {'s': 4, 't': 1, 'f': 1});
        await tester.pumpWidget(
          mount(data, {
            '_to': r'${s}',
            '_from': r'${boom(f)}',
            '_trigger': r'${boom(t)}',
            ...variant.value,
          }),
        );
        await tester.pumpAndSettle();
        expect(shown(tester), '4');
        data.value = {'s': 4, 't': 0, 'f': 1};
        await tester.pumpAndSettle();
        data.value = {'s': 6, 't': 2, 'f': 0};
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(shown(tester), '6');
        expect(errors, isEmpty);
      });
    }

    for (final misuse in <String, Map<String, Object?>>{
      '_duration 꼴 오류': {'_duration': 'abc'},
      '길이 0 반복': {'_duration': 0, '_repeat': true},
      '_spring 꼴 오류': {'_spring': 5},
      '_spring + _duration 충돌': {'_spring': 'spatial_fast', '_duration': 300},
      '_spring 범위 밖': {
        '_spring': {'stiffness': 0, 'damping_ratio': 1},
      },
    }.entries) {
      testWidgets('${misuse.key}: 애니메이션 없이 _to를 즉시 따른다', (tester) async {
        final data = ValueNotifier<Map<String, Object?>>({'s': 10});
        addTearDown(data.dispose);
        await tester.pumpWidget(
          mount(data, {'_from': 0, '_to': r'${s}', ...misuse.value}),
        );
        expect(shown(tester), '10');
        data.value = {'s': 20};
        await tester.pump();
        expect(shown(tester), '20');
        expect(tester.binding.hasScheduledFrame, isFalse);
        expect(tester.takeException(), isNull);
        expect(errors, isEmpty);
      });
    }
  });
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}
