import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/custom/shared_element_widget.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/engine_presentation.dart';
import 'package:sdui_engine/src/shell/sdui_transition_page.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/presentation/presentation.dart';
import 'package:sdui_engine/src/presentation/page_transition_style.dart';

const _content = ValueKey('non-shared');
const _source = ValueKey('source');
const _destination = ValueKey('destination');

Widget _box({bool top = false, String tag = 'item', double? size}) => Align(
  alignment: top ? Alignment.bottomRight : Alignment.topLeft,
  child: SharedElement(
    key: top ? _destination : _source,
    tag: tag,
    radius: top ? 40 : 4,
    child: SizedBox(
      width: size ?? (top ? 200 : 80),
      height: size ?? (top ? 200 : 80),
      child: ColoredBox(color: top ? Colors.blue : Colors.red),
    ),
  ),
);

Page<void> _page(
  String id,
  Widget child, {
  PageTransitionContentTiming timing = PageTransitionContentTiming.duringShared,
}) => sduiTransitionPage(
  key: ValueKey(id),
  child: child,
  spec: PageTransitionSpec(type: 'fade', contentTiming: timing),
);

Future<(ValueNotifier<List<Page<void>>>, NavigatorState)> _pump(
  WidgetTester tester,
  Widget source, {
  bool reduced = false,
}) async {
  final pages = ValueNotifier<List<Page<void>>>([_page('source', source)]);
  addTearDown(pages.dispose);
  final key = GlobalKey<NavigatorState>();
  final controller = HeroController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: ValueListenableBuilder<List<Page<void>>>(
          valueListenable: pages,
          builder: (_, value, _) => HeroControllerScope(
            controller: controller,
            child: Navigator(
              key: key,
              pages: value,
              onDidRemovePage: (page) =>
                  pages.value = [...pages.value]..remove(page),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (pages, key.currentState!);
}

Future<void> _push(
  WidgetTester tester,
  ValueNotifier<List<Page<void>>> pages, {
  String tag = 'item',
  PageTransitionContentTiming timing = PageTransitionContentTiming.duringShared,
}) async {
  pages.value = [
    ...pages.value,
    _page(
      'destination',
      Stack(
        children: [
          const Positioned(
            left: 200,
            top: 200,
            child: Text('other content', key: _content),
          ),
          _box(top: true, tag: tag),
        ],
      ),
      timing: timing,
    ),
  ];
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Finder get _snapshot => find.byType(RawImage);

void main() {
  tearDown(EnginePresentation.reset);

  testWidgets(
    'push and pop fly a source snapshot with rect/radius interpolation',
    (tester) async {
      final (pages, navigator) = await _pump(tester, _box());
      await _push(tester, pages);
      expect(_snapshot, findsOneWidget);
      final rect = tester.getRect(_snapshot);
      expect(rect.width, inExclusiveRange(80, 200));
      expect(rect.left, inExclusiveRange(0, 600));
      final clip = tester.widget<ClipRRect>(
        find.ancestor(of: _snapshot, matching: find.byType(ClipRRect)).first,
      );
      expect(
        (clip.borderRadius as BorderRadius).topLeft.x,
        closeTo(4 + 36 * (rect.width - 80) / 120, 1e-6),
      );
      expect(tester.widget<RawImage>(_snapshot).image, isNotNull);
      await tester.pumpAndSettle();
      expect(_snapshot, findsNothing);
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_snapshot, findsOneWidget);
      expect(tester.getSize(_snapshot).width, inExclusiveRange(80, 200));
      await tester.pumpAndSettle();
      expect(find.byKey(_source), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('duplicate tags fail closed and recovery restores flights', (
    tester,
  ) async {
    final logs = <String>[];
    EngineLog.configure(colors: false, output: logs.add);
    final children = ValueNotifier<bool>(true);
    addTearDown(children.dispose);
    final (pages, navigator) = await _pump(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: children,
        builder: (_, duplicate, _) =>
            Stack(children: [_box(), if (duplicate) _box(top: true)]),
      ),
    );
    await _push(tester, pages);
    expect(tester.takeException(), isNull);
    expect(_snapshot, findsNothing);
    expect(logs.any((line) => line.contains('duplicate tag "item"')), isTrue);
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
    children.value = false;
    await tester.pumpAndSettle();
    await _push(tester, pages);
    expect(_snapshot, findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('source removed before pop: no flight, navigation still works', (
    tester,
  ) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    final (pages, navigator) = await _pump(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (_, show, _) => show ? _box() : const SizedBox(),
      ),
    );
    await _push(tester, pages);
    await tester.pumpAndSettle();
    visible.value = false;
    await tester.pump();
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_snapshot, findsNothing);
    await tester.pumpAndSettle();
    expect(pages.value, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  for (final mode in ['reduced', 'inactive', 'offstage', 'zero']) {
    testWidgets('$mode source does not fly', (tester) async {
      final (pages, _) = await _pump(
        tester,
        mode == 'inactive'
            ? TickerMode(enabled: false, child: _box())
            : mode == 'offstage'
            ? Offstage(child: _box())
            : _box(size: mode == 'zero' ? 0 : null),
        reduced: mode == 'reduced',
      );
      await _push(tester, pages);
      expect(_snapshot, findsNothing);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final timing in PageTransitionContentTiming.values) {
    testWidgets('$timing content timing', (tester) async {
      final (pages, _) = await _pump(tester, _box());
      await _push(tester, pages, timing: timing);
      expect(_snapshot, findsOneWidget);
      if (timing == PageTransitionContentTiming.afterShared) {
        final opacity = tester.widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.byKey(_content),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        );
        expect(opacity.opacity, 0);
      } else {
        final fade = tester.widget<FadeTransition>(
          find
              .ancestor(
                of: find.byKey(_content),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(fade.opacity.value, inExclusiveRange(0, 1));
      }
      await tester.pumpAndSettle();
      if (timing == PageTransitionContentTiming.afterShared) {
        expect(
          tester
              .widget<AnimatedOpacity>(
                find
                    .ancestor(
                      of: find.byKey(_content),
                      matching: find.byType(AnimatedOpacity),
                    )
                    .first,
              )
              .opacity,
          1,
        );
      }
    });
  }

  testWidgets('after_shared without a match reveals immediately', (
    tester,
  ) async {
    final (pages, _) = await _pump(tester, _box());
    await _push(
      tester,
      pages,
      tag: 'different',
      timing: PageTransitionContentTiming.afterShared,
    );
    expect(_snapshot, findsNothing);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find
                .ancestor(
                  of: find.byKey(_content),
                  matching: find.byType(AnimatedOpacity),
                )
                .first,
          )
          .opacity,
      1,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('bindable tag participates through the template interpreter', (
    tester,
  ) async {
    final (pages, _) = await _pump(
      tester,
      const EngineRunner(
        rootData: {'id': 'item'},
        template: {
          '_type': 'shared_element',
          'tag': r'${id}',
          'radius': 5,
          '_child': {
            '_type': 'container',
            'width': 80,
            'height': 80,
            'color': '#ff0000',
          },
        },
      ),
    );
    expect(
      tester.widget<SharedElement>(find.byType(SharedElement)).tag,
      'item',
    );
    await _push(tester, pages);
    expect(_snapshot, findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('modal surface inside a page route never participates', (
    tester,
  ) async {
    final (pages, _) = await _pump(
      tester,
      const EngineRunner(
        surfaceType: 'modal',
        template: {
          '_type': 'shared_element',
          'tag': 'item',
          '_child': {'_type': 'container', 'width': 80, 'height': 80},
        },
      ),
    );
    await _push(tester, pages);
    expect(_snapshot, findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'modal overlay is excluded and does not conflict with route tag',
    (tester) async {
      final (pages, navigator) = await _pump(tester, _box());
      final overlay = OverlayEntry(builder: (_) => _box());
      navigator.overlay!.insert(overlay);
      await tester.pump();
      await _push(tester, pages);
      expect(_snapshot, findsOneWidget);
      expect(tester.takeException(), isNull);
      overlay.remove();
      await tester.pumpAndSettle();
      overlay.dispose();
    },
  );

  testWidgets('inactive same-tag tab does not suppress the active tab', (
    tester,
  ) async {
    final (pages, _) = await _pump(
      tester,
      Stack(
        children: [
          _box(),
          TickerMode(enabled: false, child: Offstage(child: _box(top: true))),
        ],
      ),
    );
    await _push(tester, pages);
    expect(_snapshot, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'respectReducedMotion false allows flight despite device setting',
    (tester) async {
      EnginePresentation.value = const SduiPresentation(
        transitions: PageTransitionStyle(respectReducedMotion: false),
      );
      final (pages, _) = await _pump(tester, _box(), reduced: true);
      await _push(tester, pages);
      expect(_snapshot, findsOneWidget);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'duplicate destination and keyed list reorder remain fail closed',
    (tester) async {
      final order = ValueNotifier(false);
      addTearDown(order.dispose);
      final (pages, navigator) = await _pump(tester, _box());
      pages.value = [
        ...pages.value,
        _page(
          'duplicate-destination',
          ValueListenableBuilder<bool>(
            valueListenable: order,
            builder: (_, reverse, _) => Row(
              children: [
                for (final id in (reverse ? ['b', 'a'] : ['a', 'b']))
                  SharedElement(
                    key: ValueKey(id),
                    tag: 'item',
                    child: const SizedBox(width: 80, height: 80),
                  ),
              ],
            ),
          ),
        ),
      ];
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_snapshot, findsNothing);
      expect(tester.takeException(), isNull);
      order.value = true;
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_snapshot, findsNothing);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('snapshot does not mount another copy of a GlobalKey child', (
    tester,
  ) async {
    final liveKey = GlobalKey();
    final (pages, _) = await _pump(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SharedElement(
          tag: 'item',
          child: SizedBox(
            key: liveKey,
            width: 80,
            height: 80,
            child: const ColoredBox(color: Colors.red),
          ),
        ),
      ),
    );
    await _push(tester, pages);
    expect(_snapshot, findsOneWidget);
    expect(find.byKey(liveKey, skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('scrolled-away kept-alive source does not fly back on pop', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    final (pages, navigator) = await _pump(
      tester,
      SingleChildScrollView(
        controller: scroll,
        child: Column(
          children: [
            SizedBox(height: 80, child: _box()),
            const SizedBox(height: 1500),
          ],
        ),
      ),
    );
    await _push(tester, pages);
    expect(_snapshot, findsOneWidget);
    await tester.pumpAndSettle();
    scroll.jumpTo(800);
    await tester.pump();
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_snapshot, findsNothing);
    await tester.pumpAndSettle();
    expect(pages.value, hasLength(1));
  });

  testWidgets('platform view source skips raster flight', (tester) async {
    final (pages, _) = await _pump(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: SharedElement(
          tag: 'item',
          child: SizedBox(
            width: 80,
            height: 80,
            child: PlatformViewSurface(
              controller: _PlatformController(),
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              gestureRecognizers: const {},
            ),
          ),
        ),
      ),
    );
    await _push(tester, pages);
    expect(_snapshot, findsNothing);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'factory registers wrapper and invalid tag passes child through',
    (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final child = const SizedBox();
            expect(
              WidgetFactory.build(
                context,
                'shared_element',
                {'tag': ''},
                [child],
              ),
              same(child),
            );
            expect(
              WidgetFactory.build(
                context,
                'shared_element',
                {'tag': 'item'},
                [child],
              ),
              isA<SharedElement>(),
            );
            return child;
          },
        ),
      );
    },
  );
}

class _PlatformController extends PlatformViewController {
  @override
  int get viewId => 1;
  @override
  Future<void> clearFocus() async {}
  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {}
  @override
  Future<void> dispose() async {}
}
