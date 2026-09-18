import 'package:flutter/widgets.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/ir/model/action/command.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scroll_event_wrapper.dart';

class _RecordScrollDriver extends Driver {
  const _RecordScrollDriver(this.calls);

  final List<Map<String, Object?>> calls;

  @override
  String get type => 'record_scroll_event';

  @override
  Future<Object?> run(DriverContext ctx) async {
    calls.add(Map<String, Object?>.from(ctx.params));
    return null;
  }
}

Widget _subject({
  required Map<String, String> on,
  required List<Map<String, Object?>> calls,
  double endThreshold = 20,
  double startThreshold = 20,
}) {
  DriverRegistry.register(_RecordScrollDriver(calls));
  final actions = {
    for (final action in on.values)
      action: Action(
        dedupe: false,
        steps: [
          [
            Command(
              type: 'record_scroll_event',
              params: {
                'action': action,
                'offset': Expression.compile('event.offset'),
                'extent_after': Expression.compile('event.extent_after'),
              },
            ),
          ],
        ],
      ),
  };
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Scope(
      config: const ScopeConfig(state: {}),
      actions: actions,
      child: ScrollEventWrapper(
        on: on,
        endThreshold: endThreshold,
        startThreshold: startThreshold,
        child: ListView.builder(
          itemExtent: 50,
          itemCount: 30,
          itemBuilder: (_, index) => Text('$index'),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(DriverRegistry.reset);

  test('threshold는 wrapper 기본값을 쓰고 각각 재정의할 수 있다', () {
    const defaults = ScrollEventWrapper(on: {}, child: SizedBox());
    const customEnd = ScrollEventWrapper(
      on: {},
      endThreshold: 42,
      child: SizedBox(),
    );

    expect(defaults.endThreshold, 300);
    expect(defaults.startThreshold, 300);
    expect(customEnd.endThreshold, 42);
    expect(customEnd.startThreshold, 300);
  });

  testWidgets('endReached는 zone 진입에 한 번 발화하고 벗어나면 재무장한다', (tester) async {
    final calls = <Map<String, Object?>>[];
    await tester.pumpWidget(
      _subject(on: {'end_reached': 'more'}, calls: calls),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    expect(calls.single['action'], 'more');
    expect(calls.single['extent_after'] as num, lessThanOrEqualTo(20));

    await tester.drag(find.byType(ListView), const Offset(0, -30));
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(calls, hasLength(2));
  });

  testWidgets('startReached는 대칭으로 동작하고 scroll은 update마다 발화한다', (tester) async {
    final calls = <Map<String, Object?>>[];
    await tester.pumpWidget(
      _subject(on: {'start_reached': 'first', 'scroll': 'track'}, calls: calls),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(calls.where((call) => call['action'] == 'track'), isNotEmpty);
    calls.clear();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(calls.where((call) => call['action'] == 'first'), hasLength(1));
  });
}
