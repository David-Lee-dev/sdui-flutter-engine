// Smooth union of up to eight rounded boxes, painted by the `shape` widget.
//
// The formulas and constants match lib/src/runtime/util/shape_geometry.dart
// (roundBoxDistance, smoothMin, unionDistance); keep the two in step.
//
// Uniform layout (floats, in declaration order):
//   uParams  primitive count, smooth k, rim width, unused
//   uFill    fill color (straight RGBA, 0-1)
//   uRim     rim color (straight RGBA, 0-1)
//   uP0-uP7  center x, center y, half width, half height per primitive
//   uR0-uR1  corner radius of primitives 0-3 and 4-7
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

void main() {
  vec2 p = FlutterFragCoord().xy;
  float count = uParams.x;
  float k = uParams.y;
  float rim = uParams.z;

  float d = 1e9;
  if (count > 0.5) d = roundBoxDistance(p, uP0, uR0.x);
  if (count > 1.5) d = smoothMin(d, roundBoxDistance(p, uP1, uR0.y), k);
  if (count > 2.5) d = smoothMin(d, roundBoxDistance(p, uP2, uR0.z), k);
  if (count > 3.5) d = smoothMin(d, roundBoxDistance(p, uP3, uR0.w), k);
  if (count > 4.5) d = smoothMin(d, roundBoxDistance(p, uP4, uR1.x), k);
  if (count > 5.5) d = smoothMin(d, roundBoxDistance(p, uP5, uR1.y), k);
  if (count > 6.5) d = smoothMin(d, roundBoxDistance(p, uP6, uR1.z), k);
  if (count > 7.5) d = smoothMin(d, roundBoxDistance(p, uP7, uR1.w), k);

  // One-pixel antialiased coverage of the fill and of a rim centred on the
  // edge, matching a stroked path of width `rim`.
  float fillA = clamp(0.5 - d, 0.0, 1.0) * uFill.a;
  vec4 color = vec4(uFill.rgb * fillA, fillA);
  if (rim > 0.0) {
    float rimA = clamp(rim * 0.5 + 0.5 - abs(d), 0.0, 1.0) * uRim.a;
    color = vec4(uRim.rgb * rimA, rimA) + color * (1.0 - rimA);
  }
  fragColor = color;
}
