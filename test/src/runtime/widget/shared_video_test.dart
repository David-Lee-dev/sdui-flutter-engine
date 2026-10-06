import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/video_source.dart';
import 'package:sdui_engine/src/runtime/media/video_source_registry.dart';
import 'package:sdui_engine/src/runtime/media/shared_video_session.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shared_element_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/video_widget.dart';
import 'package:sdui_engine/src/runtime/widget/contract/action_sink.dart';

class _Source implements VideoSource {
  final controllers = <_Controller>[];
  bool fail = false;
  Completer<void>? initialization;

  @override
  Future<SduiVideoController> controllerFor(VideoRequest request) async {
    final controller = _Controller(fail, initialization);
    controllers.add(controller);
    return controller;
  }
}

class _Controller implements SduiVideoController {
  _Controller(this.fail, this.initialization);
  final bool fail;
  final Completer<void>? initialization;
  final listeners = <VoidCallback>{};
  int initializes = 0;
  int plays = 0;
  int disposes = 0;
  int viewCalls = 0;
  int mountedViews = 0;
  int surfaceMounts = 0;
  int maxMountedViews = 0;
  final observedPositions = <Duration>[];
  Duration position = const Duration(seconds: 5);
  bool playing = false;
  bool loop = true;
  double volume = 1;

  @override
  Future<void> initialize() async {
    initializes++;
    await initialization?.future;
    if (fail) throw StateError('init failed');
  }

  @override
  Future<void> dispose() async {
    disposes++;
  }

  @override
  Future<void> play() async {
    plays++;
    playing = true;
  }

  @override
  Future<void> pause() async {
    playing = false;
  }

  @override
  Future<void> setLooping(bool looping) async {
    loop = looping;
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
  }

  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove(listener);
  }

  @override
  VideoPlayback get playback => VideoPlayback(
    width: 100,
    height: 100,
    duration: const Duration(seconds: 12),
    position: position,
    isPlaying: playing,
  );
  void end() {
    playing = false;
    position = const Duration(seconds: 12);
    for (final listener in listeners.toList()) {
      listener();
    }
  }

  @override
  Widget buildView() {
    viewCalls++;
    observedPositions.add(position);
    return _Surface(this);
  }
}

class _Surface extends StatefulWidget {
  const _Surface(this.controller);
  final _Controller controller;
  @override
  State<_Surface> createState() => _SurfaceState();
}

class _SurfaceState extends State<_Surface> {
  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    c.mountedViews++;
    c.surfaceMounts++;
    if (c.mountedViews > c.maxMountedViews) c.maxMountedViews = c.mountedViews;
  }

  @override
  void dispose() {
    widget.controller.mountedViews--;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.green);
}

class _Sink implements ActionSink {
  final calls = <String>[];
  @override
  void handle(String actionId, {Object? event, ActionInvocation? invocation}) {
    calls.add(actionId);
  }

  @override
  Future<void> handleAwaitable(
    String actionId, {
    Object? event,
    ActionInvocation? invocation,
  }) async {
    handle(actionId);
  }
}

Widget _video({
  String src = 'counter.mp4',
  String tag = 'video',
  bool destination = false,
  _Sink? sink,
}) => Align(
  alignment: destination ? Alignment.bottomRight : Alignment.topLeft,
  child: SharedElement(
    tag: tag,
    radius: destination ? 16 : 4,
    child: SizedBox(
      width: destination ? 250 : 100,
      height: destination ? 250 : 100,
      child: Builder(
        builder: (context) => VideoWidget.build(
          context,
          {
            'src': src,
            'autoplay': true,
            'loop': false,
            'muted': !destination,
            'on_end': destination ? 'destination-end' : 'source-end',
            'show_controls': true,
          },
          const [],
          sink,
        ),
      ),
    ),
  ),
);

Future<NavigatorState> _pump(WidgetTester tester, {_Sink? sink}) async {
  final key = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: key,
      home: _video(sink: sink),
    ),
  );
  await tester.pumpAndSettle();
  return key.currentState!;
}

