import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_widget.dart';

import 'model_3d/fixtures.dart';

void main() {
  setUp(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
    ImageSourceRegistry.install(const TextModel3dImageSource());
  });
  tearDown(() {
    Model3dSourceRegistry.reset();
    ImageSourceRegistry.reset();
  });

  testWidgets('ignores drags cancelled long and multiple pointers', (
    tester,
  ) async {
    final source = RecordingModel3dSource(tapSupported: true);
    Model3dSourceRegistry.install(source);
    final sink = Model3dSink();
    await pumpModel3d(tester, const {
      'src': 'a.glb',
      'width': 200,
      'height': 200,
      'on_tap_model': 'picked',
    }, dispatch: sink);
    await tester.pumpAndSettle();
    final point = tester.getCenter(find.byKey(const Key('model-view')));
    final drag = await tester.startGesture(point);
    await drag.moveBy(const Offset(40, 0));
    await drag.up();
    final cancelled = await tester.startGesture(point);
    await cancelled.cancel();
    final long = await tester.startGesture(point);
    await tester.pump(const Duration(seconds: 1));
    await long.up(timeStamp: const Duration(seconds: 1));
    final first = await tester.startGesture(point, pointer: 10);
    final second = await tester.startGesture(
      point + const Offset(10, 0),
      pointer: 11,
    );
    await second.up();
    await first.up();
    await tester.pump();
    expect((source.controllers.single as TapModel3dController).picks, isEmpty);
    expect(sink.calls, isEmpty);
  });

  testWidgets(
    'removed highlight prop preserves ancestor taps without picking',
    (tester) async {
      final source = RecordingModel3dSource(tapSupported: true);
      Model3dSourceRegistry.install(source);
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: Center(
              child: Builder(
                builder: (context) => Model3dWidget.build(
                  context,
                  const {
                    'src': 'a.glb',
                    'width': 200,
                    'height': 200,
                    'highlight_on_tap': {'duration': 200},
                  },
                  const [],
                  null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(400, 300));
      await tester.pump();
      expect(taps, 1);
      expect(
        (source.controllers.single as TapModel3dController).picks,
        isEmpty,
      );
    },
  );

  testWidgets('removed appearance props leave the retained look unchanged', (
    tester,
  ) async {
    final source = RecordingModel3dSource(tapSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'a.glb',
      'shading': 'unlit',
      'outline': {
        'color': '#123456',
        'width': 3,
        'nodes': ['Head'],
      },
      'highlight_on_tap': {'color': '#abcdef', 'width': 4, 'duration': 500},
    });
    final c = source.controllers.single as TapModel3dController;
    expect(c.looks.last, const Model3dLook());
    await pumpModel3d(tester, const {'src': 'a.glb'});
    expect(c.looks.last, const Model3dLook());
    expect(await FakeModel3dController().hitTest(Offset.zero), isNull);
  });

  testWidgets('absent tap action preserves ancestor taps', (tester) async {
    final source = RecordingModel3dSource(tapSupported: true);
    Model3dSourceRegistry.install(source);
    var taps = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => taps++,
          child: Center(
            child: Builder(
              builder: (context) => Model3dWidget.build(
                context,
                const {'src': 'a.glb', 'width': 200, 'height': 200},
                const [],
                null,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(taps, 1);
    expect((source.controllers.single as TapModel3dController).picks, isEmpty);
  });

  testWidgets('model hit dispatches node and material; miss does nothing', (
    tester,
  ) async {
    final source = RecordingModel3dSource(tapSupported: true);
    Model3dSourceRegistry.install(source);
    final sink = Model3dSink();
    await pumpModel3d(tester, const {
      'src': 'a.glb',
      'width': 200,
      'height': 200,
      'on_tap_model': 'picked',
    }, dispatch: sink);
    await tester.pumpAndSettle();
    final c = source.controllers.single as TapModel3dController;
    await tester.tapAt(tester.getCenter(find.byKey(const Key('model-view'))));
    await tester.pump();
    expect(sink.calls.single.$1, 'picked');
    expect(sink.calls.single.$2, {'node': 'Head', 'material': 'Skin'});
    c.hit = null;
    await tester.tapAt(tester.getCenter(find.byKey(const Key('model-view'))));
    await tester.pump();
    expect(c.picks, hasLength(2));
    expect(sink.calls, hasLength(1));
  });
}
