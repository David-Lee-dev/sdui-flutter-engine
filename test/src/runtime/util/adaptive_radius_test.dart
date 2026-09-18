import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/adaptive_radius.dart';

void main() {
  group('AdaptiveRadius.compute', () {
    test('returns max radius when both dimensions meet the threshold', () {
      expect(AdaptiveRadius.compute(const Size(200, 240)), 14);
    });

    test('clamps a small square to the minimum radius', () {
      expect(AdaptiveRadius.compute(const Size(36, 36)), 8);
    });

    test('uses the square root of the shorter dimension', () {
      expect(AdaptiveRadius.compute(const Size(100, 100)), 10);
    });

    test('treats an infinite dimension as the threshold', () {
      expect(AdaptiveRadius.compute(const Size(double.infinity, 100)), 10);
    });

    test('returns max radius when both dimensions are infinite', () {
      expect(
        AdaptiveRadius.compute(const Size(double.infinity, double.infinity)),
        14,
      );
    });
  });
}
