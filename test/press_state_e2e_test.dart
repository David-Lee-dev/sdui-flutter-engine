import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';

import 'support/engine_harness.dart';

/// `_on: { tap: { do, pressed_as } }` (0.9.0): a bool variable that is true
/// while the tap is held, readable by the node's own props and descendants.
Map<String, Object?> _screen(Map<String, Object?> tap, {bool scroll = false}) {
  final button = {
    '_type': 'container',
    'width': 120,
    'height': 60,
    'color': r'${down ? "#FF000000" : "#FFFFFFFF"}',
    '_on': {
      'tap': {'do': 'inc', 'pressed_as': 'down', ...tap},
    },
    '_child': {'_type': 'text', 'value': r'${down ? "D" : "U"}${n}'},
  };
  return {
    '_type': 'column',
    '_scope': {
      '_state': {'n': 0},
      '_action': {
        'inc': {'_type': 'set', 'n': r'${n + 1}'},
      },
    },
    '_children': [
      if (scroll)
        {
          '_type': 'sizedbox',
          'height': 200,
          '_child': {
            '_type': 'list_view',
            '_children': [
              button,
              for (var i = 0; i < 10; i++) {'_type': 'sizedbox', 'height': 100},
            ],
          },
        }
      else
        button,
    ],
  };
}

Color? _color(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .ancestor(of: find.byType(Text), matching: find.byType(Container))
        .first,
  );
  return container.color ?? (container.decoration as BoxDecoration?)?.color;
}

void main() {
  late List<SduiError> errors;
  setUp(() {
    errors = [];
    EngineErrors.observer = _Capture(errors);
  });
  tearDown(EngineErrors.reset);

  for (final ripple in [true, false]) {
    testWidgets('ripple $ripple: 누르는 동안 자기 props와 자손이 true, 떼면 false', (
      tester,
    ) async {
      await pumpEngineTemplate(tester, _screen({'ripple': ripple}));
      expect(find.text('U0'), findsOneWidget);
      expect(_color(tester), const Color(0xFFFFFFFF));

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('U0')),
      );
      await tester.pump();
      expect(find.text('D0'), findsOneWidget);
      expect(_color(tester), const Color(0xFF000000));

      await gesture.up();
      await tester.pump();
      expect(find.text('U1'), findsOneWidget);
      expect(_color(tester), const Color(0xFFFFFFFF));
      await tester.pumpAndSettle();
      expect(errors, isEmpty);
    });
  }

  testWidgets('포인터 취소는 false', (tester) async {
    await pumpEngineTemplate(tester, _screen(const {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('U0')),
    );
    await tester.pump();
    expect(find.text('D0'), findsOneWidget);
    await gesture.cancel();
    await tester.pump();
    expect(find.text('U0'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('터치 슬롭을 넘게 움직이면 누른 채여도 false', (tester) async {
    await pumpEngineTemplate(tester, _screen(const {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('U0')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(4, 0));
    await tester.pump();
    expect(find.text('D0'), findsOneWidget);
    await gesture.moveBy(const Offset(kTouchSlop + 2, 0));
    await tester.pump();
    expect(find.text('U0'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('U0'), findsOneWidget);
  });

  testWidgets('스크롤이 제스처를 가져가면 false', (tester) async {
    await pumpEngineTemplate(tester, _screen(const {}, scroll: true));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('U0')),
    );
    await tester.pump(kPressTimeout);
    expect(find.text('D0'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    expect(find.text('U0'), findsOneWidget);
    expect(
      tester.widget<ListView>(find.byType(ListView)).controller?.offset ??
          Scrollable.of(tester.element(find.text('U0'))).position.pixels,
      greaterThan(0),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('U0'), findsOneWidget);
  });

  testWidgets('두 번째 손가락은 상태를 바꾸지 않는다', (tester) async {
    await pumpEngineTemplate(tester, _screen(const {}));
    final center = tester.getCenter(find.text('U0'));
    final first = await tester.startGesture(center, pointer: 1);
    await tester.pump();
    final second = await tester.startGesture(center, pointer: 2);
    await second.up();
    await tester.pump();
    expect(find.textContaining('D'), findsOneWidget);
    await first.up();
    await tester.pumpAndSettle();
    expect(find.textContaining('U'), findsOneWidget);
  });

  testWidgets('누른 채 노드가 사라져도 예외·보고가 없다', (tester) async {
    await pumpEngineTemplate(tester, _screen(const {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('U0')),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(errors, isEmpty);
  });
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}
