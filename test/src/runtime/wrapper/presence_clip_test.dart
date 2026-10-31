import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/runtime/wrapper/presence.dart';

const _timing = PresenceConfig(durationMs: 1000, curve: 'linear');
const _capture = ValueKey('capture');

/// A [height]-tall box that paints outside itself: a red mark 24 px above,
/// a green one 24 px below and an orange one 24 px past its trailing edge.
Widget _box(
  double height, {
  double width = 100,
  bool composited = false,
  Key? key,
}) {
  Widget box = SizedBox(
    key: key,
    width: width,
    height: height,
    child: const Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: ColoredBox(color: Colors.blue)),
        Positioned(
          top: -24,
          left: 10,
          width: 20,
          height: 20,
          child: ColoredBox(color: Colors.red),
        ),
        Positioned(
          bottom: -24,
          left: 10,
          width: 20,
          height: 20,
          child: ColoredBox(color: Colors.green),
        ),
        Positioned(
          right: -24,
          top: 10,
          width: 20,
          height: 20,
          child: ColoredBox(color: Colors.orange),
        ),
      ],
    ),
  );
  return composited ? RepaintBoundary(child: box) : box;
}

/// [child] at ([pad], [pad]) on a white 400 x 400 capture.
Widget _scene(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double pad = 50,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(
      alignment: Alignment.topLeft,
      child: RepaintBoundary(
        key: _capture,
        child: SizedBox(
          width: 400,
          height: 400,
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: pad, top: pad),
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      ),
    ),
  ),
);

Widget _single(Object? id, Widget? child) =>
    PresenceGroup.single(childKey: id, config: _timing, child: child);

Widget _list(List<String> ids, Widget Function(String id) item, Axis axis) =>
    PresenceGroup.list(
      items: [for (final id in ids) (id, item(id))],
      builder: (children) => axis == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            )
          : Row(mainAxisSize: MainAxisSize.min, children: children),
      axis: axis,
      config: _timing,
    );

Future<int> _pixel(WidgetTester tester, int x, int y) async =>
    (await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_capture),
      );
      final image = await boundary.toImage();
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final i = (y * image.width + x) * 4;
      final rgb =
          (data.getUint8(i) << 16) |
          (data.getUint8(i + 1) << 8) |
          data.getUint8(i + 2);
      image.dispose();
      return rgb;
    }))!;

Future<void> _painted(WidgetTester tester, int x, int y) async => expect(
  await _pixel(tester, x, y),
  isNot(0xffffff),
  reason: 'pixel ($x, $y) must be painted',
);

Future<void> _clipped(WidgetTester tester, int x, int y) async => expect(
  await _pixel(tester, x, y),
  0xffffff,
  reason: 'pixel ($x, $y) must be clipped',
);

List<ClipRectLayer> _clips(WidgetTester tester) =>
    tester.layers.whereType<ClipRectLayer>().toList();

