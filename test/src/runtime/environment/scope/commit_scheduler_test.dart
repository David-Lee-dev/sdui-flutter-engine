import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/environment/scope/commit_scheduler.dart';

void main() {
  group('FlutterCommitScheduler', () {
    testWidgets('빌드 밖(idle)에선 즉시 flush', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final scheduler = FlutterCommitScheduler();
      final flushes = <Set<String>>[];

      scheduler.schedule({'a'}, flushes.add);

      expect(flushes, [
        {'a'},
      ]);
      scheduler.dispose();
    });

    testWidgets('빌드 중이면 post-frame로 미루고 키 합집합을 한 번에', (tester) async {
      final scheduler = FlutterCommitScheduler();
      final flushes = <Set<String>>[];
      var fired = false;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            // build = persistentCallbacks 페이즈 — 미뤄져야 한다.
            if (!fired) {
              fired = true;
              scheduler.schedule({'a'}, flushes.add);
              scheduler.schedule({'b'}, flushes.add);
            }
            return const SizedBox();
          },
        ),
      );

      // 프레임 끝(post-frame)에 union 한 번.
      expect(flushes, [
        {'a', 'b'},
      ]);
      scheduler.dispose();
    });

    testWidgets('예약 뒤 dispose하면 콜백이 안 온다', (tester) async {
      final scheduler = FlutterCommitScheduler();
      final flushes = <Set<String>>[];
      var fired = false;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            if (!fired) {
              fired = true;
              scheduler.schedule({'a'}, flushes.add);
              scheduler.dispose();
            }
            return const SizedBox();
          },
        ),
      );

      expect(flushes, isEmpty);
    });
  });
}
