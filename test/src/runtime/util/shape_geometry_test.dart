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
      final hard = ShapeGeometry.combineDistance(neck, [circle, bar], 0);
      final soft = ShapeGeometry.combineDistance(neck, [circle, bar], 24);
      expect(hard, closeTo(5, 1e-9));
      expect(soft, lessThan(0));
      expect(
        ShapeGeometry.combineDistance(const Offset(50, 50), [circle, bar], 0),
        -10,
      );
      expect(ShapeGeometry.combineDistance(neck, const [], 8), double.infinity);
    });
  });

  group('hardPath (셰이더 없을 때 대체)', () {
    test('각 도형 안쪽은 포함, 사이 빈 곳과 바깥은 제외', () {
      final path = ShapeGeometry.hardPath(const [
        ShapeBox(center: Offset(50, 50), half: Size(10, 10), radius: 10),
        ShapeBox(center: Offset(50, 80), half: Size(40, 10), radius: 10),
      ]);
      expect(path!.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(20, 80)), isTrue);
      expect(path.contains(const Offset(50, 65)), isFalse);
      expect(path.contains(const Offset(5, 5)), isFalse);
    });

    test('빈 목록은 빈 경로', () {
      expect(ShapeGeometry.hardPath(const [])!.getBounds(), Rect.zero);
    });
  });

  group('op · 도형별 smooth (0.9.0)', () {
    const bar = ShapeBox(
      center: Offset(100, 50),
      half: Size(100, 20),
      radius: 20,
    );
    const dip = ShapeBox(
      center: Offset(100, 30),
      half: Size(20, 20),
      radius: 20,
      op: ShapeOp.subtract,
    );

    test('smoothMax는 -smoothMin(-a, -b)이다', () {
      for (final (a, b, k) in [
        (1.0, 3.0, 4.0),
        (-2.0, 5.0, 8.0),
        (2.0, 2.0, 8.0),
      ]) {
        expect(
          ShapeGeometry.smoothMax(a, b, k),
          closeTo(-ShapeGeometry.smoothMin(-a, -b, k), 1e-12),
        );
      }
      expect(ShapeGeometry.smoothMax(3, 5, 0), 5);
    });

    test('subtract(k=0)은 max(d, -b): 깎인 자리는 바깥, 나머지는 그대로', () {
      final p = const Offset(100, 40); // 막대 안, 원 안
      final d = ShapeGeometry.combineDistance(p, const [bar, dip], 0);
      final a = ShapeGeometry.roundBoxDistance(p, bar);
      final b = ShapeGeometry.roundBoxDistance(p, dip);
      expect(d, closeTo(a > -b ? a : -b, 1e-12));
      expect(d, greaterThan(0));
      expect(
        ShapeGeometry.combineDistance(const Offset(20, 50), const [
          bar,
          dip,
        ], 0),
        ShapeGeometry.roundBoxDistance(const Offset(20, 50), bar),
      );
    });

    test('intersect(k=0)은 max(d, b)', () {
      const both = ShapeBox(
        center: Offset(100, 30),
        half: Size(20, 20),
        radius: 20,
        op: ShapeOp.intersect,
      );
      for (final p in const [Offset(100, 40), Offset(20, 50), Offset(100, 5)]) {
        final a = ShapeGeometry.roundBoxDistance(p, bar);
        final b = ShapeGeometry.roundBoxDistance(p, both);
        expect(
          ShapeGeometry.combineDistance(p, const [bar, both], 0),
          closeTo(a > b ? a : b, 1e-12),
        );
      }
    });

    test('도형별 smooth가 공통 smooth를 이기고, 없으면 공통값을 쓴다', () {
      const p = Offset(100, 52);
      const own = ShapeBox(
        center: Offset(100, 30),
        half: Size(20, 20),
        radius: 20,
        op: ShapeOp.subtract,
        smooth: 0,
      );
      expect(
        ShapeGeometry.combineDistance(p, const [bar, own], 24),
        ShapeGeometry.combineDistance(p, const [bar, dip], 0),
      );
      expect(
        ShapeGeometry.combineDistance(p, const [bar, dip], 24),
        isNot(ShapeGeometry.combineDistance(p, const [bar, dip], 0)),
      );
    });

    test('첫 도형의 op는 무시한다', () {
      const first = ShapeBox(
        center: Offset(100, 50),
        half: Size(100, 20),
        radius: 20,
        op: ShapeOp.subtract,
      );
      for (final p in const [Offset(100, 50), Offset(5, 5)]) {
        expect(
          ShapeGeometry.combineDistance(p, const [first], 8),
          ShapeGeometry.roundBoxDistance(p, bar),
        );
      }
    });

    test('hardPath는 목록 순서대로 difference·intersect를 적용한다', () {
      final cut = ShapeGeometry.hardPath(const [bar, dip])!;
      expect(cut.contains(const Offset(20, 50)), isTrue);
      expect(cut.contains(const Offset(100, 40)), isFalse);
      const both = ShapeBox(
        center: Offset(100, 30),
        half: Size(20, 20),
        radius: 20,
        op: ShapeOp.intersect,
      );
      final meet = ShapeGeometry.hardPath(const [bar, both])!;
      expect(meet.contains(const Offset(100, 40)), isTrue);
      expect(meet.contains(const Offset(20, 50)), isFalse);
      expect(meet.contains(const Offset(100, 15)), isFalse);
    });
  });

  group('at 배치 (0.9.0)', () {
    test('다섯 칸 중심은 정확히 W(i+0.5)/5', () {
      for (var i = 0; i < 5; i++) {
        final b = ShapeGeometry.resolve(
          ShapePrimitive(
            kind: ShapeKind.circle,
            alignment: Alignment.center,
            at: Offset((i + 0.5) / 5, 0),
            radius: 10,
          ),
          box,
        );
        expect(b.center, Offset(box.width * (i + 0.5) / 5, 0));
        expect(b.half, const Size(10, 10));
      }
    });

    test('at은 align을 이기고 offset은 그 뒤에 더한다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.rrect,
          alignment: Alignment.bottomRight,
          at: Offset(0.25, 0.5),
          offset: Offset(3, -4),
          size: Size(20, 10),
        ),
        box,
      );
      expect(
        b.rect,
        Rect.fromCenter(center: const Offset(53, 46), width: 20, height: 10),
      );
    });

    test('inset은 at보다 우선한다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.capsule,
          alignment: Alignment.center,
          at: Offset(0, 0),
          inset: Size(10, 20),
        ),
        box,
      );
      expect(b.rect, const Rect.fromLTRB(10, 20, 190, 80));
    });

    test('op와 smooth는 상자로 그대로 넘어간다', () {
      final b = ShapeGeometry.resolve(
        const ShapePrimitive(
          kind: ShapeKind.circle,
          alignment: Alignment.center,
          radius: 5,
          op: ShapeOp.intersect,
          smooth: 7,
        ),
        box,
      );
      expect(b.op, ShapeOp.intersect);
      expect(b.smooth, 7);
    });
  });

  group('backdrop clip 차이 측정', () {
    /// 하드 Path clip 안이지만 smooth [k] 윤곽 밖인 점이 그 윤곽에서 떨어진
    /// 최대 거리(px). nav 유리 캡슐(360×64) 위 가장자리를 반지름 34 원으로 깎는다.
    double mismatch(double k) {
      const capsule = ShapeBox(
        center: Offset(180, 48),
        half: Size(180, 32),
        radius: 32,
      );
      const cut = ShapeBox(
        center: Offset(180, 16),
        half: Size(34, 34),
        radius: 34,
        op: ShapeOp.subtract,
      );
      const shapes = [capsule, cut];
      const step = 0.5;
      // 매끈한 윤곽 위(안쪽이고 이웃 중 바깥이 있는) 표본과,
      // 하드 안쪽이지만 매끈한 바깥인 표본(blur가 비치는 자리)을 모은다.
      bool inside(double x, double y) =>
          ShapeGeometry.combineDistance(Offset(x, y), shapes, k) <= 0;
      final edge = <Offset>[];
      final leak = <Offset>[];
      for (var y = 0.0; y <= 96; y += step) {
        for (var x = 100.0; x <= 260; x += step) {
          final p = Offset(x, y);
          if (inside(x, y)) {
            if (!inside(x + step, y) ||
                !inside(x - step, y) ||
                !inside(x, y + step) ||
                !inside(x, y - step)) {
              edge.add(p);
            }
          } else if (ShapeGeometry.combineDistance(p, shapes, 0) < 0) {
            leak.add(p);
          }
        }
      }
      var worst = 0.0;
      for (final p in leak) {
        var nearest = double.infinity;
        for (final e in edge) {
          final d = (p - e).distance;
          if (d < nearest) nearest = d;
        }
        if (nearest > worst) worst = nearest;
      }
      return worst;
    }

    test('smooth 24·64에서 하드 clip이 매끈한 윤곽 밖으로 나가는 거리', () {
      final at24 = mismatch(24);
      final at64 = mismatch(64);
      // ignore: avoid_print
      print(
        'backdrop clip mismatch: smooth 24 → ${at24.toStringAsFixed(1)} px, '
        'smooth 64 → ${at64.toStringAsFixed(1)} px',
      );
      // docs/widgets/custom/shape.md 의 수치(약 8 px / 약 20 px)를 지킨다.
      expect(at24, inInclusiveRange(1, 9));
      expect(at64, inInclusiveRange(1, 21));
    });
  });
}