void main() {
  group('presence 실행 중 클립은 슬롯보다 큰 자식의 자라는 변만 자른다', () {
    testWidgets('같은 높이 swap: 위로 넘친 말풍선이 그려진다', (tester) async {
      await tester.pumpWidget(_scene(_single('a', _box(80))));
      await tester.pumpWidget(_scene(_single('b', _box(80))));
      await tester.pump(const Duration(milliseconds: 500));

      await _painted(tester, 65, 30);
    });

    for (final (from, to) in [(140.0, 60.0), (60.0, 140.0)]) {
      testWidgets('swap $from → $to: 큰 자식만 슬롯 아래에서 잘린다', (tester) async {
        await tester.pumpWidget(_scene(_single('a', _box(from))));
        await tester.pumpWidget(_scene(_single('b', _box(to))));
        await tester.pump(const Duration(milliseconds: 500));

        await _painted(tester, 65, 30);
        await _clipped(tester, 100, 160);
        // The short child fits, so its own bottom overflow still paints.
        await _painted(tester, 65, 120);
      });
    }

    testWidgets('퇴장 collapse: 떠나는 자식은 줄어드는 아래 변만 잘린다', (tester) async {
      await tester.pumpWidget(_scene(_single('a', _box(140))));
      await tester.pumpWidget(_scene(_single(null, null)));
      await tester.pump(const Duration(milliseconds: 500));

      await _painted(tester, 65, 30);
      await _clipped(tester, 100, 130);
    });

    testWidgets('list 에서 한 프레임에 넣고 빼면 상자마다 자기 자식만 자른다', (tester) async {
      Widget item(String id) =>
          _box(100, width: id == 'a' ? 100 : 50, key: ValueKey(id));
      await tester.pumpWidget(_scene(_list(['a'], item, Axis.vertical)));
      await tester.pumpWidget(_scene(_list(['b'], item, Axis.vertical)));
      await tester.pump(const Duration(milliseconds: 500));

      final leaving = tester.getTopLeft(find.byKey(const ValueKey('a')));
      await _painted(tester, leaving.dx.toInt() + 15, leaving.dy.toInt() - 20);
      await _clipped(tester, leaving.dx.toInt() + 80, leaving.dy.toInt() + 80);
      final entering = tester.getTopLeft(find.byKey(const ValueKey('b')));
      await _painted(
        tester,
        entering.dx.toInt() + 15,
        entering.dy.toInt() - 20,
      );
    });

    testWidgets('되돌린 swap 은 매 프레임 규칙을 지키고 같은 클립 레이어를 쓴다', (tester) async {
      await tester.pumpWidget(
        _scene(_single('a', _box(140, composited: true))),
      );
      await tester.pumpWidget(_scene(_single('b', _box(60, composited: true))));
      await tester.pump(const Duration(milliseconds: 300));
      final clip = _clips(tester).single;
      await _painted(tester, 65, 30);

      await tester.pumpWidget(
        _scene(_single('a', _box(140, composited: true))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(_clips(tester).single, same(clip));
      await _painted(tester, 65, 30);

      await tester.pump(const Duration(seconds: 2));

      expect(_clips(tester), isEmpty);
      await _painted(tester, 65, 210);
    });

    testWidgets('가로 RTL reveal 은 왼쪽 변만 자른다', (tester) async {
      Widget item(String id) => _box(60);
      await tester.pumpWidget(
        _scene(_list([], item, Axis.horizontal), direction: TextDirection.rtl),
      );
      await tester.pumpWidget(
        _scene(
          _list(['a'], item, Axis.horizontal),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await _clipped(tester, 40, 90);
      await _painted(tester, 115, 65);
    });

    for (final composited in [false, true]) {
      testWidgets('composited=$composited: 같은 픽셀, 합성 자식만 ClipRectLayer', (
        tester,
      ) async {
        await tester.pumpWidget(
          _scene(_single('a', _box(140, composited: composited))),
        );
        await tester.pumpWidget(_scene(_single(null, null)));
        await tester.pump(const Duration(milliseconds: 500));

        await _painted(tester, 65, 30);
        await _clipped(tester, 100, 130);
        expect(_clips(tester), hasLength(composited ? 1 : 0));
      });
    }

    testWidgets('맞는 자식의 아래 넘침은 실행 중에도 그려진다', (tester) async {
      await tester.pumpWidget(_scene(_single('a', _box(80))));
      await tester.pumpWidget(_scene(_single('b', _box(80))));
      await tester.pump(const Duration(milliseconds: 500));

      await _painted(tester, 65, 145);
    });

    testWidgets('클립은 0 이 아닌 paint offset 을 따른다', (tester) async {
      await tester.pumpWidget(_scene(_single('a', _box(140)), pad: 80));
      await tester.pumpWidget(_scene(_single(null, null), pad: 80));
      await tester.pump(const Duration(milliseconds: 500));

      await _painted(tester, 95, 60);
      await _painted(tester, 100, 140);
      await _clipped(tester, 100, 160);
    });

    testWidgets('자식을 떼면 자식의 클립 레이어 핸들이 비워진다', (tester) async {
      Widget item(String id) => _box(100, composited: true);
      await tester.pumpWidget(_scene(_list(['a', 'b'], item, Axis.vertical)));
      await tester.pumpWidget(_scene(_list([], item, Axis.vertical)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(_clips(tester), hasLength(2));

      final handles = <dynamic>[];
      for (final element
          in find
              .byWidgetPredicate(
                (w) => w.runtimeType.toString() == '_PresenceBox',
              )
              .evaluate()) {
        final box =
            element.renderObject!
                as ContainerRenderObjectMixin<
                  RenderBox,
                  ContainerBoxParentData<RenderBox>
                >;
        handles.add((box.firstChild!.parentData! as dynamic).clip);
        box.removeAll();
      }

      expect(handles, hasLength(2));
      expect(handles.every((handle) => handle.layer == null), isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hit test 는 실행 중과 쉬는 상태 모두 그대로다', (tester) async {
      var taps = 0;
      Widget child() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => taps++,
        child: _box(100),
      );
      await tester.pumpWidget(_scene(_single('a', child())));
      await tester.tapAt(const Offset(80, 80));
      expect(taps, 1);

      await tester.pumpWidget(_scene(_single(null, null)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tapAt(const Offset(80, 80));
      expect(taps, 1);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpWidget(_scene(_single('a', child())));
      await tester.pump(const Duration(seconds: 2));
      await tester.tapAt(const Offset(80, 80));
      expect(taps, 2);
    });
  });
}
