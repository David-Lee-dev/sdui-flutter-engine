import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/swipe/swipe_controller.dart';

/// A test double recording orchestration calls without a live [PageController].
class _FakeLink implements SwipePaneLink {
  _FakeLink(this.owner, {this.currentPage});

  @override
  final Object owner;

  /// The continuous position the controller reads back; `null` mimics a pane
  /// with no attached viewport.
  @override
  double? currentPage;

  final List<double> synced = <double>[];
  final List<(int, bool)> moved = <(int, bool)>[];

  @override
  void syncTo(double page) => synced.add(page);

  @override
  Future<void> moveTo(int index, {bool animate = true}) async {
    moved.add((index, animate));
    currentPage = index.toDouble();
  }
}

void main() {
  group('SwipeController', () {
    group('construction', () {
      test('clamps the initial index into range', () {
        expect(SwipeController(length: 3, initialIndex: 9).index, 2);
        expect(SwipeController(length: 3, initialIndex: -4).index, 0);
      });
    });

    group('registerLink', () {
      test('snaps a newly attached pane to the current position', () {
        final controller = SwipeController(length: 3, initialIndex: 1);
        final link = _FakeLink('a');
        controller.registerLink(link);
        expect(link.synced, [1.0]);
      });
    });

    group('page', () {
      test('reflects the first live link so watchers glide with it', () {
        final controller = SwipeController(length: 3);
        final a = _FakeLink('a', currentPage: 0.5);
        controller.registerLink(a);
        expect(controller.page, 0.5);
      });

      test('falls back to the settled position when no link is live', () {
        final controller = SwipeController(length: 3, initialIndex: 2);
        expect(controller.page, 2.0);
      });
    });

    group('drive', () {
      test('only the interaction owner drives; others are mirrored', () {
        final controller = SwipeController(length: 3);
        final a = _FakeLink('a');
        final b = _FakeLink('b');
        controller
          ..registerLink(a)
          ..registerLink(b);
        a.synced.clear();
        b.synced.clear();

        controller.beginInteraction('a');
        controller.drive('a', 0.4);

        expect(b.synced, [0.4]); // follower mirrored
        expect(a.synced, isEmpty); // source is not mirrored to itself
      });

      test('ignores a driver that does not own the interaction', () {
        final controller = SwipeController(length: 3);
        final b = _FakeLink('b');
        controller.registerLink(b);
        b.synced.clear();

        controller.beginInteraction('a');
        controller.drive('b', 0.4); // b is not the owner

        expect(b.synced, isEmpty);
      });

      test('first gesture wins when two panes begin interacting', () {
        final controller = SwipeController(length: 3);
        controller.beginInteraction('a');
        controller.beginInteraction('b');
        expect(controller.isInteracting, isTrue);

        final started = <String>[];
        controller.onInteractionStart = () => started.add('x');
        // already interacting → no second start
        controller.beginInteraction('c');
        expect(started, isEmpty);
      });
    });

    group('endInteraction', () {
      test(
        'settles all non-source links to the landed page and reports it',
        () {
          final controller = SwipeController(length: 3);
          final a = _FakeLink('a');
          final b = _FakeLink('b');
          controller
            ..registerLink(a)
            ..registerLink(b);
          int? settled;
          controller.onSettled = (i) => settled = i;

          controller.beginInteraction('a');
          controller.endInteraction('a', 1); // pane a landed on page 1

          expect(controller.index, 1);
          expect(b.moved, contains((1, true))); // follower animated to 1
          expect(a.moved, isEmpty); // source snapped itself
          expect(settled, 1);
          expect(controller.isInteracting, isFalse);
        },
      );

      test('fires the interaction-end hook for autoplay resume', () {
        final controller = SwipeController(length: 3);
        var ended = 0;
        controller.onInteractionEnd = () => ended++;
        controller.beginInteraction('a');
        controller.endInteraction('a', 0);
        expect(ended, 1);
      });
    });

    group('goTo', () {
      test('moves every link and reports the settled index', () async {
        final controller = SwipeController(length: 4);
        final a = _FakeLink('a');
        controller.registerLink(a);
        int? settled;
        controller.onSettled = (i) => settled = i;

        await controller.goTo(2);

        expect(controller.index, 2);
        expect(a.moved, contains((2, true)));
        expect(settled, 2);
      });

      test('clamps an out-of-range target', () async {
        final controller = SwipeController(length: 3);
        await controller.goTo(99);
        expect(controller.index, 2);
      });
    });

    group('setLength', () {
      test('re-clamps the current index when the range shrinks', () {
        final controller = SwipeController(length: 5, initialIndex: 4);
        controller.setLength(2);
        expect(controller.length, 2);
        expect(controller.index, 1);
      });
    });

    group('loop', () {
      test('anchors the position on the virtual axis at construction', () {
        final controller = SwipeController(
          length: 4,
          initialIndex: 1,
          loop: true,
        );
        expect(controller.index, 1);
        expect(controller.virtualBase, 40000);
        expect(controller.page, 40001.0); // virtual, no live link yet
        expect(controller.logicalPage, 1.0);
      });

      test('snaps a newly attached pane to the virtual position', () {
        final controller = SwipeController(
          length: 4,
          initialIndex: 2,
          loop: true,
        );
        final link = _FakeLink('a');
        controller.registerLink(link);
        expect(link.synced, [40002.0]);
      });

      test('a settle folds the virtual landing back to a logical index', () {
        final controller = SwipeController(length: 4, loop: true);
        final link = _FakeLink('a');
        controller.registerLink(link);
        int? settled;
        controller.onSettled = (i) => settled = i;

        controller.beginInteraction('a');
        controller.endInteraction('a', controller.virtualBase + 3);

        expect(controller.index, 3);
        expect(settled, 3);
      });

      test(
        'advancing off the last item moves forward across the seam',
        () async {
          final controller = SwipeController(length: 4, loop: true);
          final link = _FakeLink('a');
          controller.registerLink(link);

          // Settle onto the last item within the anchor cycle.
          controller.beginInteraction('a');
          controller.endInteraction('a', controller.virtualBase + 3);
          expect(controller.index, 3);

          // Autoplay/next asks for logical 0; the nearest item-0 is forward.
          await controller.goTo(0);
          expect(controller.index, 0);
          expect(link.moved.last.$1, controller.virtualBase + 4);
        },
      );

      test(
        'seeking the previous item off the first wraps backward one step',
        () async {
          final controller = SwipeController(length: 4, loop: true);
          final link = _FakeLink('a');
          controller.registerLink(link);

          await controller.goTo(3); // from item 0, item 3 is one step back
          expect(controller.index, 3);
          expect(link.moved.last.$1, controller.virtualBase - 1);
        },
      );

      test(
        'logicalPage wraps into [0, length) as the position crosses the seam',
        () {
          final controller = SwipeController(length: 4, loop: true);
          final link = _FakeLink(
            'a',
            currentPage: controller.virtualBase - 0.5,
          );
          controller.registerLink(link);
          expect(controller.logicalPage, 3.5);
        },
      );
    });
  });
}
