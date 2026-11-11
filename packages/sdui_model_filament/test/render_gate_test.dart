import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_filament/src/render_gate.dart';

void main() {
  const linger = Duration(milliseconds: 300);

  // testWidgets fakes timers; tester.pump advances them.
  ({RenderGate gate, List<String> calls, Set<Object> drawn}) newGate() {
    final calls = <String>[];
    final drawn = <Object>{};
    return (
      gate: RenderGate(
        resume: () => calls.add('resume'),
        pause: () => calls.add('pause'),
        render: (view, rendering) =>
            rendering ? drawn.add(view) : drawn.remove(view),
        linger: linger,
      ),
      calls: calls,
      drawn: drawn,
    );
  }

  testWidgets('아무도 원하지 않으면 멈추고, 변화가 생기면 linger 동안만 돈다', (tester) async {
    final (:gate, :calls, drawn: _) = newGate();
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
    final (:gate, :calls, drawn: _) = newGate();
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
    final (:gate, calls: _, drawn: _) = newGate();
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
    final (:gate, :calls, drawn: _) = newGate();
    final view = Object();
    gate.hold(view, playing: true);

    gate.release(view);
    await tester.pump(const Duration(milliseconds: 200));
    expect(gate.running, isTrue);
    await tester.pump(const Duration(milliseconds: 100));

    expect(gate.running, isFalse);
    expect(calls, ['pause']);
  });

  testWidgets('한 뷰가 움직이면 그 뷰만 그리고, 가만히 있는 뷰는 그리기에서 뺀다', (tester) async {
    final (:gate, calls: _, :drawn) = newGate();
    final still = Object();
    final moving = Object();

    gate.touch(still);
    gate.hold(moving, playing: true);
    expect(drawn, {still, moving});

    await tester.pump(linger);
    expect(drawn, {moving});
    expect(gate.running, isTrue);

    gate.hold(moving, playing: false);
    await tester.pump(linger);
    expect(drawn, isEmpty);
    expect(gate.running, isFalse);
  });

  testWidgets('뷰가 사라지면 남은 뷰를 linger 동안 다시 그린다', (tester) async {
    final (:gate, calls: _, :drawn) = newGate();
    final gone = Object();
    final kept = Object();
    gate.touch(kept);
    gate.hold(gone, playing: true);
    await tester.pump(linger);
    expect(drawn, {gone});

    // 사라진 뷰는 뷰어가 정리하므로 그리기에서 빼라고 다시 부르지 않는다.
    gate.release(gone);
    expect(drawn, contains(kept));
    await tester.pump(linger);
    expect(drawn, isNot(contains(kept)));
    expect(gate.running, isFalse);
  });

  testWidgets('wake 는 모든 뷰를 linger 동안 그린다', (tester) async {
    final (:gate, :calls, :drawn) = newGate();
    final a = Object();
    final b = Object();
    gate.touch(a);
    gate.touch(b);
    await tester.pump(linger);
    expect(drawn, isEmpty);
    expect(gate.running, isFalse);

    gate.wake();
    expect(drawn, {a, b});
    expect(gate.running, isTrue);
    await tester.pump(linger);
    expect(drawn, isEmpty);
    expect(calls, ['pause', 'resume', 'pause']);
  });
}
