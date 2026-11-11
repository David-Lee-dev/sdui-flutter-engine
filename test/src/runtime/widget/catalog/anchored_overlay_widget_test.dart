import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';

/// `anchored_overlay` + `anchored` at the template boundary: a screen whose
/// badge opens a dim layer in the nearest Overlay with content placed at the
/// badge's on-screen rect, reading and changing the screen's state.

const _requires = ['anchored_overlay_v1', 'presence_v1'];

/// A screen: a status line, then a scroll view holding `top` px of space,
/// the `badge` anchor (60×20, tap opens) and [overlay].
Map<String, Object?> _screen(
  Map<String, Object?> overlay, {
  double header = 40,
  double top = 300,
}) => {
  '_requires': _requires,
  '_type': 'column',
  '_scope': {
    '_state': {'open': false, 'picked': 'none', 'label': 'hello'},
    '_action': {
      'open': {'_type': 'set', 'open': true},
      'close': {'_type': 'set', 'open': false},
      'pick': {'_type': 'set', 'picked': 'card'},
    },
  },
  '_children': [
    {
      '_type': 'sizedbox',
      'height': header,
      '_child': {'_type': 'text', 'value': r'state ${open} ${picked}'},
    },
    {
      '_type': 'expanded',
      '_child': {
        '_type': 'single_child_scroll_view',
        '_child': {
          '_type': 'column',
          '_children': [
            {'_type': 'sizedbox', 'height': top},
            {
              '_type': 'anchor',
              'id': 'badge',
              '_child': {
                '_type': 'sizedbox',
                '_key': 'badge',
                'width': 60,
                'height': 20,
                '_on': {'tap': 'open'},
                '_child': {'_type': 'text', 'value': 'badge'},
              },
            },
            {'_type': 'sizedbox', 'height': 1200},
            overlay,
          ],
        },
      },
    },
  ],
};

Map<String, Object?> _overlay(
  List<Map<String, Object?>> children, {
  Map<String, Object?> props = const {},
}) => {
  '_type': 'anchored_overlay',
  '_if': r'${open}',
  '_presence': true,
  'anchor': 'badge',
  'on_dismiss': 'close',
  ...props,
  '_children': children,
};

Map<String, Object?> _box(
  String key, {
  double width = 60,
  double height = 20,
}) => {'_type': 'sizedbox', '_key': key, 'width': width, 'height': height};

Map<String, Object?> _anchored(
  Map<String, Object?> child, {
  String placement = 'over',
  Map<String, Object?> extra = const {},
}) => {'_type': 'anchored', 'placement': placement, ...extra, '_child': child};

