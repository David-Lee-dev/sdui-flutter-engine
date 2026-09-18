import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/event_timing.dart';
import 'package:sdui_engine/src/runtime/wrapper/event_timing_controller.dart';

void main() {
  group('EventTimingController', () {
    test('null timing이면 매번 즉시 발화한다', () {
      final controller = EventTimingController();
      var count = 0;
      controller.run('e', null, () => count++);
      controller.run('e', null, () => count++);
      expect(count, 2);
      controller.dispose();
    });

    testWidgets('throttle: leading 즉시 발화 + window 내 후속은 드롭', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final controller = EventTimingController();
      var count = 0;
      const timing = EventTiming.throttle(Duration(milliseconds: 100));

      controller.run('e', timing, () => count++); // leading
      controller.run('e', timing, () => count++); // dropped
      controller.run('e', timing, () => count++); // dropped
      expect(count, 1);

      await tester.pump(const Duration(milliseconds: 101)); // window closes
      controller.run('e', timing, () => count++); // leading again
      expect(count, 2);

      controller.dispose();
    });

    testWidgets('debounce: 조용해진 뒤 마지막 이벤트만 발화한다', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final controller = EventTimingController();
      final fired = <int>[];
      const timing = EventTiming.debounce(Duration(milliseconds: 100));

      controller.run('e', timing, () => fired.add(1));
      await tester.pump(const Duration(milliseconds: 50));
      controller.run('e', timing, () => fired.add(2)); // resets the timer
      await tester.pump(const Duration(milliseconds: 50));
      controller.run('e', timing, () => fired.add(3)); // resets again
      expect(fired, isEmpty); // still within the quiet window

      await tester.pump(const Duration(milliseconds: 101));
      expect(fired, [3]); // only the last survives

      controller.dispose();
    });

    test('이벤트 키별로 독립적으로 타이밍한다', () {
      final controller = EventTimingController();
      var a = 0;
      var b = 0;
      const timing = EventTiming.throttle(Duration(milliseconds: 100));
      controller.run('a', timing, () => a++);
      controller.run('b', timing, () => b++);
      expect(a, 1);
      expect(b, 1);
      controller.dispose();
    });

    testWidgets('dispose가 pending debounce를 취소한다', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final controller = EventTimingController();
      var count = 0;
      controller.run(
        'e',
        const EventTiming.debounce(Duration(milliseconds: 100)),
        () => count++,
      );
      controller.dispose();
      await tester.pump(const Duration(milliseconds: 200));
      expect(count, 0);
    });
  });
}
