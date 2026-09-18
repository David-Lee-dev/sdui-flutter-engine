import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/engine_registries.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/anchor_widget.dart';
import 'package:sdui_engine/src/runtime/driver/scroll_driver.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

DriverContext _ctx(Map<String, Object?> params) =>
    DriverContext(params: params, state: _NoState(), isCancelled: () => false);

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('ScrollDriver', () {
    group('run (유닛)', () {
      test('anchor 없으면 throw', () async {
        await expectLater(
          ScrollDriver(anchors: AnchorRegistry()).run(_ctx(const {})),
          throwsArgumentError,
        );
      });

      test('미등록 anchor는 no-op', () async {
        final result = await ScrollDriver(
          anchors: AnchorRegistry(),
        ).run(_ctx({'anchor': 'nope'}));
        expect(result, isNull);
      });

      test('등록됐지만 mount 안 된 anchor도 no-op', () async {
        final registry = AnchorRegistry()..register('x', GlobalKey());
        final result = await ScrollDriver(
          anchors: registry,
        ).run(_ctx({'anchor': 'x'}));
        expect(result, isNull); // currentContext null → 조용히 무동작
      });
    });

    group('run (통합)', () {
      testWidgets('등록된 anchor로 실제 스크롤한다', (tester) async {
        final registry = AnchorRegistry();
        final controller = ScrollController();
        await tester.pumpWidget(
          _wrap(
            SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  const SizedBox(height: 2000),
                  AnchorScope(
                    id: 'bottom',
                    registry: registry,
                    child: const Text('타깃'),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(controller.offset, 0.0); // 아직 위

        await ScrollDriver(
          anchors: registry,
        ).run(_ctx({'anchor': 'bottom', 'duration': 0}));
        await tester.pumpAndSettle();

        expect(controller.offset, greaterThan(0)); // ensureVisible이 스크롤함
      });
    });
  });
}
