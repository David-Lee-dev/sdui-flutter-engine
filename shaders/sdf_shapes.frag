// Up to eight rounded boxes folded left by union, subtract or intersect,
// painted by the `shape` widget.
//
// The formulas and constants match lib/src/runtime/util/shape_geometry.dart
// (roundBoxDistance, smoothMin, smoothMax, combineDistance); keep the two in
// step.
//
// One draw paints one stage: the fill coverage tinted by uFill, or the rim
// coverage tinted by uRim. A gradient stage passes white and is tinted by
// the caller with BlendMode.srcIn.
//
// Uniform layout (floats, in declaration order):
//   uParams  primitive count, unused, rim width, stage (0 fill, 1 rim)
//   uFill    fill color (straight RGBA, 0-1)
//   uRim     rim color (straight RGBA, 0-1)
//   uP0-uP7  center x, center y, half width, half height per primitive
//   uR0-uR1  corner radius of primitives 0-3 and 4-7
//   uOp0-uOp1  op of primitives 0-3 and 4-7 (0 union, 1 subtract,
//              2 intersect; primitive 0's op is ignored)
//   uK0-uK1  smooth (blend width) of primitives 0-3 and 4-7
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec4 uParams;
uniform vec4 uFill;
uniform vec4 uRim;
uniform vec4 uP0;
uniform vec4 uP1;
uniform vec4 uP2;
uniform vec4 uP3;
uniform vec4 uP4;
uniform vec4 uP5;
uniform vec4 uP6;
uniform vec4 uP7;
uniform vec4 uR0;
uniform vec4 uR1;
uniform vec4 uOp0;
uniform vec4 uOp1;
uniform vec4 uK0;
uniform vec4 uK1;

out vec4 fragColor;

float roundBoxDistance(vec2 p, vec4 box, float r) {
  vec2 q = abs(p - box.xy) - box.zw + vec2(r);
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float smoothMin(float a, float b, float k) {
  if (k <= 0.0) {
    return min(a, b);
  }
  float h = max(k - abs(a - b), 0.0) / k;
  return min(a, b) - h * h * k * 0.25;
}

float smoothMax(float a, float b, float k) {
  return -smoothMin(-a, -b, k);
}

float combine(float d, float b, float op, float k) {
  if (op > 1.5) return smoothMax(d, b, k);
  if (op > 0.5) return smoothMax(d, -b, k);
  return smoothMin(d, b, k);
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float count = uParams.x;
  float rim = uParams.z;

  float d = 1e9;
  if (count > 0.5) d = roundBoxDistance(p, uP0, uR0.x);
  if (count > 1.5) d = combine(d, roundBoxDistance(p, uP1, uR0.y), uOp0.y, uK0.y);
  if (count > 2.5) d = combine(d, roundBoxDistance(p, uP2, uR0.z), uOp0.z, uK0.z);
  if (count > 3.5) d = combine(d, roundBoxDistance(p, uP3, uR0.w), uOp0.w, uK0.w);
  if (count > 4.5) d = combine(d, roundBoxDistance(p, uP4, uR1.x), uOp1.x, uK1.x);
  if (count > 5.5) d = combine(d, roundBoxDistance(p, uP5, uR1.y), uOp1.y, uK1.y);
  if (count > 6.5) d = combine(d, roundBoxDistance(p, uP6, uR1.z), uOp1.z, uK1.z);
  if (count > 7.5) d = combine(d, roundBoxDistance(p, uP7, uR1.w), uOp1.w, uK1.w);

  // One-pixel antialiased coverage of the fill, or of a rim centred on the
  // edge matching a stroked path of width `rim`.
  if (uParams.w > 0.5) {
    float rimA = rim > 0.0
        ? clamp(rim * 0.5 + 0.5 - abs(d), 0.0, 1.0) * uRim.a
        : 0.0;
    fragColor = vec4(uRim.rgb * rimA, rimA);
  } else {
    float fillA = clamp(0.5 - d, 0.0, 1.0) * uFill.a;
    fragColor = vec4(uFill.rgb * fillA, fillA);
  }
}
