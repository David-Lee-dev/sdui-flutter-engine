import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/page_transition.dart';
import 'package:sdui_engine/src/runtime/transition/_base.dart';
import 'package:sdui_engine/src/runtime/transition/transition_factory.dart';
import 'package:sdui_engine/src/shell/sdui_transition_page.dart';

const _baseKey = ValueKey('base-content');
const _topKey = ValueKey('top-content');

Page<void> _engine(String id, PageTransitionSpec spec) => sduiTransitionPage(
  key: ValueKey(id),
  spec: spec,
  child: SizedBox.expand(key: id == 'base' ? _baseKey : _topKey),
);

Future<(ValueNotifier<List<Page<void>>>, NavigatorState)> _pump(
  WidgetTester tester,
  Page<void> base, {
  bool rtl = false,
}) async {
  final pages = ValueNotifier<List<Page<void>>>([base]);
  addTearDown(pages.dispose);
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: ValueListenableBuilder<List<Page<void>>>(
          valueListenable: pages,
          builder: (_, value, _) => Navigator(
            key: navigator,
            pages: value,
            onDidRemovePage: (page) =>
                pages.value = [...pages.value]..remove(page),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (pages, navigator.currentState!);
}

Finder _content(Key key) => find.byKey(key, skipOffstage: false);
double _opacity(WidgetTester tester, Key key) => tester
    .widget<FadeTransition>(
      find
          .ancestor(
            of: _content(key),
            matching: find.byType(FadeTransition, skipOffstage: false),
          )
          .first,
    )
    .opacity
    .value;
PageRoute<dynamic> _route(WidgetTester tester, Key key) =>
    ModalRoute.of(tester.element(_content(key)))! as PageRoute<dynamic>;

void main() {
  tearDown(PageTransitionFactory.reset);
  for (final (type, axis) in [
    ('fade_through', 'x'),
    ('shared_axis', 'x'),
    ('shared_axis', 'y'),
    ('shared_axis', 'z'),
  ]) {
    for (final same in [false, true]) {
      testWidgets('engine pair $type $axis same=$same push/pop', (
        tester,
      ) async {
        final (pages, navigator) = await _pump(
          tester,
          _engine('base', PageTransitionSpec(type: same ? type : 'fade')),
        );
        final spec = PageTransitionSpec(
          type: type,
          params: type == 'shared_axis' ? {'axis': axis} : {},
        );
        pages.value = [...pages.value, _engine('top', spec)];
        await tester.pump();
        for (final reverse in [false, true]) {
          if (reverse) {
            navigator.pop();
            await tester.pump();
          }
          final times = reverse ? [1.0, 0.5, 0.35, 0.0] : [0.0, 0.35, 0.5, 1.0];
          var previous = times.first;
          for (final t in times) {
            await tester.pump(
              Duration(milliseconds: ((t - previous).abs() * 300).round()),
            );
            previous = t;
            expect(
              _route(tester, _baseKey).secondaryAnimation!.value,
              closeTo(t, 1e-6),
            );
            final enter = type == 'fade_through'
                ? ((t - 0.35) / 0.65).clamp(0.0, 1.0)
                : t;
            final exit = type == 'fade_through'
                ? 1 - (t / 0.35).clamp(0.0, 1.0)
                : 1 - t;
            expect(_opacity(tester, _topKey), closeTo(enter, 1e-6));
            expect(_opacity(tester, _baseKey), closeTo(exit, 1e-6));
            final top = tester
                .renderObject<RenderBox>(_content(_topKey))
                .getTransformTo(null);
            final base = tester
                .renderObject<RenderBox>(_content(_baseKey))
                .getTransformTo(null);
            if (type == 'fade_through' || axis == 'z') {
              expect(
                top.entry(0, 0),
                closeTo(
                  type == 'fade_through' ? 0.92 + 0.08 * enter : 0.8 + 0.2 * t,
                  1e-6,
                ),
              );
              expect(
                base.entry(0, 0),
                closeTo(type == 'shared_axis' ? 1 + 0.1 * t : 1, 1e-6),
              );
            } else {
              expect(
                top.entry(axis == 'x' ? 0 : 1, 3),
                closeTo(30 * (1 - t), 1e-6),
              );
              expect(
                base.entry(axis == 'x' ? 0 : 1, 3),
                closeTo(-30 * t, 1e-6),
              );
            }
          }
          await tester.pumpAndSettle();
          if (reverse) expect(_content(_topKey), findsNothing);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final legacy in ['material', 'cupertino', 'app']) {
    for (final incoming in [true, false]) {
      for (final type in ['fade_through', 'shared_axis']) {
        testWidgets(
          '$legacy neighbour degrades engineIncoming=$incoming effect=$type',
          (tester) async {
            Page<void> legacyPage(String id) {
              final child = SizedBox.expand(
                key: id == 'base' ? _baseKey : _topKey,
              );
              return switch (legacy) {
                'material' => MaterialPage(key: ValueKey(id), child: child),
                'cupertino' => CupertinoPage(key: ValueKey(id), child: child),
                _ => _AppPage(key: ValueKey(id), child: child),
              };
            }

            final base = incoming
                ? legacyPage('base')
                : _engine('base', PageTransitionSpec(type: 'fade'));
            final (pages, navigator) = await _pump(tester, base);
            final top = incoming
                ? _engine('top', PageTransitionSpec(type: type))
                : legacyPage('top');
            pages.value = [base, top];
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 150));
            final baseRoute = _route(tester, _baseKey);
            final topRoute = _route(tester, _topKey);
            expect(baseRoute.secondaryAnimation!.value, 0);
            expect(baseRoute.receivedTransition, isNull);
            expect(topRoute.animation!.value, inExclusiveRange(0, 1));
            final matrix = tester
                .renderObject<RenderBox>(_content(_baseKey))
                .getTransformTo(null);
            expect(matrix.entry(0, 0), 1);
            expect(matrix.entry(0, 3), 0);
            if (incoming) {
              final t = topRoute.animation!.value;
              expect(
                _opacity(tester, _topKey),
                closeTo(
                  type == 'fade_through'
                      ? ((t - 0.35) / 0.65).clamp(0.0, 1.0)
                      : t,
                  1e-6,
                ),
              );
            }
            await tester.pumpAndSettle();
            navigator.pop();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 150));
            expect(baseRoute.secondaryAnimation!.value, 0);
            expect(baseRoute.receivedTransition, isNull);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final type in ['fade', 'shared_axis']) {
    testWidgets(
      'custom secondary transition is preserved or replaced by $type',
      (tester) async {
        PageTransitionFactory.register(const _SecondaryFade());
        final (pages, navigator) = await _pump(
          tester,
          _engine('base', PageTransitionSpec(type: 'secondary_fade')),
        );
        pages.value = [
          ...pages.value,
          _engine('top', PageTransitionSpec(type: type)),
        ];
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        final t = _route(tester, _topKey).animation!.value;
        final fades = tester
            .widgetList<FadeTransition>(
              find.ancestor(
                of: _content(_baseKey),
                matching: find.byType(FadeTransition, skipOffstage: false),
              ),
            )
            .toList();
        expect(fades.first.opacity.value, closeTo(1 - t, 1e-6));
        if (type == 'shared_axis') {
          expect(fades[1].opacity.value, 1);
        }
        await tester.pumpAndSettle();
        navigator.pop();
        await tester.pumpAndSettle();
        expect(_opacity(tester, _baseKey), 1);
      },
    );
  }

  testWidgets('incoming curve and RTL drive both shared_axis pages', (
    tester,
  ) async {
    final (pages, navigator) = await _pump(
      tester,
      _engine('base', PageTransitionSpec(type: 'fade', curve: 'ease_out')),
      rtl: true,
    );
    pages.value = [
      ...pages.value,
      _engine(
        'top',
        PageTransitionSpec(
          type: 'shared_axis',
          curve: 'ease_in',
          params: {'distance': 80},
        ),
      ),
    ];
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final t = Curves.easeIn.transform(_route(tester, _topKey).animation!.value);
    expect(_opacity(tester, _topKey), closeTo(t, 1e-6));
    expect(_opacity(tester, _baseKey), closeTo(1 - t, 1e-6));
    expect(
      tester.getTopLeft(_content(_topKey)).dx,
      closeTo(-80 * (1 - t), 1e-6),
    );
    expect(tester.getTopLeft(_content(_baseKey)).dx, closeTo(80 * t, 1e-6));
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'ios shared_axis swipe scrubs both pages and cancel restores',
    (tester) async {
      final (pages, navigator) = await _pump(
        tester,
        _engine('base', PageTransitionSpec(type: 'fade')),
      );
      pages.value = [
        ...pages.value,
        _engine('top', PageTransitionSpec(type: 'shared_axis')),
      ];
      await tester.pumpAndSettle();
      final drag = await tester.startGesture(const Offset(5, 200));
      await drag.moveBy(const Offset(30, 0));
      await tester.pump();
      for (final delta in [100.0, 100.0]) {
        await drag.moveBy(Offset(delta, 0));
        await tester.pump();
        final t = _route(tester, _topKey).animation!.value;
        expect(navigator.userGestureInProgress, isTrue);
        expect(t, inExclusiveRange(0.5, 1));
        expect(_opacity(tester, _topKey), closeTo(t, 1e-6));
        expect(_opacity(tester, _baseKey), closeTo(1 - t, 1e-6));
        expect(
          tester.getTopLeft(_content(_topKey)).dx,
          closeTo(30 * (1 - t), 1e-6),
        );
        expect(
          tester.getTopLeft(_content(_baseKey)).dx,
          closeTo(-30 * t, 1e-6),
        );
      }
      await tester.pump(const Duration(milliseconds: 500));
      await drag.up();
      await tester.pumpAndSettle();
      expect(navigator.userGestureInProgress, isFalse);
      expect(_content(_topKey), findsOneWidget);
      expect(_opacity(tester, _topKey), 1);
      expect(_opacity(tester, _baseKey), 0);
      expect(tester.getTopLeft(_content(_topKey)), Offset.zero);
      navigator.pop();
      await tester.pumpAndSettle();
      expect(_opacity(tester, _baseKey), 1);
      expect(tester.getTopLeft(_content(_baseKey)), Offset.zero);
    },
    variant: TargetPlatformVariant({TargetPlatform.iOS}),
  );
}

final class _AppPage extends Page<void> {
  const _AppPage({super.key, required this.child});
  final Widget child;
  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder<void>(
    settings: this,
    pageBuilder: (_, _, _) => child,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

final class _SecondaryFade extends PageTransitionEffect {
  const _SecondaryFade();
  @override
  String get type => 'secondary_fade';
  @override
  Widget build(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionSpec spec,
  ) => FadeTransition(
    opacity: secondaryAnimation.drive(Tween<double>(begin: 1, end: 0)),
    child: child,
  );
}
