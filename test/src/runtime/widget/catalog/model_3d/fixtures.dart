import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/image_source.dart';
import 'package:sdui_engine/src/contract/model_3d_source.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/model_3d/model_3d_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

final class Model3dPlay {
  const Model3dPlay(this.clip, this.loop, this.crossfade);

  final String clip;
  final bool loop;
  final Duration crossfade;
}

class FakeModel3dController extends LegacyModel3dController
    implements Model3dLookController {
  FakeModel3dController({super.fail, super.failPlay, super.gate});
  final outfits = <dynamic>[];
  void setOutfit(dynamic outfit) => outfits.add(outfit);
  final looks = <Model3dLook>[];
  @override
  void setLook(Model3dLook look) => looks.add(look);
  final scenes = <List<dynamic>>[];
  final sceneActive = <bool>[];
}

class LegacyModel3dController implements SduiModel3dController {
  LegacyModel3dController({
    this.fail = false,
    this.failPlay = false,
    this.gate,
  });

  final bool fail;
  final bool failPlay;

  /// Holds [initialize] open until completed, to observe the loading phase.
  final Completer<void>? gate;
  @override
  final List<String> clips = const ['Idle', 'Jump', 'Wave'];
  final plays = <Model3dPlay>[];
  final cameras = <Model3dCamera>[];
  final poses = <(String, Duration)>[];
  final _listeners = <VoidCallback>[];
  bool disposed = false;
  int stops = 0;
  int initializations = 0;
  String? _clip;
  int _completions = 0;

  @override
  Future<void> initialize() async {
    initializations++;
    await gate?.future;
    if (fail) throw StateError('load failed');
  }

  @override
  Future<void> play(
    String clip, {
    required bool loop,
    Duration crossfade = Duration.zero,
  }) async {
    plays.add(Model3dPlay(clip, loop, crossfade));
    _clip = clip;
    if (failPlay) throw StateError('play failed');
  }

  /// Simulates the renderer reporting the end of a non-looping clip.
  void finish() {
    _completions++;
    for (final listener in [..._listeners]) {
      listener();
    }
  }

  @override
  Future<void> stop() async => stops++;

  @override
  void setCamera(Model3dCamera camera) => cameras.add(camera);

  /// Every clip lasts a second, except `Wave` at six.
  @override
  Duration? clipDuration(String clip) =>
      !clips.contains(clip) ? null : Duration(seconds: clip == 'Wave' ? 6 : 1);

  @override
  void setPose(String clip, Duration time) => poses.add((clip, time));

  double get seconds =>
      poses.last.$2.inMicroseconds / Duration.microsecondsPerSecond;

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  Model3dPlayback get playback =>
      Model3dPlayback(clip: _clip, isPlaying: true, completions: _completions);

  @override
  Widget buildView() => const SizedBox.expand(key: Key('model-view'));

  @override
  Future<void> dispose() async => disposed = true;
}

class UnadvertisedLookController extends LegacyModel3dController {
  final looks = <Model3dLook>[];
  void setLook(Model3dLook look) => looks.add(look);
}

final class FixedModel3dSource extends Model3dSource {
  FixedModel3dSource(this.controller);
  final SduiModel3dController controller;
  @override
  Future<SduiModel3dController> controllerFor(Model3dRequest request) async =>
      controller;
}

class MotionModel3dController extends FakeModel3dController
    implements Model3dMotionController {
  final morphs = <Map<String, double>>[];
  @override
  void setMorphs(Map<String, double> weights) => morphs.add(Map.of(weights));
  final gaze = <dynamic>[];
  @override
  void setLookAt(dynamic value) => gaze.add(value);
  final layers = <dynamic>[];
  final layerFades = <Duration>[];
  @override
  int layerCompletions = 0;
  @override
  void setLayer(dynamic value, {Duration crossfade = Duration.zero}) {
    layers.add(value);
    layerFades.add(crossfade);
  }

  void finishLayer() {
    layerCompletions++;
    for (final listener in [..._listeners]) {
      listener();
    }
  }

  final motionActive = <bool>[];
  @override
  void setMotionActive(bool active) => motionActive.add(active);
}

final class SceneModel3dController extends FakeModel3dController
    implements Model3dSceneController, Model3dOutfitController {
  SceneModel3dController({super.fail, super.failPlay, super.gate});

  @override
  void setScene(List<Model3dSceneItem> scene, {bool active = true}) {
    scenes.add(scene);
    sceneActive.add(active);
  }
}

class TapModel3dController extends FakeModel3dController
    implements Model3dTapController {
  Model3dHit? hit = const Model3dHit(node: 'Head', material: 'Skin');
  final picks = <Offset>[];
  @override
  Future<Model3dHit?> hitTest(Offset position) async {
    picks.add(position);
    return hit;
  }
}

final class RecordingModel3dSource extends Model3dSource {
  RecordingModel3dSource({
    this.fail = false,
    this.failPlay = false,
    this.gate,
    this.frameRate,
    this.sceneSupported = false,
    this.motionSupported = false,
    this.tapSupported = false,
  });

  @override
  final int? frameRate;

  /// Whether controllers created from now on fail to load.
  bool fail;
  final bool failPlay;
  final bool sceneSupported;
  final bool motionSupported;
  final bool tapSupported;
  final Completer<void>? gate;
  final requests = <Model3dRequest>[];
  final controllers = <FakeModel3dController>[];

  @override
  Future<SduiModel3dController> controllerFor(Model3dRequest request) async {
    requests.add(request);
    final controller = tapSupported
        ? TapModel3dController()
        : motionSupported
        ? MotionModel3dController()
        : sceneSupported
        ? SceneModel3dController(fail: fail, failPlay: failPlay, gate: gate)
        : FakeModel3dController(fail: fail, failPlay: failPlay, gate: gate);
    controllers.add(controller);
    return controller;
  }
}

final class TextModel3dImageSource implements ImageSource {
  const TextModel3dImageSource();

  @override
  ImageResult resolve(ImageRequest request) =>
      ReadyImage(Text('poster:${request.src}'));
}

final class Model3dSink implements ActionSink {
  final calls = <(String, Object?)>[];

  @override
  void handle(String action, {Object? event, ActionInvocation? invocation}) {
    calls.add((action, event));
  }

  @override
  Future<void> handleAwaitable(
    String action, {
    Object? event,
    ActionInvocation? invocation,
  }) async => handle(action, event: event);
}

const model3dStates = {
  'idle': {'clip': 'Idle', 'loop': true},
  'jump': {'clip': 'Jump', 'next': 'idle'},
  'wave': {'clip': 'Wave'},
  'dance': {'clip': 'Dance'},
};

double model3dPosterOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

Future<void> pumpModel3d(
  WidgetTester tester,
  Map<String, Object?> props, {
  ActionSink? dispatch,
  bool shown = true,
}) async {
  await tester.pumpWidget(
    TickerMode(
      enabled: shown,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Builder(
            builder: (context) =>
                Model3dWidget.build(context, props, const [], dispatch),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
