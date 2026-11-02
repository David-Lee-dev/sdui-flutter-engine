import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_filament/src/render_gate.dart';

void main() {
  const linger = Duration(milliseconds: 300);

  // testWidgets fakes timers; tester.pump advances them.
  ({RenderGate gate, List<String> calls}) newGate() {
    final calls = <String>[];
    return (
      gate: RenderGate(
        resume: () => calls.add('resume'),
        pause: () => calls.add('pause'),
        linger: linger,
      ),
      calls: calls,
    );
  }

  testWidgets('아무도 원하지 않으면 멈추고, 변화가 생기면 linger 동안만 돈다', (tester) async {
    final (:gate, :calls) = newGate();
    final view = Object();

    gate.settle();
    expect(calls, ['pause']);

    gate.touch(view);
    expect(gate.running, isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    gate.touch(view); // 연속 변화는 linger를 다시 센다
    await tester.pump(const Duration(milliseconds: 200));
    expect(gate.running, isTrue);
    await tester.pump(const Duration(milliseconds: 100));

    expect(gate.running, isFalse);
    expect(calls, ['pause', 'resume', 'pause']);
  });

  testWidgets('재생 중에는 계속 돌고, 재생이 끝나면 linger 뒤 멈춘다', (tester) async {
    final (:gate, :calls) = newGate();
    final view = Object();
    gate.settle();

    gate.hold(view, playing: true);
    await tester.pump(const Duration(seconds: 5));
    expect(gate.running, isTrue);

    gate.hold(view, playing: false);
    await tester.pump(linger);
    expect(gate.running, isFalse);
    expect(calls, ['pause', 'resume', 'pause']);
  });

  testWidgets('다른 뷰가 움직이는 동안에는 한 뷰가 멈춰도 계속 돈다', (tester) async {
    final (:gate, calls: _) = newGate();
    final still = Object();
    final moving = Object();
    gate.settle();

    gate.touch(still);
    gate.hold(moving, playing: true);
    await tester.pump(linger * 2);
    expect(gate.running, isTrue);

    gate.hold(moving, playing: false);
    await tester.pump(linger);
    expect(gate.running, isFalse);
  });

  testWidgets('뷰가 사라지면 자원 정리를 위해 linger 동안 더 돈다', (tester) async {
    final (:gate, :calls) = newGate();
    final view = Object();
    gate.hold(view, playing: true);

    gate.release(view);
    await tester.pump(const Duration(milliseconds: 200));
    expect(gate.running, isTrue);
    await tester.pump(const Duration(milliseconds: 100));

    expect(gate.running, isFalse);
    expect(calls, ['pause']);
  });
}
