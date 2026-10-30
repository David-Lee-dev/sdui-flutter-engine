import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/util/function_registry.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/morph_scope.dart';

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

    testWidgets('inset·padding만 바뀌면 다시 빌드하지 않고 reduced motion 전환에는 반응한다', (
      tester,
    ) async {
      final media = ValueNotifier(const MediaQueryData());
      addTearDown(media.dispose);
      var rebuilds = 0;
      debugOnRebuildDirtyWidget = (element, _) {
        if (element.widget is SpringMorphScope) rebuilds++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      await tester.pumpWidget(
        ValueListenableBuilder<MediaQueryData>(
          valueListenable: media,
          builder: (_, data, child) => MediaQuery(data: data, child: child!),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_from': 0,
                  '_to': 100,
                  '_as': 'n',
                  '_spring': 'spatial_slow',
                },
                'value': r'${n}',
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      final before = rebuilds;
      for (var i = 1; i <= 5; i++) {
        media.value = media.value.copyWith(
          viewInsets: EdgeInsets.only(bottom: i * 40.0),
          padding: EdgeInsets.only(bottom: 34.0 - i),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(rebuilds, before);
      expect(value(tester), inExclusiveRange(0, 100));
      media.value = media.value.copyWith(disableAnimations: true);
      await tester.pump();
      expect(value(tester), 100);
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

  group('MorphScope 0.9.0 _velocity', () {
    /// `[value, velocity]` shown by the template text.
    List<double> shown(WidgetTester tester) => tester
        .widget<Text>(find.byType(Text))
        .data!
        .split('|')
        .map(double.parse)
        .toList();

    Widget mount(Map<String, Object?> morph, {bool reduceMotion = false}) =>
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {'_as': 'n', '_velocity': 'v', ...morph},
                'value': r'${n}|${v}',
              },
            ),
          ),
        );

    testWidgets('linear tween은 (to-from)/duration 단위/초, 끝나면 0', (tester) async {
      await tester.pumpWidget(
        mount({'_from': 0, '_to': 100, '_duration': 200, '_curve': 'linear'}),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(shown(tester)[1], closeTo(500, 1e-6));
      await tester.pump(const Duration(milliseconds: 100));
      expect(shown(tester)[1], closeTo(500, 1e-6));
      await tester.pumpAndSettle();
      expect(shown(tester), [100, 0]);
    });

    testWidgets('곡선 tween은 곡선 기울기 × (to-from)/duration', (tester) async {
      await tester.pumpWidget(
        mount({'_from': 0, '_to': 100, '_duration': 200, '_curve': 'ease_out'}),
      );
      await tester.pump(const Duration(milliseconds: 60));
      const t = 0.3, h = 1e-4;
      final slope =
          (Curves.easeOut.transform(t + h) - Curves.easeOut.transform(t - h)) /
          (2 * h);
      expect(shown(tester)[1], closeTo(slope * 100 / 0.2, 1));
      await tester.pumpAndSettle();
      expect(shown(tester)[1], 0);
    });

    testWidgets('repeat + reverse의 되돌아오는 다리는 음의 속도', (tester) async {
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 10,
          '_duration': 100,
          '_curve': 'linear',
          '_repeat': true,
          '_reverse': true,
        }),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(shown(tester)[1], closeTo(100, 1e-6));
      await tester.pump(const Duration(milliseconds: 100));
      expect(shown(tester)[1], closeTo(-100, 1e-6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('spring은 시뮬레이션 속도를 따르고 멈추면 0', (tester) async {
      final sim = SpringSimulation(
        SpringDescription.withDampingRatio(mass: 1, stiffness: 100, ratio: 0.5),
        0,
        100,
        0,
      );
      await tester.pumpWidget(
        mount({
          '_from': 0,
          '_to': 100,
          '_spring': {'stiffness': 100, 'damping_ratio': 0.5},
        }),
      );
      for (var ms = 50; ms <= 300; ms += 50) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          shown(tester)[1],
          closeTo(sim.dx(ms / 1000), 1e-6),
          reason: '$ms',
        );
      }
      await tester.pumpAndSettle();
      expect(shown(tester), [100, 0]);
    });

    testWidgets('reduced motion에서는 값이 목표이고 속도는 0', (tester) async {
      for (final morph in <Map<String, Object?>>[
        {'_from': 0, '_to': 100, '_spring': 'spatial_default'},
        {'_from': 0, '_to': 100, '_duration': 300},
      ]) {
        await tester.pumpWidget(mount(morph, reduceMotion: true));
        await tester.pump(const Duration(milliseconds: 20));
        expect(shown(tester), [100, 0], reason: '$morph');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('속도는 ±1e4로 자르고 비유한이면 0', (tester) async {
      Future<double> midway(num from, num to) async {
        await tester.pumpWidget(
          mount({
            '_from': from,
            '_to': to,
            '_duration': 100,
            '_curve': 'linear',
          }),
        );
        await tester.pump(const Duration(milliseconds: 50));
        final v = shown(tester)[1];
        await tester.pumpWidget(const SizedBox());
        return v;
      }

      expect(await midway(0, 1e9), 1e4);
      expect(await midway(0, -1e9), -1e4);
      expect(await midway(-1.7e308, 1.7e308), 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('애니메이션 없는 morph(잘못된 _duration)의 속도는 0', (tester) async {
      await tester.pumpWidget(mount({'_from': 0, '_to': 5, '_duration': -1}));
      expect(shown(tester), [5, 0]);
    });

    testWidgets('속도만 읽는 자식도 매 틱 다시 그린다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'text',
                '_morph': {
                  '_as': 'n',
                  '_velocity': 'v',
                  '_from': 0,
                  '_to': 10,
                  '_spring': 'spatial_slow',
                },
                'value': r'${round(v)}',
              },
            ),
          ),
        ),
      );
      final seen = <String>{};
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        seen.add(tester.widget<Text>(find.byType(Text)).data!);
      }
      expect(seen.length, greaterThan(3));
      await tester.pumpAndSettle();
    });
  });

  group('MorphScope 0.9.0 tween reduced motion', () {
    double value(WidgetTester tester) =>
        double.parse(tester.widget<Text>(find.byType(Text)).data!);

    Widget mount(ValueNotifier<int> score, Map<String, Object?> morph) =>
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, v, _) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Scaffold(
              body: EngineRunner(
                template: {
                  '_type': 'text',
                  '_morph': {'_to': r'${score}', '_as': 'n', ...morph},
                  'value': r'${n}',
                },
                rootData: {'score': v},
              ),
            ),
          ),
        );

    testWidgets('첫 프레임부터 목표이고 재목표도 즉시 이동한다', (tester) async {
      final score = ValueNotifier<int>(100);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        mount(score, {'_from': 0, '_duration': 300, '_delay': 100}),
      );
      expect(value(tester), 100);
      expect(tester.hasRunningAnimations, isFalse);
      score.value = 30;
      await tester.pump();
      expect(value(tester), 30);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('_repeat도 목표에 머문다', (tester) async {
      final score = ValueNotifier<int>(10);
      addTearDown(score.dispose);
      await tester.pumpWidget(
        mount(score, {
          '_from': 0,
          '_duration': 100,
          '_repeat': true,
          '_reverse': true,
        }),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(value(tester), 10);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('MorphScope 0.10.1 spring reduced motion mid-flight', () {
    List<double> read(WidgetTester tester) => [
      for (final part
          in tester.widget<Text>(find.byType(Text)).data!.split('|'))
        double.parse(part),
    ];
    double value(WidgetTester tester) => read(tester)[0];
    double velocity(WidgetTester tester) => read(tester)[1];

    Widget mount(bool reduce, Map<String, Object?> morph) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: Scaffold(
        body: EngineRunner(
          template: {
            '_type': 'text',
            '_morph': {
              '_from': 0,
              '_to': 100,
              '_as': 'n',
              '_velocity': 'v',
              '_spring': {'stiffness': 100, 'damping_ratio': 0.5},
              ...morph,
            },
            'value': r'${n}|${v}',
          },
        ),
      ),
    );

    testWidgets('비행 중 켜지면 목표로 이동하고 멈추며, 다시 꺼도 재생하지 않는다', (tester) async {
      await tester.pumpWidget(mount(false, const {}));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), inExclusiveRange(0, 100));

      await tester.pumpWidget(mount(true, const {}));
      await tester.pump();
      expect(value(tester), 100);
      expect(velocity(tester), 0);
      expect(tester.hasRunningAnimations, isFalse);

      await tester.pumpWidget(mount(false, const {}));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), 100);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('_delay 대기 중 켜지면 타이머를 취소하고 목표로 이동한다', (tester) async {
      await tester.pumpWidget(mount(false, const {'_delay': 200}));
      await tester.pump(const Duration(milliseconds: 50));
      expect(value(tester), 0);

      await tester.pumpWidget(mount(true, const {'_delay': 200}));
      await tester.pump();
      expect(value(tester), 100);
      expect(velocity(tester), 0);

      await tester.pumpWidget(mount(false, const {'_delay': 200}));
      await tester.pump(const Duration(milliseconds: 300));
      expect(value(tester), 100);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('MorphScope 0.9.0 RepaintBoundary', () {
    Finder boundaryAbove(Type scope) => find.ancestor(
      of: find.byType(Text),
      matching: find.descendant(
        of: find.byType(scope),
        matching: find.byType(RepaintBoundary),
      ),
    );

    Widget mount(Map<String, Object?> template) => MaterialApp(
      home: Scaffold(body: EngineRunner(template: template)),
    );

    testWidgets('spring morph는 바로 아래 위젯을 RepaintBoundary로 감싼다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_type': 'text',
          '_morph': {'_to': 1, '_as': 'n', '_spring': 'spatial_fast'},
          'value': r'${n}',
        }),
      );
      expect(boundaryAbove(SpringMorphScope), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('반복 tween morph도 감싼다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_type': 'text',
          '_morph': {'_to': 1, '_as': 'n', '_duration': 100, '_repeat': true},
          'value': r'${n}',
        }),
      );
      expect(boundaryAbove(MorphScope), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('one-shot tween morph의 트리는 그대로다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_type': 'text',
          '_morph': {'_from': 0, '_to': 1, '_as': 'n', '_duration': 100},
          'value': r'${n}',
        }),
      );
      expect(boundaryAbove(MorphScope), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('expanded 노드의 spring morph도 parent data를 지킨다', (tester) async {
      await tester.pumpWidget(
        mount({
          '_type': 'row',
          '_children': [
            {
              '_type': 'expanded',
              '_morph': {'_to': 1, '_as': 'n', '_spring': 'spatial_fast'},
              '_child': {'_type': 'text', 'value': r'${n}'},
            },
          ],
        }),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(boundaryAbove(SpringMorphScope), findsOneWidget);
      expect(
        find.ancestor(
          of: boundaryAbove(SpringMorphScope),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });

    final sliverMorphs = {
      '반복 tween': {'_duration': 100, '_repeat': true},
      'spring': {'_spring': 'spatial_fast'},
    };
    for (final morph in sliverMorphs.entries) {
      testWidgets('sliver 노드의 ${morph.key} morph는 RepaintBoundary를 넣지 않는다', (
        tester,
      ) async {
        await tester.pumpWidget(
          mount({
            '_type': 'custom_scroll_view',
            '_children': [
              {
                '_type': 'sliver_to_box_adapter',
                '_morph': {'_to': 1, '_as': 'n', ...morph.value},
                '_child': {'_type': 'text', 'value': r'${n}'},
              },
            ],
          }),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        expect(find.byType(Text), findsOneWidget);
        expect(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(RepaintBoundary),
              )
              .evaluate()
              .where(
                (e) =>
                    e.findAncestorWidgetOfExactType<SliverToBoxAdapter>() ==
                    null,
              ),
          isEmpty,
        );
        await tester.pumpWidget(const SizedBox());
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