Widget _app(
  Map<String, Object?> template, {
  VoidCallback? onBar,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  home: Directionality(
    textDirection: direction,
    child: Stack(
      children: [
        Positioned.fill(
          child: Material(child: EngineRunner(template: template)),
        ),
        if (onBar != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: GestureDetector(
              onTap: onBar,
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
      ],
    ),
  ),
);

Finder _key(String key) => find.byKey(ValueKey(key));

/// The opacity the outermost [Opacity] under [key] applies: a node's key
/// wraps its `_motion` layers.
double _opacity(WidgetTester tester, String key) => tester
    .widget<Opacity>(
      find.descendant(of: _key(key), matching: find.byType(Opacity)).first,
    )
    .opacity;

/// [node]'s rect in logical screen pixels: the semantics tree reports
/// physical pixels.
Rect _semanticsRect(WidgetTester tester, SemanticsNode node) {
  var rect = node.rect;
  for (SemanticsNode? n = node; n != null; n = n.parent) {
    final transform = n.transform;
    if (transform != null) rect = MatrixUtils.transformRect(transform, rect);
  }
  final ratio = tester.view.devicePixelRatio;
  return Rect.fromLTRB(
    rect.left / ratio,
    rect.top / ratio,
    rect.right / ratio,
    rect.bottom / ratio,
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('badge'));
  await tester.pump();
}

void main() {
  testWidgets('A1 places content at the anchor rect of a scrolled page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _screen(
          _overlay([
            _anchored(_box('hl')),
            _anchored(
              _box('card', width: 120, height: 30),
              placement: 'below',
              extra: {'align': 'start'},
            ),
          ]),
        ),
      ),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    final badge = tester.getRect(_key('badge'));

    await _open(tester);
    await tester.pumpAndSettle();

    expect(tester.getRect(_key('hl')), badge);
    final card = tester.getRect(_key('card'));
    expect(card.left, badge.left);
    expect(card.top, badge.bottom);
  });

  testWidgets('A2 dim and content paint above a bar beside the screen', (
    tester,
  ) async {
    var barTaps = 0;
    await tester.pumpWidget(
      _app(_screen(_overlay([_anchored(_box('hl'))])), onBar: () => barTaps++),
    );
    await tester.tapAt(const Offset(400, 570));
    expect(barTaps, 1);

    await _open(tester);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(400, 570));
    await tester.pumpAndSettle();

    expect(barTaps, 1);
  });

  testWidgets('A3 the template highlight is drawn and hit above the dim', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _screen(
          _overlay([
            _anchored({
              ..._box('hl'),
              '_on': {'tap': 'pick'},
              '_child': {'_type': 'text', 'value': 'lit'},
            }),
          ]),
        ),
      ),
    );
    final badge = tester.getRect(_key('badge'));
    await _open(tester);
    await tester.pumpAndSettle();

    expect(tester.getRect(_key('hl')), badge);
    await tester.tapAt(badge.center);
    await tester.pumpAndSettle();
    expect(find.text('state true card'), findsOneWidget);
  });

  testWidgets('A4 overlay content reads screen state and dispatches actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _screen(
          _overlay([
            _anchored({
              '_type': 'sizedbox',
              'width': 120,
              'height': 30,
              '_on': {'tap': 'pick'},
              '_child': {'_type': 'text', 'value': r'card ${label}'},
            }, placement: 'below'),
          ]),
        ),
      ),
    );
    await _open(tester);
    await tester.pumpAndSettle();

    expect(find.text('card hello'), findsOneWidget);
    await tester.tap(find.text('card hello'));
    await tester.pumpAndSettle();
    expect(find.text('state true card'), findsOneWidget);
  });

  testWidgets('A5 a tap on the dim and system back dispatch on_dismiss', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_screen(_overlay([_anchored(_box('hl'))]))));
    await _open(tester);
    await tester.pumpAndSettle();
    expect(find.text('state true none'), findsOneWidget);

    await tester.tapAt(const Offset(20, 500));
    await tester.pumpAndSettle();
    expect(find.text('state false none'), findsOneWidget);
    expect(_key('hl'), findsNothing);

    await _open(tester);
    await tester.pumpAndSettle();
    expect(find.text('state true none'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('state false none'), findsOneWidget);
    expect(_key('hl'), findsNothing);
  });

  testWidgets('A6 cards enter one after another by their delay', (
    tester,
  ) async {
    Map<String, Object?> card(String key, int delay) => _anchored({
      ..._box(key, width: 100, height: 30),
      '_motion': {'type': 'fade', 'duration': 100, 'delay': delay},
    }, placement: 'above');
    // The anchor sits at the top of the scroll viewport, so the cards above
    // it are drawn outside the page's viewport, over the header.
    await tester.pumpWidget(
      _app(
        _screen(
          _overlay([card('c1', 0), card('c2', 100)]),
          header: 200,
          top: 0,
        ),
      ),
    );
    await _open(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(_opacity(tester, 'c1'), greaterThan(0));
    expect(_opacity(tester, 'c2'), 0);

    // A delay timer starts its motion's ticker on the next frame.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacity(tester, 'c1'), 1);
    expect(_opacity(tester, 'c2'), 1);
  });

  testWidgets('A7 exits run by exit_delay and the overlay stays until done', (
    tester,
  ) async {
    Map<String, Object?> card(String key, int exitDelay) => _anchored({
      ..._box(key, width: 100, height: 30),
      '_motion': {
        'type': 'fade',
        'on': 'both',
        'duration': 100,
        'exit_delay': exitDelay,
      },
    }, placement: 'below');
    await tester.pumpWidget(
      _app(
        _screen(
          _overlay(
            [card('c1', 100), card('c2', 0)],
            props: {'barrier_duration': 100, 'barrier_exit_delay': 200},
          ),
        ),
      ),
    );
    await _open(tester);
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(20, 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(_opacity(tester, 'c2'), lessThan(1));
    expect(_opacity(tester, 'c1'), 1);

    // c1's exit_delay elapses at 100 ms; its ticker starts on the next frame.
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 40));
    expect(_opacity(tester, 'c2'), 0);
    expect(_opacity(tester, 'c1'), lessThan(1));

    // The dim waits 200 ms and fades for 100 ms.
    await tester.pump(const Duration(milliseconds: 100));
    expect(_key('c1'), findsOneWidget, reason: 'the dim is still fading');

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(_key('c1'), findsNothing);
    expect(_key('c2'), findsNothing);
  });
  for (final direction in TextDirection.values) {
    testWidgets(
      'A1 places above, start and end with a gap in ${direction.name}',
      (tester) async {
        Map<String, Object?> card(String key, String placement, String align) =>
            _anchored(
              _box(key, width: 100, height: 30),
              placement: placement,
              extra: {'align': align, 'gap': 8},
            );
        await tester.pumpWidget(
          _app(
            _screen(
              _overlay([
                card('above', 'above', 'start'),
                card('start', 'start', 'start'),
                card('end', 'end', 'end'),
              ]),
            ),
            direction: direction,
          ),
        );
        final badge = tester.getRect(_key('badge'));
        await _open(tester);
        await tester.pumpAndSettle();

        final above = tester.getRect(_key('above'));
        final start = tester.getRect(_key('start'));
        final end = tester.getRect(_key('end'));
        // Sizes and the gap scale alike: the card is 100 wide in the template.
        final gap = 8 * above.width / 100;
        final rtl = direction == TextDirection.rtl;

        expect(above.bottom, moreOrLessEquals(badge.top - gap));
        expect(rtl ? above.right : above.left, rtl ? badge.right : badge.left);
        expect(start.top, badge.top);
        expect(end.bottom, badge.bottom);
        if (rtl) {
          expect(start.left, moreOrLessEquals(badge.right + gap));
          expect(end.right, moreOrLessEquals(badge.left - gap));
        } else {
          expect(start.right, moreOrLessEquals(badge.left - gap));
          expect(end.left, moreOrLessEquals(badge.right + gap));
        }
      },
    );
  }

  group('anchored semantics', () {
    Future<void> openWith(WidgetTester tester, String anchor) async {
      await tester.pumpWidget(
        _app(
          _screen(
            _overlay(
              [
                _anchored({
                  ..._box('card', width: 120, height: 30),
                  '_child': {'_type': 'text', 'value': 'card text'},
                }),
              ],
              props: {'anchor': anchor},
            ),
          ),
        ),
      );
      await _open(tester);
      await tester.pumpAndSettle();
    }

    testWidgets('a placed child is announced', (tester) async {
      final semantics = tester.ensureSemantics();
      await openWith(tester, 'badge');

      expect(find.bySemanticsLabel('card text'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a child not drawn for a missing anchor is not announced', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await openWith(tester, 'nowhere');

      expect(find.text('card text'), findsOneWidget);
      expect(find.bySemanticsLabel('card text'), findsNothing);
      semantics.dispose();
    });

    testWidgets('a child moved with its anchor is announced at its new rect', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await openWith(tester, 'badge');

      // The dim takes the drags, so the page scrolls beneath the layer.
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(100);
      await tester.pumpAndSettle();

      final card = tester.getRect(_key('card'));
      expect(card.center, tester.getRect(_key('badge')).center);
      final node = tester.getSemantics(find.text('card text'));
      expect(_semanticsRect(tester, node), card);
      semantics.dispose();
    });
  });
}
