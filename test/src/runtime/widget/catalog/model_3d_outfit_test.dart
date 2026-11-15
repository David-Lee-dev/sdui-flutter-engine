import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/media/image_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/model_3d_source_registry.dart';

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

  testWidgets('transition names and invalid outfit values use safe defaults', (
    tester,
  ) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    for (final name in ['cut', 'pop', 'drop', 'dissolve', 'unknown']) {
      await pumpModel3d(tester, {
        'src': 'char.glb',
        'outfit': {
          'show': false,
          'hide': 'bad',
          'colors': 42,
          'attach': ['bad'],
          'transition': name,
          'transition_duration': -1,
        },
      });
      final outfit = source.controllers.single.outfits.last as Model3dOutfit;
      expect(outfit.show, isEmpty);
      expect(outfit.hide, isEmpty);
      expect(outfit.colors, isEmpty);
      expect(outfit.attach, isEmpty);
      expect(outfit.transition.name, name == 'unknown' ? 'pop' : name);
      expect(outfit.duration, const Duration(milliseconds: 300));
    }
  });

  testWidgets('absent outfit sends one empty snapshot and legacy ignores it', (
    tester,
  ) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {'src': 'char.glb'});
    await pumpModel3d(tester, const {'src': 'char.glb'});
    expect(source.controllers.single.outfits, [Model3dOutfit()]);
    final legacy = FakeModel3dController();
    (legacy as SduiModel3dController).setOutfit(Model3dOutfit(show: ['shirt']));
    expect(legacy.outfits, isEmpty);
  });

  testWidgets('changes outfit without reloading', (tester) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'outfit': {
        'hide': ['shirt'],
      },
    });
    final controller = source.controllers.single;
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'outfit': {
        'show': ['shirt'],
      },
    });
    expect(controller.outfits, hasLength(2));
    expect((controller.outfits.last as Model3dOutfit).show, ['shirt']);
    expect(source.requests, hasLength(1));
    expect(controller.initializations, 1);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'outfit': {
        'show': ['shirt'],
      },
    });
    expect(controller.outfits, hasLength(2));
  });

  testWidgets('parses outfit and drops invalid entries', (tester) async {
    final source = RecordingModel3dSource(sceneSupported: true);
    Model3dSourceRegistry.install(source);
    await pumpModel3d(tester, const {
      'src': 'char.glb',
      'outfit': {
        'show': ['shirt', 4, ''],
        'hide': ['body', false],
        'colors': {'cloth': '#FF0000', 'bad': 'invalid'},
        'attach': {'Head': 'hat.glb', 'Hand': null, 'bad': 42},
        'transition': 'drop',
        'transition_duration': 450,
      },
    });
    expect(source.controllers.single.outfits, hasLength(1));
    final outfit = source.controllers.single.outfits.single as Model3dOutfit;
    expect(outfit.show, ['shirt']);
    expect(outfit.hide, ['body']);
    expect(outfit.colors, {'cloth': const Color(0xFFFF0000)});
    expect(outfit.attach, {'Head': 'hat.glb', 'Hand': null});
    expect(outfit.transition.name, 'drop');
    expect(outfit.duration, const Duration(milliseconds: 450));
    expect(() => outfit.show.add('bad'), throwsUnsupportedError);
    expect(() => outfit.attach['new'] = 'bad', throwsUnsupportedError);
  });
}
