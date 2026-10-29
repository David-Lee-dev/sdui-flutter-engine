import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/shape_geometry.dart';

void main() {
  const box = Size(200, 100);

  group('ShapeGeometry.resolve', () {
    test('circle radius는 정렬 위치에 지름 2r 원을 둔다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.circle,
          alignment: Alignment.center,
          radius: 20,
        ),
        box,
      );
      expect(b.center, const Offset(100, 50));
      expect(b.half, const Size(20, 20));
      expect(b.radius, 20);
    });

    test('circle width/height는 짧은 변을 지름으로 가운데 둔다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.circle,
          alignment: Alignment.topLeft,
          size: Size(60, 40),
        ),
        box,
      );
      expect(b.center, const Offset(30, 20));
      expect(b.half, const Size(20, 20));
      expect(b.radius, 20);
    });

    test('capsule inset은 상자를 줄인 사각형, 반지름은 짧은 변의 절반', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.capsule,
          alignment: Alignment.center,
          inset: Size(10, 20),
        ),
        box,
      );
      expect(b.rect, const Rect.fromLTRB(10, 20, 190, 80));
      expect(b.radius, 30);
    });

    test('크기·inset이 없으면 상자 전체를 채운다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.rrect,
          alignment: Alignment.center,
        ),
        box,
      );
      expect(b.rect, Offset.zero & box);
      expect(b.radius, 0);
    });

    test('rrect width/height + 정렬 + offset, radius는 짧은 변 절반으로 자른다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.rrect,
          alignment: Alignment.bottomRight,
          offset: Offset(-5, 3),
          size: Size(40, 20),
          radius: 50,
        ),
        box,
      );
      expect(b.rect, const Rect.fromLTWH(155, 83, 40, 20));
      expect(b.radius, 10);
    });

    test('[x, y] 정렬은 Alignment 좌표대로 놓는다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.circle,
          alignment: Alignment(0.5, -1),
          radius: 10,
        ),
        box,
      );
      expect(b.center, const Offset(145, 10));
    });

    test('inset이 상자보다 크면 크기 0으로 접고 반지름은 음수가 되지 않는다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.capsule,
          alignment: Alignment.center,
          inset: Size(150, 10),
        ),
        box,
      );
      expect(b.half.width, 0);
      expect(b.radius, 0);
    });

    test('좌표·크기는 ±16384로 자른다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.rrect,
          alignment: Alignment.topLeft,
          offset: Offset(1e9, -1e9),
          size: Size(1e9, 10),
        ),
        box,
      );
      expect(b.center.dx, ShapeGeometry.maxCoordinate);
      expect(b.center.dy, -ShapeGeometry.maxCoordinate);
      expect(b.half.width, ShapeGeometry.maxCoordinate);
    });
  });

  group('SDF', () {
    const circle = ShapeBox(
      center: Offset(50, 50),
      half: Size(10, 10),
      radius: 10,
    );
    const bar = ShapeBox(
      center: Offset(50, 80),
      half: Size(40, 10),
      radius: 10,
    );

    test('roundBoxDistance: 안쪽 음수, 가장자리 0, 바깥 거리', () {
      expect(ShapeGeometry.roundBoxDistance(const Offset(50, 50), circle), -10);
      expect(
        ShapeGeometry.roundBoxDistance(const Offset(60, 50), circle),
        closeTo(0, 1e-12),
      );
      expect(
        ShapeGeometry.roundBoxDistance(const Offset(80, 50), circle),
        closeTo(20, 1e-12),
      );
      expect(
        ShapeGeometry.roundBoxDistance(
          const Offset(57.0710678, 57.0710678),
          circle,
        ),
        closeTo(0, 1e-6),
      );
      // 모서리 반지름 0인 사각형의 모서리 바깥은 유클리드 거리.
      const square = ShapeBox(
        center: Offset.zero,
        half: Size(10, 10),
        radius: 0,
      );
      expect(
        ShapeGeometry.roundBoxDistance(const Offset(13, 14), square),
        closeTo(5, 1e-12),
      );
    });

    test('smoothMin: k=0은 min, a=b면 a - k/4, 멀면 min', () {
      expect(ShapeGeometry.smoothMin(3, 5, 0), 3);
      expect(ShapeGeometry.smoothMin(2, 2, 8), 0);
      expect(ShapeGeometry.smoothMin(0, 100, 8), 0);
      expect(
        ShapeGeometry.smoothMin(1, 3, 4),
        closeTo(1 - 0.25 * 0.25 * 4, 1e-12),
      );
    });

    test('unionDistance: k가 클수록 두 도형 사이 목이 채워진다', () {
      const neck = Offset(50, 65); // 원(아래 끝 60)과 막대(위 끝 70) 사이
      final hard = ShapeGeometry.unionDistance(neck, [circle, bar], 0);
      final soft = ShapeGeometry.unionDistance(neck, [circle, bar], 24);
      expect(hard, closeTo(5, 1e-9));
      expect(soft, lessThan(0));
      expect(
        ShapeGeometry.unionDistance(const Offset(50, 50), [circle, bar], 0),
        -10,
      );
      expect(ShapeGeometry.unionDistance(neck, const [], 8), double.infinity);
    });
  });

  group('unionPath (셰이더 없을 때 대체)', () {
    test('각 도형 안쪽은 포함, 사이 빈 곳과 바깥은 제외', () {
      final path = ShapeGeometry.unionPath(const [
        ShapeBox(center: Offset(50, 50), half: Size(10, 10), radius: 10),
        ShapeBox(center: Offset(50, 80), half: Size(40, 10), radius: 10),
      ]);
      expect(path.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(20, 80)), isTrue);
      expect(path.contains(const Offset(50, 65)), isFalse);
      expect(path.contains(const Offset(5, 5)), isFalse);
    });

    test('빈 목록은 빈 경로', () {
      expect(ShapeGeometry.unionPath(const []).getBounds(), Rect.zero);
    });
  });
}
