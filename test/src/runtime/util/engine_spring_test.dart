import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/engine_spring.dart';
import 'package:sdui_engine/src/runtime/util/engine_spring.dart';

void main() {
  group('EngineSpring', () {
    test('describe는 감쇠비로 damping = ratio·2·√(m·k)를 만든다', () {
      final d = EngineSpring.describe(
        const EngineSpringSpec(stiffness: 400, dampingRatio: 0.5, mass: 2),
      );
      expect(d.mass, 2);
      expect(d.stiffness, 400);
      expect(d.damping, closeTo(0.5 * 2 * math.sqrt(2 * 400), 1e-9));
    });

    test('프리셋 값과 effect의 속도 비승계', () {
      const presets = EngineSpringNames.presets;
      expect(presets.keys, {
        'spatial_fast',
        'spatial_default',
        'spatial_slow',
        'effect_default',
      });
      expect(presets['spatial_fast']!.dampingRatio, 0.8);
      expect(presets['spatial_default']!.dampingRatio, 0.75);
      expect(presets['spatial_slow']!.dampingRatio, 0.85);
      expect(presets['effect_default']!.carriesVelocity, isFalse);
      expect(
        presets.entries
            .where((e) => e.key != 'effect_default')
            .every((e) => e.value.carriesVelocity && e.value.mass == 1),
        isTrue,
      );
    });

    test('simulate는 멈추면 목표값·속도 0을 보고한다', () {
      final sim = EngineSpring.simulate(
        EngineSpringNames.presets['spatial_fast']!,
        from: 0,
        to: 1,
        velocity: 0,
      );
      expect(sim.isDone(0), isFalse);
      expect(sim.isDone(2), isTrue);
      expect(sim.x(2), 1);
      expect(sim.dx(2), 0);
    });

    test('simulate의 정착 허용치는 이동 거리에 비례한다', () {
      const spec = EngineSpringSpec(stiffness: 200, dampingRatio: 1);
      final small = EngineSpring.simulate(spec, from: 0, to: 1, velocity: 0);
      final large = EngineSpring.simulate(spec, from: 0, to: 1000, velocity: 0);
      double settle(Simulation sim) {
        var t = 0.0;
        while (!sim.isDone(t)) {
          t += 0.001;
        }
        return t;
      }

      // 비례 허용치면 거리와 무관하게 거의 같은 시간에 정착한다.
      expect(settle(large), closeTo(settle(small), 0.01));
    });

    test('simulate는 5초가 지나면 정착 여부와 무관하게 목표로 끝난다', () {
      final sim = EngineSpring.simulate(
        const EngineSpringSpec(stiffness: 1, dampingRatio: 0.2, mass: 10),
        from: 0,
        to: 100,
        velocity: 0,
      );
      expect(sim.isDone(4.99), isFalse);
      expect(sim.isDone(5), isTrue);
      expect(sim.x(5), 100);
    });
  });
}