Route<void> _route({_Sink? sink, String src = 'counter.mp4'}) =>
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => _video(destination: true, sink: sink, src: src),
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
Future<void> _push(
  WidgetTester tester,
  NavigatorState navigator, {
  _Sink? sink,
  String src = 'counter.mp4',
}) async {
  unawaited(navigator.push(_route(sink: sink, src: src)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  late _Source source;
  setUp(() {
    source = _Source();
    VideoSourceRegistry.install(source);
  });
  tearDown(VideoSourceRegistry.reset);

  testWidgets('same src with different tags autoplays independent leases', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Expanded(child: _video(tag: 'video-1')),
            Expanded(child: _video(tag: 'video-2')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.controllers, hasLength(2));
    final scopes = tester
        .widgetList<SharedVideoScope>(find.byType(SharedVideoScope))
        .toList();
    expect(scopes, hasLength(2));
    final first = scopes[0].leases.single;
    final second = scopes[1].leases.single;
    expect(identical(first.session, second.session), isFalse);
    expect(first.session.ownsPlayback(first), isTrue);
    expect(second.session.ownsPlayback(second), isTrue);
    expect(source.controllers.map((c) => c.plays), everyElement(1));
    expect(source.controllers.map((c) => c.playing), everyElement(isTrue));
    await tester.pumpWidget(const SizedBox());
    expect(source.controllers.map((c) => c.disposes), everyElement(1));
  });

  testWidgets(
    'handoff retains position and pop restores config and end owner',
    (tester) async {
      final sink = _Sink();
      final navigator = await _pump(tester, sink: sink);
      final c = source.controllers.single;
      expect(c.volume, 0);
      await _push(tester, navigator, sink: sink);
      expect(source.controllers, hasLength(1));
      expect(c.initializes, 1);
      expect(c.plays, 1);
      expect(c.position, const Duration(seconds: 5));
      expect(c.volume, 1);
      expect(c.listeners, hasLength(1));
      expect(find.byType(GestureDetector, skipOffstage: false), findsOneWidget);
      c.end();
      expect(sink.calls, ['destination-end']);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();
      expect(c.volume, 0);
      expect(find.byType(GestureDetector, skipOffstage: false), findsOneWidget);
      c.end();
      expect(sink.calls, ['destination-end', 'source-end']);
      expect(c.disposes, 0);
      await tester.pumpWidget(const SizedBox());
      expect(c.disposes, 1);
      expect(c.listeners, isEmpty);
    },
  );

  testWidgets(
    'flight builds a live view of the shared controller without snapshots',
    (tester) async {
      final navigator = await _pump(tester);
      final c = source.controllers.single;
      await _push(tester, navigator);
      expect(find.byType(RawImage), findsNothing);
      expect(find.byType(_Surface), findsOneWidget);
      expect(tester.getSize(find.byType(_Surface)).width, 100);
      final clip = find.ancestor(
        of: find.byType(_Surface),
        matching: find.byType(ClipRRect),
      );
      expect(clip, findsOneWidget);
      expect(tester.getSize(clip).width, inExclusiveRange(100, 250));
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(RawImage), findsNothing);
      expect(find.byType(_Surface), findsOneWidget);
      await tester.pumpAndSettle();
      expect(c.viewCalls, greaterThan(1));
      expect(c.maxMountedViews, greaterThan(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(c.mountedViews, 0);
      expect(c.disposes, 1);
    },
  );

  testWidgets(
    'every push and pop frame retains playback and a visible surface',
    (tester) async {
      final navigator = await _pump(tester);
      final c = source.controllers.single;
      unawaited(navigator.push(_route()));
      await tester.pump();
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          c.mountedViews,
          greaterThanOrEqualTo(1),
          reason: 'push frame $frame',
        );
        c.position += const Duration(milliseconds: 50);
        expect(c.initializes, 1);
        expect(tester.takeException(), isNull);
        expect(find.byType(_Surface), findsOneWidget);
      }
      navigator.pop();
      await tester.pump();
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          c.mountedViews,
          greaterThanOrEqualTo(1),
          reason: 'pop frame $frame',
        );
        c.position += const Duration(milliseconds: 50);
        expect(c.initializes, 1);
        expect(tester.takeException(), isNull);
        expect(find.byType(_Surface), findsOneWidget);
      }
      expect(c.position, const Duration(milliseconds: 6200));
      expect(c.observedPositions, isNotEmpty);
      for (var i = 1; i < c.observedPositions.length; i++) {
        expect(
          c.observedPositions[i],
          greaterThanOrEqualTo(c.observedPositions[i - 1]),
        );
      }
      expect(source.controllers, hasLength(1));
      expect(c.surfaceMounts, greaterThan(1));
      expect(c.viewCalls, greaterThan(1));
      await tester.pumpWidget(const SizedBox());
      expect(c.disposes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'flight reference retains controller after every route lease leaves',
    (tester) async {
      await _pump(tester);
      final scope = tester.widget<SharedVideoScope>(
        find.byType(SharedVideoScope),
      );
      final release = scope.leases.single.session.retainFlight();
      final c = source.controllers.single;
      await tester.pumpWidget(const SizedBox());
      expect(c.disposes, 0);
      release();
      release();
      expect(c.disposes, 1);
      expect(c.listeners, isEmpty);
    },
  );

  testWidgets('same tag with different src uses independent controllers', (
    tester,
  ) async {
    final navigator = await _pump(tester);
    await _push(tester, navigator, src: 'other.mp4');
    expect(source.controllers, hasLength(2));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    expect(source.controllers.map((c) => c.disposes), everyElement(1));
  });

  testWidgets('initialization failure disposes once and never mounts video', (
    tester,
  ) async {
    source.fail = true;
    final navigator = await _pump(tester);
    await _push(tester, navigator);
    await tester.pumpAndSettle();
    expect(source.controllers, hasLength(1));
    expect(source.controllers.single.disposes, 1);
    expect(find.byType(_Surface, skipOffstage: false), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(source.controllers.single.disposes, 1);
  });

  testWidgets('route removal during flight releases flight and both leases', (
    tester,
  ) async {
    final navigator = await _pump(tester);
    await _push(tester, navigator);
    final c = source.controllers.single;
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(c.disposes, 1);
    expect(c.mountedViews, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removal during pending initialization disposes only once', (
    tester,
  ) async {
    source.initialization = Completer<void>();
    await _pump(tester);
    final c = source.controllers.single;
    await tester.pumpWidget(const SizedBox());
    source.initialization!.complete();
    await tester.pump();
    expect(c.initializes, 1);
    expect(c.disposes, 1);
    expect(c.listeners, isEmpty);
  });
  testWidgets('cancelled swipe retains destination owner and releases flight', (
    tester,
  ) async {
    final sink = _Sink();
    final navigator = await _pump(tester, sink: sink);
    unawaited(
      navigator.push(
        CupertinoPageRoute<void>(
          builder: (_) => _video(destination: true, sink: sink),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final c = source.controllers.single;
    final gesture = await tester.startGesture(const Offset(1, 300));
    await gesture.moveBy(const Offset(150, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(navigator.userGestureInProgress, isTrue);
    c.position += const Duration(seconds: 1);
    expect(c.initializes, 1);
    expect(c.listeners, hasLength(1));
    expect(find.byType(_Surface), findsOneWidget);
    expect(find.byType(RawImage), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isTrue);
    expect(c.position, const Duration(seconds: 6));
    c.end();
    expect(sink.calls, ['destination-end']);
    expect(c.volume, 1);
    expect(c.disposes, 0);
    expect(c.maxMountedViews, greaterThan(1));
    expect(find.byType(_Surface), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(c.volume, 0);
    await tester.pumpWidget(const SizedBox());
    expect(c.disposes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate source tags never hand off to destination', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: Row(
          children: [
            Expanded(child: _video()),
            Expanded(child: _video()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.controllers, hasLength(2));
    await _push(tester, key.currentState!);
    await tester.pumpAndSettle();
    expect(source.controllers, hasLength(3));
    await tester.pumpWidget(const SizedBox());
    expect(source.controllers.map((c) => c.disposes), everyElement(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate destination tags split all controllers', (
    tester,
  ) async {
    final navigator = await _pump(tester);
    unawaited(
      navigator.push(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => Row(
            children: [
              Expanded(child: _video(destination: true)),
              Expanded(child: _video(destination: true)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.controllers, hasLength(3));
    await tester.pumpWidget(const SizedBox());
    expect(source.controllers.map((c) => c.disposes), everyElement(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing only destination returns source without disposing', (
    tester,
  ) async {
    final navigator = await _pump(tester);
    final route = _route();
    unawaited(navigator.push(route));
    await tester.pumpAndSettle();
    final c = source.controllers.single;
    navigator.removeRoute(route);
    await tester.pumpAndSettle();
    expect(c.disposes, 0);
    expect(c.volume, 0);
    expect(find.byType(_Surface), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(c.disposes, 1);
  });
}
