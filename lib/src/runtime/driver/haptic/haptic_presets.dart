// The 151 presets of Software Mansion's Pulsar
// (https://github.com/software-mansion/pulsar, commit
// abdee706282598ab0194ba739dce835dc828f164). Names are converted to
// snake_case, absolute tap event times to per-pulse delays, and continuous
// curves are kept as (ms from start, value) points.
//
// MIT License
//
// Copyright (c) 2025 Krzysztof Piaskowy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

part of 'haptic_driver.dart';

/// Named patterns a `sys_haptic` `variant` can play: tap-only presets on a
/// tap-capable device, continuous ones on a device with continuous haptics.
const Map<String, HapticPattern> hapticPresets = {
  'afterglow': HapticPattern(
    // Afterglow
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.3),
      HapticPulse(
        intensity: 0.703,
        sharpness: 0.203,
        delay: Duration(milliseconds: 75),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.1,
        delay: Duration(milliseconds: 75),
      ),
    ],
  ),
  'aftershock': HapticPattern(
    // Aftershock
    taps: [
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.247,
        delay: Duration(milliseconds: 298),
      ),
      HapticPulse(
        intensity: 0.494,
        sharpness: 0.266,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.497,
        sharpness: 0.263,
        delay: Duration(milliseconds: 101),
      ),
    ],
  ),
  'alarm': HapticPattern(
    // Alarm
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.8),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.5,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.8,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.5,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.8,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.5,
        delay: Duration(milliseconds: 200),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.9),
      (130, 0.0),
      (200, 0.9),
      (330, 0.0),
      (400, 0.9),
      (530, 0.0),
      (600, 0.9),
      (730, 0.0),
      (800, 0.9),
      (930, 0.0),
      (1000, 0.9),
      (1130, 0.0),
    ],
    sharpness: [
      (0, 0.82),
      (130, 0.82),
      (200, 0.48),
      (330, 0.48),
      (400, 0.82),
      (530, 0.82),
      (600, 0.48),
      (730, 0.48),
      (800, 0.82),
      (930, 0.82),
      (1000, 0.48),
      (1130, 0.48),
    ],
  ),
  'anvil': HapticPattern(
    // Anvil
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.15),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.2,
        delay: Duration(milliseconds: 80),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 1.0),
      (60, 0.6),
      (150, 0.3),
      (300, 0.1),
      (500, 0.0),
    ],
    sharpness: [(0, 0.12), (5, 0.1), (500, 0.08)],
  ),
  'applause': HapticPattern(
    // Applause
    taps: [
      HapticPulse(intensity: 0.2, sharpness: 0.5),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.52,
        delay: Duration(milliseconds: 150),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.54,
        delay: Duration(milliseconds: 140),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.56,
        delay: Duration(milliseconds: 130),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.58,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.484,
        sharpness: 0.6,
        delay: Duration(milliseconds: 110),
      ),
      HapticPulse(
        intensity: 0.509,
        sharpness: 0.62,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.503,
        sharpness: 0.65,
        delay: Duration(milliseconds: 118),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.716,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.434,
        sharpness: 0.725,
        delay: Duration(milliseconds: 95),
      ),
      HapticPulse(
        intensity: 0.488,
        sharpness: 0.759,
        delay: Duration(milliseconds: 96),
      ),
      HapticPulse(
        intensity: 0.506,
        sharpness: 1,
        delay: Duration(milliseconds: 97),
      ),
      HapticPulse(
        intensity: 0.528,
        sharpness: 1,
        delay: Duration(milliseconds: 93),
      ),
      HapticPulse(
        intensity: 0.519,
        sharpness: 1,
        delay: Duration(milliseconds: 83),
      ),
      HapticPulse(
        intensity: 0.528,
        sharpness: 1,
        delay: Duration(milliseconds: 98),
      ),
    ],
    intensity: [(0, 0.0), (10, 0.2), (1482, 0.266), (1564, 0.0)],
    sharpness: [(0, 0.5), (990, 0.72), (1250, 0.7)],
  ),
  'ascent': HapticPattern(
    // Ascent
    taps: [
      HapticPulse(intensity: 0.55, sharpness: 0.3),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.37,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.42,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.55,
        delay: Duration(milliseconds: 160),
      ),
      HapticPulse(
        intensity: 0.92,
        sharpness: 0.65,
        delay: Duration(milliseconds: 140),
      ),
      HapticPulse(
        intensity: 0.97,
        sharpness: 0.73,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.87,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.55),
      (155, 0.0),
      (205, 0.65),
      (335, 0.0),
      (385, 0.75),
      (495, 0.0),
      (545, 0.85),
      (635, 0.0),
      (685, 0.92),
      (755, 0.0),
      (805, 0.97),
      (860, 0.0),
      (905, 1.0),
      (1700, 0.65),
      (2100, 0.25),
      (2400, 0.0),
    ],
    sharpness: [
      (0, 0.3),
      (200, 0.37),
      (380, 0.42),
      (540, 0.55),
      (680, 0.65),
      (800, 0.73),
      (900, 0.87),
      (2400, 0.87),
    ],
  ),
  'balloon_pop': HapticPattern(
    // BalloonPop
    taps: [
      HapticPulse(intensity: 0.1, sharpness: 0.3),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.35,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.4,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.45,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.5,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.9,
        delay: Duration(milliseconds: 200),
      ),
    ],
    intensity: [
      (0, 0.0),
      (50, 0.1),
      (200, 0.0),
      (300, 0.15),
      (500, 0.0),
      (600, 0.25),
      (800, 0.0),
      (900, 0.35),
      (1100, 0.0),
      (1200, 0.5),
      (1380, 0.0),
      (1400, 1.0),
      (1440, 0.6),
      (1550, 0.1),
      (1700, 0.0),
    ],
    sharpness: [(0, 0.2), (1380, 0.5), (1400, 1.0), (1700, 0.3)],
  ),
  'barrage': HapticPattern(
    // Barrage
    taps: [
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.994,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.994,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.991,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.991,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 49),
      ),
    ],
  ),
  'bass_drop': HapticPattern(
    // BassDrop
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.509),
      HapticPulse(
        intensity: 1,
        sharpness: 0.069,
        delay: Duration(milliseconds: 71),
      ),
    ],
  ),
  'batter': HapticPattern(
    // Batter
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.35),
      HapticPulse(
        intensity: 0.82,
        sharpness: 0.32,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.36,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.33,
        delay: Duration(milliseconds: 55),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.38,
        delay: Duration(milliseconds: 50),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.9),
      (45, 0.35),
      (60, 0.8),
      (102, 0.32),
      (120, 0.93),
      (158, 0.35),
      (175, 0.83),
      (208, 0.38),
      (225, 1.0),
      (380, 0.0),
    ],
    sharpness: [(0, 0.35), (225, 0.38), (380, 0.32)],
  ),
  'bell_toll': HapticPattern(
    // BellToll
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.903,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.513,
        delay: Duration(milliseconds: 191),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.147,
        delay: Duration(milliseconds: 198),
      ),
    ],
  ),
  'blip': HapticPattern(
    // Blip
    taps: [HapticPulse(intensity: 0.55, sharpness: 0.6)],
    intensity: [(0, 0.0), (10, 0.5), (100, 0.35), (200, 0.0)],
    sharpness: [(0, 0.6), (200, 0.58)],
  ),
  'bloom': HapticPattern(
    // Bloom
    taps: [
      HapticPulse(intensity: 0.3, sharpness: 0.5),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.62,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (15, 0.28),
      (80, 0.15),
      (120, 0.5),
      (200, 0.15),
      (300, 0.0),
    ],
    sharpness: [(0, 0.48), (200, 0.62), (300, 0.58)],
  ),
  'bongo': HapticPattern(
    // Bongo
    taps: [
      HapticPulse(
        intensity: 0.594,
        sharpness: 0.594,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.588,
        sharpness: 0.588,
        delay: Duration(milliseconds: 72),
      ),
      HapticPulse(
        intensity: 0.588,
        sharpness: 0.588,
        delay: Duration(milliseconds: 78),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.4,
        delay: Duration(milliseconds: 148),
      ),
      HapticPulse(
        intensity: 0.394,
        sharpness: 0.394,
        delay: Duration(milliseconds: 81),
      ),
      HapticPulse(
        intensity: 0.394,
        sharpness: 0.394,
        delay: Duration(milliseconds: 71),
      ),
    ],
  ),
  'boulder': HapticPattern(
    // Boulder
    taps: [HapticPulse(intensity: 1, sharpness: 0.2)],
  ),
  'breaking_wave': HapticPattern(
    // BreakingWave
    taps: [
      HapticPulse(intensity: 0.497, sharpness: 0.497),
      HapticPulse(
        intensity: 0.497,
        sharpness: 0.497,
        delay: Duration(milliseconds: 89),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.1,
        delay: Duration(milliseconds: 113),
      ),
    ],
  ),
  'breath': HapticPattern(
    // Breath
    intensity: [(0, 0.0), (800, 0.5), (1600, 0.05), (2400, 0.5), (3200, 0.0)],
    sharpness: [
      (0, 0.15),
      (800, 0.25),
      (1600, 0.1),
      (2400, 0.25),
      (3200, 0.15),
    ],
  ),
  'buildup': HapticPattern(
    // Buildup
    taps: [
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.053,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.122,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.228,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.394,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.613,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.803,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 49),
      ),
    ],
  ),
  'burst': HapticPattern(
    // Burst
    taps: [
      HapticPulse(intensity: 0.2, sharpness: 0.55),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.65,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.7,
        delay: Duration(milliseconds: 80),
      ),
    ],
    intensity: [
      (0, 0.0),
      (15, 0.18),
      (80, 0.4),
      (100, 0.85),
      (130, 0.3),
      (300, 0.0),
    ],
    sharpness: [(0, 0.55), (80, 0.65), (100, 0.72), (300, 0.4)],
  ),
  'buzz': HapticPattern(
    // Buzz
    taps: [HapticPulse(intensity: 0.9, sharpness: 0.85)],
    intensity: [
      (0, 0.0),
      (5, 0.9),
      (100, 0.85),
      (150, 0.65),
      (250, 0.3),
      (350, 0.0),
    ],
    sharpness: [(0, 0.85), (350, 0.8)],
  ),
  'cadence': HapticPattern(
    // Cadence
    taps: [
      HapticPulse(
        intensity: 0.809,
        sharpness: 0.897,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.413,
        delay: Duration(milliseconds: 198),
      ),
    ],
  ),
  'camera_shutter': HapticPattern(
    // CameraShutter
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.75),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.7,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.6),
      (30, 0.05),
      (60, 0.8),
      (100, 0.1),
      (150, 0.0),
    ],
    sharpness: [(0, 0.78), (30, 0.6), (60, 0.72), (150, 0.65)],
  ),
  'canter': HapticPattern(
    // Canter
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.203,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.697,
        sharpness: 0.5,
        delay: Duration(milliseconds: 76),
      ),
      HapticPulse(
        intensity: 0.703,
        sharpness: 0.244,
        delay: Duration(milliseconds: 96),
      ),
    ],
  ),
  'cascade': HapticPattern(
    // Cascade
    taps: [
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.994,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.997,
        delay: Duration(milliseconds: 98),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.997,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 352),
      ),
      HapticPulse(
        intensity: 0.803,
        sharpness: 0.803,
        delay: Duration(milliseconds: 98),
      ),
      HapticPulse(
        intensity: 0.797,
        sharpness: 0.797,
        delay: Duration(milliseconds: 102),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.5,
        delay: Duration(milliseconds: 367),
      ),
      HapticPulse(
        intensity: 0.491,
        sharpness: 0.491,
        delay: Duration(milliseconds: 101),
      ),
      HapticPulse(
        intensity: 0.494,
        sharpness: 0.494,
        delay: Duration(milliseconds: 99),
      ),
      HapticPulse(
        intensity: 0.497,
        sharpness: 0.213,
        delay: Duration(milliseconds: 342),
      ),
      HapticPulse(
        intensity: 0.506,
        sharpness: 0.209,
        delay: Duration(milliseconds: 102),
      ),
      HapticPulse(
        intensity: 0.488,
        sharpness: 0.213,
        delay: Duration(milliseconds: 101),
      ),
    ],
  ),
  'castanets': HapticPattern(
    // Castanets
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.897,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.9,
        delay: Duration(milliseconds: 198),
      ),
    ],
  ),
  'cat_paw': HapticPattern(
    // CatPaw
    taps: [
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.3,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.08,
        delay: Duration(milliseconds: 74),
      ),
    ],
  ),
  'charge': HapticPattern(
    // Charge
    taps: [
      HapticPulse(intensity: 0.65, sharpness: 0.62),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.68,
        delay: Duration(milliseconds: 900),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.82,
        delay: Duration(milliseconds: 700),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.62),
      (100, 0.35),
      (200, 0.0),
      (900, 0.0),
      (905, 0.85),
      (980, 0.5),
      (1100, 0.35),
      (1250, 0.0),
      (1600, 0.0),
      (1603, 1.0),
      (1770, 1.0),
      (1873, 0.334),
      (2046, 0.0),
    ],
    sharpness: [
      (0, 0.62),
      (200, 0.6),
      (900, 0.68),
      (1250, 0.65),
      (1600, 0.82),
      (1680, 0.7),
      (1860, 0.6),
    ],
  ),
  'chime': HapticPattern(
    // Chime
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.5),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.65,
        delay: Duration(milliseconds: 180),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.5),
      (70, 0.08),
      (150, 0.0),
      (180, 0.7),
      (260, 0.12),
      (380, 0.0),
    ],
    sharpness: [(0, 0.48), (150, 0.48), (180, 0.65), (380, 0.6)],
  ),
  'chip': HapticPattern(
    // Chip
    taps: [HapticPulse(intensity: 0.75, sharpness: 1)],
  ),
  'chirp': HapticPattern(
    // Chirp
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.65),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.68,
        delay: Duration(milliseconds: 150),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.72,
        delay: Duration(milliseconds: 130),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.35),
      (80, 0.0),
      (150, 0.45),
      (230, 0.0),
      (280, 0.55),
      (360, 0.0),
    ],
    sharpness: [(0, 0.6), (360, 0.72)],
  ),
  'clamor': HapticPattern(
    // Clamor
    taps: [
      HapticPulse(intensity: 0.8, sharpness: 0.68),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.68,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.68,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.68,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.78),
      (70, 0.0),
      (120, 0.78),
      (190, 0.0),
      (240, 0.78),
      (310, 0.0),
      (360, 0.78),
      (430, 0.0),
    ],
    sharpness: [(0, 0.68), (430, 0.68)],
  ),
  'clasp': HapticPattern(
    // Clasp
    taps: [
      HapticPulse(intensity: 0.65, sharpness: 0.72),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.78,
        delay: Duration(milliseconds: 80),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.65),
      (45, 0.0),
      (80, 0.9),
      (130, 0.3),
      (220, 0.0),
    ],
    sharpness: [(0, 0.72), (80, 0.78), (220, 0.75)],
  ),
  'cleave': HapticPattern(
    // Cleave
    taps: [
      HapticPulse(intensity: 0.85, sharpness: 0.8),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.78,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.85),
      (65, 0.0),
      (100, 0.7),
      (165, 0.2),
      (250, 0.0),
    ],
    sharpness: [(0, 0.8), (250, 0.76)],
  ),
  'coil': HapticPattern(
    // Coil
    taps: [
      HapticPulse(intensity: 0.2, sharpness: 0.4),
      HapticPulse(
        intensity: 1,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
    ],
    intensity: [
      (0, 0.0),
      (50, 0.15),
      (200, 0.2),
      (400, 0.3),
      (570, 0.4),
      (590, 0.0),
      (600, 1.0),
      (650, 0.0),
    ],
    sharpness: [(0, 0.3), (570, 0.5), (600, 0.8), (650, 0.8)],
  ),
  'coin_drop': HapticPattern(
    // CoinDrop
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.8),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.85,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.75,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.9,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.7,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.8,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.9,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.75,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.85,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.5),
      (35, 0.0),
      (120, 0.7),
      (145, 0.0),
      (210, 0.4),
      (230, 0.0),
      (300, 0.8),
      (325, 0.0),
      (380, 0.35),
      (397, 0.0),
      (460, 0.6),
      (480, 0.0),
      (520, 0.9),
      (550, 0.0),
      (590, 0.45),
      (608, 0.0),
      (650, 0.7),
      (675, 0.0),
    ],
    sharpness: [(0, 0.8), (675, 0.9)],
  ),
  'combination_lock': HapticPattern(
    // CombinationLock
    taps: [
      HapticPulse(intensity: 0.62, sharpness: 0.75),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.75,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.63,
        sharpness: 0.75,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.75,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.62,
        sharpness: 0.75,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.72,
        delay: Duration(milliseconds: 180),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 0.62),
      (25, 0.0),
      (180, 0.6),
      (201, 0.0),
      (360, 0.63),
      (381, 0.0),
      (540, 0.6),
      (561, 0.0),
      (720, 0.62),
      (741, 0.0),
      (900, 0.9),
      (935, 0.2),
      (980, 0.0),
    ],
    sharpness: [(0, 0.75), (900, 0.75), (980, 0.7)],
  ),
  'crescendo': HapticPattern(
    // Crescendo
    taps: [
      HapticPulse(
        intensity: 0.303,
        sharpness: 0.303,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.397,
        sharpness: 0.397,
        delay: Duration(milliseconds: 98),
      ),
      HapticPulse(
        intensity: 0.506,
        sharpness: 0.506,
        delay: Duration(milliseconds: 103),
      ),
      HapticPulse(
        intensity: 0.609,
        sharpness: 0.609,
        delay: Duration(milliseconds: 98),
      ),
      HapticPulse(
        intensity: 0.703,
        sharpness: 0.703,
        delay: Duration(milliseconds: 99),
      ),
      HapticPulse(
        intensity: 0.809,
        sharpness: 0.809,
        delay: Duration(milliseconds: 103),
      ),
      HapticPulse(
        intensity: 0.981,
        sharpness: 0.981,
        delay: Duration(milliseconds: 99),
      ),
    ],
  ),
  'dewdrop': HapticPattern(
    // Dewdrop
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.52),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.65,
        delay: Duration(milliseconds: 130),
      ),
    ],
    intensity: [(0, 0.0), (8, 0.4), (65, 0.0), (130, 0.6), (210, 0.0)],
    sharpness: [(0, 0.5), (130, 0.65), (210, 0.62)],
  ),
  'dirge': HapticPattern(
    // Dirge
    taps: [
      HapticPulse(intensity: 0.45, sharpness: 0.15),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.13,
        delay: Duration(milliseconds: 900),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.12,
        delay: Duration(milliseconds: 1000),
      ),
    ],
    intensity: [
      (0, 0.0),
      (30, 0.4),
      (300, 0.2),
      (700, 0.0),
      (900, 0.0),
      (930, 0.38),
      (1200, 0.18),
      (1700, 0.0),
      (1900, 0.0),
      (1930, 0.32),
      (2200, 0.12),
      (2600, 0.0),
    ],
    sharpness: [(0, 0.14), (2600, 0.11)],
  ),
  'dissolve': HapticPattern(
    // Dissolve
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.4),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.2,
        delay: Duration(milliseconds: 400),
      ),
    ],
    intensity: [
      (0, 0.0),
      (50, 0.38),
      (300, 0.28),
      (600, 0.2),
      (900, 0.12),
      (1200, 0.0),
    ],
    sharpness: [(0, 0.38), (1200, 0.18)],
  ),
  'dog_bark': HapticPattern(
    // DogBark
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.22),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.22,
        delay: Duration(milliseconds: 280),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.9),
      (50, 0.65),
      (120, 0.15),
      (200, 0.0),
      (280, 0.85),
      (325, 0.6),
      (400, 0.12),
      (500, 0.0),
    ],
    sharpness: [(0, 0.2), (500, 0.2)],
  ),
  'drone': HapticPattern(
    // Drone
    taps: [
      HapticPulse(intensity: 0.3, sharpness: 0.45),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.45,
        delay: Duration(milliseconds: 500),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.45,
        delay: Duration(milliseconds: 500),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.45,
        delay: Duration(milliseconds: 500),
      ),
    ],
    intensity: [
      (0, 0.0),
      (20, 0.28),
      (180, 0.28),
      (280, 0.0),
      (500, 0.0),
      (520, 0.28),
      (680, 0.28),
      (780, 0.0),
      (1000, 0.0),
      (1020, 0.28),
      (1180, 0.28),
      (1280, 0.0),
      (1500, 0.0),
      (1520, 0.28),
      (1680, 0.28),
      (1780, 0.0),
    ],
    sharpness: [(0, 0.45), (1780, 0.45)],
  ),
  'engine_rev': HapticPattern(
    // EngineRev
    taps: [
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.4,
        delay: Duration(milliseconds: 700),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.5,
        delay: Duration(milliseconds: 700),
      ),
    ],
    intensity: [
      (0, 0.15),
      (700, 0.75),
      (710, 0.2),
      (720, 0.25),
      (1400, 0.95),
      (1600, 0.5),
      (1800, 0.0),
    ],
    sharpness: [(0, 0.08), (700, 0.45), (720, 0.12), (1400, 0.55), (1800, 0.3)],
  ),
  'exhale': HapticPattern(
    // Exhale
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.6),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.3,
        delay: Duration(milliseconds: 150),
      ),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.15,
        delay: Duration(milliseconds: 350),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.6),
      (100, 0.4),
      (200, 0.25),
      (500, 0.2),
      (800, 0.15),
      (1200, 0.0),
    ],
    sharpness: [(0, 0.6), (200, 0.28), (1200, 0.15)],
  ),
  'explosion': HapticPattern(
    // Explosion
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.4),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.328,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.722,
        sharpness: 0.256,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.594,
        sharpness: 0.138,
        delay: Duration(milliseconds: 67),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 1.0),
      (80, 0.7),
      (200, 0.5),
      (400, 0.3),
      (700, 0.1),
      (1000, 0.0),
    ],
    sharpness: [(0, 0.2), (5, 0.15), (1000, 0.05)],
  ),
  'fade_out': HapticPattern(
    // FadeOut
    taps: [
      HapticPulse(intensity: 1, sharpness: 1),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 86),
      ),
      HapticPulse(
        intensity: 0.603,
        sharpness: 0.603,
        delay: Duration(milliseconds: 106),
      ),
      HapticPulse(
        intensity: 0.406,
        sharpness: 0.406,
        delay: Duration(milliseconds: 106),
      ),
      HapticPulse(
        intensity: 0.291,
        sharpness: 0.209,
        delay: Duration(milliseconds: 110),
      ),
      HapticPulse(
        intensity: 0.297,
        sharpness: 0.075,
        delay: Duration(milliseconds: 98),
      ),
    ],
  ),
  'fanfare': HapticPattern(
    // Fanfare
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.4),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.55,
        delay: Duration(milliseconds: 130),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.65,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 110),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.6),
      (80, 0.0),
      (130, 0.7),
      (200, 0.0),
      (250, 0.8),
      (315, 0.0),
      (360, 1.0),
      (460, 0.5),
      (580, 0.0),
    ],
    sharpness: [(0, 0.38), (130, 0.52), (250, 0.62), (360, 0.78), (580, 0.82)],
  ),
  'feather': HapticPattern(
    // Feather
    taps: [HapticPulse(intensity: 0.45, sharpness: 0.45)],
    intensity: [(0, 0.0), (10, 0.45), (70, 0.15), (180, 0.0)],
    sharpness: [(0, 0.42), (180, 0.38)],
  ),
  'finale': HapticPattern(
    // Finale
    taps: [
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.65,
        delay: Duration(milliseconds: 400),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.7),
      (75, 0.0),
      (200, 0.7),
      (275, 0.0),
      (400, 0.9),
      (520, 0.3),
      (680, 0.0),
    ],
    sharpness: [(0, 0.55), (400, 0.65), (680, 0.6)],
  ),
  'finger_drum': HapticPattern(
    // FingerDrum
    taps: [
      HapticPulse(intensity: 0.591, sharpness: 0.591),
      HapticPulse(
        intensity: 0.588,
        sharpness: 0.588,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.328,
        delay: Duration(milliseconds: 131),
      ),
    ],
  ),
  'firecracker': HapticPattern(
    // Firecracker
    taps: [
      HapticPulse(intensity: 1, sharpness: 1),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 75),
      ),
    ],
  ),
  'fizz': HapticPattern(
    // Fizz
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.65),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.7,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.73,
        delay: Duration(milliseconds: 110),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.75,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.7,
        delay: Duration(milliseconds: 90),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.5),
      (60, 0.15),
      (120, 0.6),
      (178, 0.1),
      (230, 0.7),
      (290, 0.15),
      (330, 0.75),
      (390, 0.2),
      (420, 0.65),
      (500, 0.0),
    ],
    sharpness: [(0, 0.62), (420, 0.72), (500, 0.68)],
  ),
  'flare': HapticPattern(
    // Flare
    taps: [
      HapticPulse(intensity: 0.2, sharpness: 0.7),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.8,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.9,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.85,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.75,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [
      (0, 0.0),
      (20, 0.18),
      (60, 0.52),
      (90, 0.95),
      (100, 1.0),
      (120, 0.75),
      (140, 0.65),
      (200, 0.35),
      (380, 0.0),
    ],
    sharpness: [(0, 0.7), (60, 0.82), (100, 0.92), (200, 0.75), (380, 0.6)],
  ),
  'flick': HapticPattern(
    // Flick
    taps: [HapticPulse(intensity: 0.42, sharpness: 0.5)],
    intensity: [(0, 0.0), (6, 0.4), (45, 0.05), (80, 0.0)],
    sharpness: [(0, 0.5), (80, 0.5)],
  ),
  'flinch': HapticPattern(
    // Flinch
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.75),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.7,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.58,
        delay: Duration(milliseconds: 80),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 0.95),
      (60, 0.3),
      (120, 0.8),
      (170, 0.4),
      (280, 0.0),
    ],
    sharpness: [(0, 0.73), (120, 0.68), (280, 0.55)],
  ),
  'flourish': HapticPattern(
    // Flourish
    taps: [
      HapticPulse(intensity: 0.25, sharpness: 0.45),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.65,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.78,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.62,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.628,
        sharpness: 0.628,
        delay: Duration(milliseconds: 84),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.6,
        delay: Duration(milliseconds: 98),
      ),
      HapticPulse(
        intensity: 0.456,
        sharpness: 0.456,
        delay: Duration(milliseconds: 72),
      ),
      HapticPulse(
        intensity: 0.303,
        sharpness: 0.303,
        delay: Duration(milliseconds: 73),
      ),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.2,
        delay: Duration(milliseconds: 90),
      ),
    ],
    intensity: [
      (0, 0.0),
      (50, 0.2),
      (200, 0.65),
      (380, 0.95),
      (480, 0.5),
      (650, 0.0),
    ],
    sharpness: [(0, 0.43), (380, 0.78), (650, 0.65)],
  ),
  'flurry': HapticPattern(
    // Flurry
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.55),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.6,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.65,
        delay: Duration(milliseconds: 55),
      ),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.7,
        delay: Duration(milliseconds: 50),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.45),
      (40, 0.0),
      (60, 0.55),
      (95, 0.0),
      (115, 0.65),
      (148, 0.0),
      (165, 0.82),
      (240, 0.1),
      (300, 0.0),
    ],
    sharpness: [(0, 0.55), (165, 0.72), (300, 0.7)],
  ),
  'flush': HapticPattern(
    // Flush
    taps: [
      HapticPulse(intensity: 0.25, sharpness: 0.3),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.35,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.3,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.25,
        delay: Duration(milliseconds: 50),
      ),
    ],
    intensity: [
      (0, 0.0),
      (30, 0.22),
      (80, 0.45),
      (100, 0.78),
      (140, 0.52),
      (200, 0.2),
      (380, 0.0),
    ],
    sharpness: [(0, 0.3), (100, 0.35), (150, 0.28), (380, 0.22)],
  ),
  'gallop': HapticPattern(
    // Gallop
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.603,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.163,
        delay: Duration(milliseconds: 145),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.609,
        delay: Duration(milliseconds: 446),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.153,
        delay: Duration(milliseconds: 149),
      ),
    ],
  ),
  'gavel': HapticPattern(
    // Gavel
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.106,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.609,
        delay: Duration(milliseconds: 191),
      ),
    ],
  ),
  'glitch': HapticPattern(
    // Glitch
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.9),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.3,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.95,
        delay: Duration(milliseconds: 25),
      ),
      HapticPulse(
        intensity: 0.1,
        sharpness: 0.2,
        delay: Duration(milliseconds: 15),
      ),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.85,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.05,
        sharpness: 0.1,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.9,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.4,
        delay: Duration(milliseconds: 25),
      ),
    ],
    intensity: [
      (0, 0.9),
      (20, 0.1),
      (55, 1.0),
      (65, 0.0),
      (100, 0.85),
      (118, 0.0),
      (160, 0.95),
      (175, 0.15),
      (220, 0.0),
    ],
    sharpness: [
      (0, 0.9),
      (20, 0.2),
      (55, 1.0),
      (65, 0.1),
      (100, 0.88),
      (118, 0.15),
      (160, 0.92),
      (220, 0.3),
    ],
  ),
  'guitar_strum': HapticPattern(
    // GuitarStrum
    taps: [HapticPulse(intensity: 0.9, sharpness: 0.55)],
    intensity: [
      (0, 0.0),
      (5, 0.9),
      (60, 0.65),
      (200, 0.45),
      (450, 0.28),
      (750, 0.14),
      (1100, 0.05),
      (1400, 0.0),
    ],
    sharpness: [(0, 0.58), (5, 0.55), (1400, 0.52)],
  ),
  'hail': HapticPattern(
    // Hail
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.7),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.75,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.65,
        delay: Duration(milliseconds: 35),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.8,
        delay: Duration(milliseconds: 25),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.7,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.75,
        delay: Duration(milliseconds: 35),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.85,
        delay: Duration(milliseconds: 25),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.65,
        delay: Duration(milliseconds: 35),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.78,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.7,
        delay: Duration(milliseconds: 30),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.82,
        delay: Duration(milliseconds: 25),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.68,
        delay: Duration(milliseconds: 35),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.74,
        delay: Duration(milliseconds: 25),
      ),
    ],
    intensity: [(0, 0.0), (10, 0.3), (400, 0.3), (430, 0.0)],
    sharpness: [(0, 0.7), (430, 0.7)],
  ),
  'hammer': HapticPattern(
    // Hammer
    taps: [
      HapticPulse(intensity: 0.75, sharpness: 0.3),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.32,
        delay: Duration(milliseconds: 220),
      ),
      HapticPulse(
        intensity: 0.88,
        sharpness: 0.3,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.92,
        sharpness: 0.32,
        delay: Duration(milliseconds: 170),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 150),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 130),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.75),
      (90, 0.05),
      (180, 0.0),
      (220, 0.8),
      (310, 0.05),
      (380, 0.0),
      (420, 0.88),
      (508, 0.05),
      (550, 0.0),
      (590, 0.92),
      (678, 0.05),
      (710, 0.0),
      (740, 1.0),
      (816, 0.05),
      (840, 0.0),
      (870, 1.0),
      (950, 0.05),
      (1050, 0.0),
    ],
    sharpness: [(0, 0.28), (1050, 0.28)],
  ),
  'heartbeat': HapticPattern(
    // Heartbeat
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.2),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.2,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.2,
        delay: Duration(milliseconds: 680),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.2,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.8),
      (80, 0.0),
      (120, 0.5),
      (200, 0.0),
      (800, 0.0),
      (810, 0.8),
      (880, 0.0),
      (920, 0.5),
      (1000, 0.0),
    ],
    sharpness: [(0, 0.2), (1000, 0.2)],
  ),
  'herald': HapticPattern(
    // Herald
    taps: [
      HapticPulse(intensity: 0.497, sharpness: 0.497),
      HapticPulse(
        intensity: 0.497,
        sharpness: 0.497,
        delay: Duration(milliseconds: 89),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 119),
      ),
    ],
  ),
  'hoof_beat': HapticPattern(
    // HoofBeat
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.106,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.109,
        delay: Duration(milliseconds: 191),
      ),
    ],
  ),
  'ignition': HapticPattern(
    // Ignition
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.203,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.697,
        sharpness: 0.5,
        delay: Duration(milliseconds: 76),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.703,
        delay: Duration(milliseconds: 96),
      ),
    ],
  ),
  'impact': HapticPattern(
    // Impact
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.6),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.5,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.4,
        delay: Duration(milliseconds: 70),
      ),
    ],
    intensity: [(0, 0.0), (5, 0.85), (60, 0.35), (120, 0.15), (200, 0.0)],
    sharpness: [(0, 0.6), (200, 0.35)],
  ),
  'jolt': HapticPattern(
    // Jolt
    taps: [HapticPulse(intensity: 1, sharpness: 1)],
  ),
  'keyboard_mechanical': HapticPattern(
    // KeyboardMechanical
    taps: [
      HapticPulse(intensity: 0.55, sharpness: 0.68),
      HapticPulse(
        intensity: 0.72,
        sharpness: 0.74,
        delay: Duration(milliseconds: 22),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 0.52),
      (18, 0.2),
      (22, 0.7),
      (38, 0.15),
      (55, 0.0),
    ],
    sharpness: [(0, 0.68), (22, 0.76), (55, 0.7)],
  ),
  'keyboard_membrane': HapticPattern(
    // KeyboardMembrane
    taps: [HapticPulse(intensity: 0.35, sharpness: 0.38)],
    intensity: [(0, 0.0), (12, 0.33), (50, 0.18), (100, 0.06), (140, 0.0)],
    sharpness: [(0, 0.38), (140, 0.35)],
  ),
  'knell': HapticPattern(
    // Knell
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.58),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.5,
        delay: Duration(milliseconds: 350),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.9),
      (200, 0.5),
      (300, 0.1),
      (350, 0.5),
      (430, 0.1),
      (550, 0.0),
    ],
    sharpness: [(0, 0.58), (300, 0.52), (550, 0.48)],
  ),
  'knock': HapticPattern(
    // Knock
    taps: [
      HapticPulse(intensity: 0.65, sharpness: 0.35),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.35,
        delay: Duration(milliseconds: 280),
      ),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.35,
        delay: Duration(milliseconds: 280),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.65),
      (70, 0.08),
      (200, 0.0),
      (280, 0.65),
      (348, 0.08),
      (480, 0.0),
      (560, 0.65),
      (628, 0.08),
      (760, 0.0),
    ],
    sharpness: [(0, 0.32), (760, 0.32)],
  ),
  'lament': HapticPattern(
    // Lament
    taps: [
      HapticPulse(intensity: 0.85, sharpness: 0.55),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.42,
        delay: Duration(milliseconds: 350),
      ),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.37,
        delay: Duration(milliseconds: 350),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.3,
        delay: Duration(milliseconds: 350),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.85),
      (190, 0.3),
      (295, 0.0),
      (355, 0.7),
      (535, 0.25),
      (645, 0.0),
      (705, 0.55),
      (880, 0.18),
      (995, 0.0),
      (1055, 0.75),
      (1620, 0.35),
      (2150, 0.1),
      (2450, 0.0),
    ],
    sharpness: [(0, 0.55), (350, 0.42), (700, 0.37), (1050, 0.3), (2450, 0.26)],
  ),
  'latch': HapticPattern(
    // Latch
    taps: [
      HapticPulse(intensity: 0.75, sharpness: 0.68),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.45,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.72),
      (60, 0.15),
      (100, 0.38),
      (170, 0.08),
      (230, 0.0),
    ],
    sharpness: [(0, 0.68), (100, 0.45), (230, 0.42)],
  ),
  'lighthouse': HapticPattern(
    // Lighthouse
    taps: [
      HapticPulse(intensity: 0.45, sharpness: 0.5),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.5,
        delay: Duration(milliseconds: 400),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.5,
        delay: Duration(milliseconds: 400),
      ),
    ],
    intensity: [
      (0, 0.0),
      (15, 0.4),
      (150, 0.4),
      (250, 0.0),
      (400, 0.0),
      (415, 0.4),
      (550, 0.4),
      (650, 0.0),
      (800, 0.0),
      (815, 0.4),
      (950, 0.4),
      (1050, 0.0),
    ],
    sharpness: [(0, 0.5), (1050, 0.5)],
  ),
  'lilt': HapticPattern(
    // Lilt
    taps: [
      HapticPulse(intensity: 0.45, sharpness: 0.52),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.65,
        delay: Duration(milliseconds: 160),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.45),
      (72, 0.0),
      (160, 0.65),
      (240, 0.12),
      (360, 0.0),
    ],
    sharpness: [(0, 0.5), (160, 0.65), (360, 0.6)],
  ),
  'lock': HapticPattern(
    // Lock
    taps: [
      HapticPulse(intensity: 0.3, sharpness: 0.5),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.7,
        delay: Duration(milliseconds: 150),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.25),
      (100, 0.15),
      (140, 0.0),
      (150, 0.9),
      (175, 0.2),
      (220, 0.0),
    ],
    sharpness: [(0, 0.4), (140, 0.5), (150, 0.75), (220, 0.6)],
  ),
  'lope': HapticPattern(
    // Lope
    taps: [
      HapticPulse(intensity: 0.7, sharpness: 0.72),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.65,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.72,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.65,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.75,
        delay: Duration(milliseconds: 80),
      ),
    ],
    intensity: [
      (0, 0.0),
      (6, 0.68),
      (60, 0.15),
      (80, 0.43),
      (140, 0.12),
      (160, 0.68),
      (220, 0.15),
      (240, 0.43),
      (300, 0.12),
      (320, 0.73),
      (450, 0.0),
    ],
    sharpness: [(0, 0.72), (450, 0.7)],
  ),
  'march': HapticPattern(
    // March
    taps: [
      HapticPulse(intensity: 0.65, sharpness: 0.28),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.28,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.28,
        delay: Duration(milliseconds: 300),
      ),
    ],
    intensity: [
      (0, 0.0),
      (15, 0.6),
      (150, 0.45),
      (250, 0.0),
      (300, 0.0),
      (315, 0.65),
      (450, 0.5),
      (550, 0.0),
      (600, 0.0),
      (615, 0.6),
      (750, 0.4),
      (900, 0.0),
    ],
    sharpness: [(0, 0.25), (900, 0.25)],
  ),
  'metronome': HapticPattern(
    // Metronome
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.5),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.5,
        delay: Duration(milliseconds: 200),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.45),
      (80, 0.0),
      (200, 0.0),
      (208, 0.45),
      (280, 0.0),
    ],
    sharpness: [(0, 0.5), (280, 0.5)],
  ),
  'murmur': HapticPattern(
    // Murmur
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.303),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.3,
        delay: Duration(milliseconds: 80),
      ),
    ],
  ),
  'nudge': HapticPattern(
    // Nudge
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.5),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.5,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [(0, 0.0), (10, 0.6), (60, 0.0), (120, 0.4), (180, 0.0)],
    sharpness: [(0, 0.5), (180, 0.5)],
  ),
  'passing_car': HapticPattern(
    // PassingCar
    intensity: [
      (0, 0.0),
      (80, 0.1),
      (200, 0.35),
      (350, 0.75),
      (450, 1.0),
      (550, 0.7),
      (700, 0.3),
      (900, 0.08),
      (1100, 0.0),
    ],
    sharpness: [(0, 0.35), (200, 0.42), (450, 0.38), (700, 0.3), (1100, 0.22)],
  ),
  'patter': HapticPattern(
    // Patter
    taps: [
      HapticPulse(intensity: 0.603, sharpness: 0.2),
      HapticPulse(
        intensity: 0.606,
        sharpness: 0.197,
        delay: Duration(milliseconds: 82),
      ),
      HapticPulse(
        intensity: 0.609,
        sharpness: 0.594,
        delay: Duration(milliseconds: 97),
      ),
    ],
  ),
  'peal': HapticPattern(
    // Peal
    taps: [
      HapticPulse(intensity: 0.75, sharpness: 0.62),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.62,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.62,
        delay: Duration(milliseconds: 180),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.75),
      (80, 0.0),
      (180, 0.75),
      (258, 0.0),
      (360, 0.75),
      (438, 0.0),
    ],
    sharpness: [(0, 0.62), (438, 0.62)],
  ),
  'peck': HapticPattern(
    // Peck
    taps: [HapticPulse(intensity: 0.55, sharpness: 0.58)],
    intensity: [(0, 0.0), (4, 0.55), (28, 0.0)],
    sharpness: [(0, 0.58), (28, 0.56)],
  ),
  'pendulum': HapticPattern(
    // Pendulum
    taps: [
      HapticPulse(
        intensity: 0.12,
        sharpness: 0.35,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.08,
        sharpness: 0.35,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.05,
        sharpness: 0.35,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.02,
        sharpness: 0.35,
        delay: Duration(milliseconds: 600),
      ),
    ],
    intensity: [
      (0, 0.7),
      (300, 0.08),
      (600, 0.5),
      (900, 0.05),
      (1200, 0.3),
      (1500, 0.03),
      (1800, 0.15),
      (2100, 0.01),
      (2400, 0.0),
    ],
    sharpness: [(0, 0.42), (2400, 0.38)],
  ),
  'ping': HapticPattern(
    // Ping
    taps: [HapticPulse(intensity: 0.65, sharpness: 0.72)],
    intensity: [(0, 0.0), (4, 0.65), (35, 0.0)],
    sharpness: [(0, 0.72), (35, 0.68)],
  ),
  'pip': HapticPattern(
    // Pip
    taps: [
      HapticPulse(intensity: 0.35, sharpness: 0.65),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.7,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [(0, 0.0), (5, 0.32), (40, 0.0), (60, 0.22), (100, 0.0)],
    sharpness: [(0, 0.65), (100, 0.7)],
  ),
  'piston': HapticPattern(
    // Piston
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.397),
      HapticPulse(
        intensity: 1,
        sharpness: 0.397,
        delay: Duration(milliseconds: 73),
      ),
    ],
  ),
  'plink': HapticPattern(
    // Plink
    taps: [
      HapticPulse(intensity: 0.55, sharpness: 0.52),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.52,
        delay: Duration(milliseconds: 150),
      ),
    ],
    intensity: [(0, 0.0), (8, 0.55), (65, 0.0), (150, 0.55), (215, 0.0)],
    sharpness: [(0, 0.52), (215, 0.52)],
  ),
  'plummet': HapticPattern(
    // Plummet
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.4,
        delay: Duration(milliseconds: 900),
      ),
    ],
    intensity: [
      (0, 0.0),
      (300, 0.02),
      (600, 0.06),
      (800, 0.15),
      (880, 0.3),
      (895, 0.5),
      (900, 0.0),
      (905, 1.0),
      (960, 0.4),
      (1050, 0.0),
    ],
    sharpness: [(0, 0.3), (895, 0.4), (905, 0.3), (1050, 0.25)],
  ),
  'plunk': HapticPattern(
    // Plunk
    taps: [HapticPulse(intensity: 0.5, sharpness: 0.2)],
  ),
  'poke': HapticPattern(
    // Poke
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.6),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.6,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.65,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.6),
      (62, 0.0),
      (100, 0.6),
      (162, 0.0),
      (200, 0.7),
      (280, 0.0),
    ],
    sharpness: [(0, 0.6), (200, 0.65), (280, 0.63)],
  ),
  'pound': HapticPattern(
    // Pound
    taps: [
      HapticPulse(intensity: 0.95, sharpness: 0.7),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.7,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.7,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.95),
      (65, 0.0),
      (100, 0.95),
      (165, 0.0),
      (200, 0.95),
      (265, 0.0),
    ],
    sharpness: [(0, 0.72), (265, 0.72)],
  ),
  'power_down': HapticPattern(
    // PowerDown
    taps: [HapticPulse(intensity: 0.8, sharpness: 0.6)],
    intensity: [
      (0, 0.8),
      (200, 0.7),
      (450, 0.55),
      (750, 0.4),
      (1050, 0.25),
      (1350, 0.12),
      (1600, 0.03),
      (1800, 0.0),
    ],
    sharpness: [(0, 0.6), (1800, 0.03)],
  ),
  'propel': HapticPattern(
    // Propel
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.58),
      HapticPulse(
        intensity: 0.9,
        sharpness: 0.72,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.55),
      (70, 0.2),
      (120, 0.88),
      (200, 0.2),
      (300, 0.0),
    ],
    sharpness: [(0, 0.56), (120, 0.72), (300, 0.65)],
  ),
  'pulse': HapticPattern(
    // Pulse
    intensity: [
      (0, 0.0),
      (300, 0.3),
      (700, 0.3),
      (1000, 0.0),
      (1300, 0.3),
      (1700, 0.3),
      (2000, 0.0),
    ],
    sharpness: [(0, 0.4), (2000, 0.4)],
  ),
  'pummel': HapticPattern(
    // Pummel
    taps: [
      HapticPulse(intensity: 0.9, sharpness: 0.85),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.95,
        sharpness: 0.87,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.83,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.88,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 0.9),
      (45, 0.6),
      (70, 0.78),
      (100, 0.55),
      (130, 0.92),
      (165, 0.65),
      (190, 0.82),
      (230, 0.7),
      (250, 1.0),
      (320, 0.4),
      (450, 0.0),
    ],
    sharpness: [(0, 0.85), (450, 0.82)],
  ),
  'push': HapticPattern(
    // Push
    taps: [HapticPulse(intensity: 0.5, sharpness: 0.52)],
    intensity: [(0, 0.0), (6, 0.48), (50, 0.15), (90, 0.0)],
    sharpness: [(0, 0.52), (90, 0.5)],
  ),
  'radar': HapticPattern(
    // Radar
    taps: [
      HapticPulse(intensity: 0.55, sharpness: 0.55),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.55,
        delay: Duration(milliseconds: 800),
      ),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.55,
        delay: Duration(milliseconds: 800),
      ),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.55,
        delay: Duration(milliseconds: 800),
      ),
    ],
    intensity: [
      (0, 0.0),
      (6, 0.55),
      (50, 0.2),
      (120, 0.0),
      (800, 0.0),
      (806, 0.55),
      (850, 0.2),
      (920, 0.0),
      (1600, 0.0),
      (1606, 0.55),
      (1650, 0.2),
      (1720, 0.0),
      (2400, 0.0),
      (2406, 0.55),
      (2450, 0.2),
      (2520, 0.0),
    ],
    sharpness: [(0, 0.55), (2520, 0.55)],
  ),
  'rain': HapticPattern(
    // Rain
    taps: [
      HapticPulse(intensity: 0.2, sharpness: 0.6),
      HapticPulse(
        intensity: 0.15,
        sharpness: 0.5,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.7,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.1,
        sharpness: 0.5,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.6,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.55,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.65,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.1,
        sharpness: 0.5,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.6,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.15,
        sharpness: 0.55,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.7,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.2,
        sharpness: 0.6,
        delay: Duration(milliseconds: 90),
      ),
    ],
    intensity: [
      (0, 0.0),
      (50, 0.08),
      (200, 0.05),
      (400, 0.08),
      (600, 0.05),
      (850, 0.08),
      (950, 0.0),
    ],
    sharpness: [(0, 0.6), (950, 0.6)],
  ),
  'ramp': HapticPattern(
    // Ramp
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.5),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.6,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.7,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 140),
      ),
    ],
    intensity: [
      (0, 0.0),
      (15, 0.38),
      (80, 0.0),
      (120, 0.55),
      (190, 0.0),
      (240, 0.72),
      (310, 0.0),
      (380, 1.0),
      (520, 0.2),
      (650, 0.0),
    ],
    sharpness: [(0, 0.48), (380, 0.78), (650, 0.75)],
  ),
  'rap': HapticPattern(
    // Rap
    taps: [
      HapticPulse(intensity: 0.6, sharpness: 0.5),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.5,
        delay: Duration(milliseconds: 120),
      ),
    ],
  ),
  'ratchet': HapticPattern(
    // Ratchet
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.9,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.906,
        delay: Duration(milliseconds: 191),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.906,
        delay: Duration(milliseconds: 197),
      ),
    ],
  ),
  'rebound': HapticPattern(
    // Rebound
    taps: [
      HapticPulse(intensity: 1, sharpness: 1),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 80),
      ),
    ],
  ),
  'ripple': HapticPattern(
    // Ripple
    taps: [
      HapticPulse(intensity: 0.858, sharpness: 0.72),
      HapticPulse(
        intensity: 0.52,
        sharpness: 0.48,
        delay: Duration(milliseconds: 140),
      ),
      HapticPulse(
        intensity: 0.22,
        sharpness: 0.32,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.08,
        sharpness: 0.2,
        delay: Duration(milliseconds: 100),
      ),
    ],
    intensity: [
      (0, 0.0),
      (70, 0.0),
      (145, 0.5),
      (200, 0.0),
      (265, 0.2),
      (310, 0.0),
      (365, 0.07),
      (420, 0.0),
    ],
    sharpness: [(0, 0.7), (140, 0.5), (260, 0.33), (420, 0.18)],
  ),
  'rivet': HapticPattern(
    // Rivet
    taps: [
      HapticPulse(intensity: 1, sharpness: 1),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 75),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 75),
      ),
    ],
  ),
  'rustle': HapticPattern(
    // Rustle
    intensity: [(0, 0.0), (8, 0.65), (75, 0.05), (200, 0.3), (290, 0.0)],
    sharpness: [(0, 0.6), (200, 0.48), (290, 0.45)],
  ),
  'shockwave': HapticPattern(
    // Shockwave
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.35),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.3,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.15,
        sharpness: 0.25,
        delay: Duration(milliseconds: 250),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 1.0),
      (50, 0.7),
      (120, 0.45),
      (200, 0.3),
      (320, 0.15),
      (450, 0.08),
      (600, 0.03),
      (800, 0.0),
    ],
    sharpness: [(0, 0.4), (5, 0.3), (800, 0.2)],
  ),
  'snap': HapticPattern(
    // Snap
    taps: [
      HapticPulse(intensity: 0.7, sharpness: 0.55),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.48,
        delay: Duration(milliseconds: 40),
      ),
    ],
    intensity: [(0, 0.0), (4, 0.7), (30, 0.15), (40, 0.3), (90, 0.0)],
    sharpness: [(0, 0.55), (40, 0.47), (90, 0.45)],
  ),
  'sonar': HapticPattern(
    // Sonar
    taps: [
      HapticPulse(intensity: 0.35, sharpness: 0.7),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.65,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.6,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.35),
      (130, 0.04),
      (500, 0.0),
      (600, 0.35),
      (730, 0.04),
      (1100, 0.0),
      (1200, 0.35),
      (1330, 0.04),
      (1550, 0.0),
      (1620, 0.0),
      (1663, 0.855),
      (1700, 0.0),
      (1800, 0.65),
      (1855, 0.0),
      (1920, 0.4),
      (2000, 0.0),
    ],
    sharpness: [(0, 0.72), (1550, 0.72), (1655, 0.8), (2000, 0.7)],
  ),
  'spark': HapticPattern(
    // Spark
    taps: [
      HapticPulse(intensity: 0.22, sharpness: 0.55),
      HapticPulse(
        intensity: 0.52,
        sharpness: 0.78,
        delay: Duration(milliseconds: 65),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 73),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 0.22),
      (28, 0.0),
      (69, 0.52),
      (95, 0.0),
      (142, 1.0),
      (185, 0.0),
    ],
    sharpness: [(0, 0.5), (65, 0.75), (138, 1.0), (185, 1.0)],
  ),
  'spin': HapticPattern(
    // Spin
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.55),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 250),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.38),
      (60, 0.0),
      (250, 0.38),
      (308, 0.0),
      (500, 0.38),
      (558, 0.0),
      (750, 0.38),
      (808, 0.0),
      (1000, 0.38),
      (1058, 0.0),
      (1250, 0.38),
      (1308, 0.0),
      (1500, 0.38),
      (1558, 0.0),
      (1750, 0.38),
      (1808, 0.0),
    ],
    sharpness: [(0, 0.55), (1808, 0.55)],
  ),
  'stagger': HapticPattern(
    // Stagger
    taps: [
      HapticPulse(intensity: 0.7, sharpness: 0.55),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.65,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.5,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.6,
        delay: Duration(milliseconds: 60),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.68),
      (45, 0.15),
      (60, 0.38),
      (100, 0.15),
      (120, 0.52),
      (162, 0.12),
      (180, 0.33),
      (320, 0.0),
    ],
    sharpness: [(0, 0.55), (60, 0.65), (120, 0.5), (180, 0.6), (320, 0.55)],
  ),
  'stamp': HapticPattern(
    // Stamp
    taps: [
      HapticPulse(intensity: 0.55, sharpness: 0.5),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.5,
        delay: Duration(milliseconds: 150),
      ),
    ],
    intensity: [(0, 0.0), (8, 0.55), (55, 0.0), (150, 0.55), (205, 0.0)],
    sharpness: [(0, 0.5), (205, 0.5)],
  ),
  'stampede': HapticPattern(
    // Stampede
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.306,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.163,
        delay: Duration(milliseconds: 145),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.303,
        delay: Duration(milliseconds: 446),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.153,
        delay: Duration(milliseconds: 149),
      ),
    ],
  ),
  'stomp': HapticPattern(
    // Stomp
    taps: [
      HapticPulse(intensity: 1, sharpness: 0.3),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 75),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 75),
      ),
    ],
  ),
  'stone_skip': HapticPattern(
    // StoneSkip
    taps: [
      HapticPulse(
        intensity: 0.706,
        sharpness: 0.706,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.697,
        sharpness: 0.5,
        delay: Duration(milliseconds: 76),
      ),
      HapticPulse(
        intensity: 0.703,
        sharpness: 0.244,
        delay: Duration(milliseconds: 104),
      ),
    ],
  ),
  'strike': HapticPattern(
    // Strike
    taps: [HapticPulse(intensity: 0.75, sharpness: 0.62)],
    intensity: [(0, 0.0), (5, 0.72), (40, 0.2), (80, 0.0)],
    sharpness: [(0, 0.62), (80, 0.6)],
  ),
  'summon': HapticPattern(
    // Summon
    taps: [
      HapticPulse(intensity: 0.8, sharpness: 0.55),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.6,
        delay: Duration(milliseconds: 300),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.6,
        delay: Duration(milliseconds: 130),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.8),
      (180, 0.0),
      (300, 0.7),
      (370, 0.0),
      (430, 0.7),
      (500, 0.0),
    ],
    sharpness: [(0, 0.52), (180, 0.52), (300, 0.62), (500, 0.62)],
  ),
  'surge': HapticPattern(
    // Surge
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.82),
      HapticPulse(
        intensity: 0.62,
        sharpness: 0.86,
        delay: Duration(milliseconds: 75),
      ),
      HapticPulse(
        intensity: 0.74,
        sharpness: 0.9,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.92,
        delay: Duration(milliseconds: 65),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.45),
      (60, 0.1),
      (75, 0.58),
      (130, 0.12),
      (145, 0.7),
      (195, 0.15),
      (210, 0.8),
      (330, 0.0),
    ],
    sharpness: [(0, 0.82), (210, 0.93), (330, 0.9)],
  ),
  'sway': HapticPattern(
    // Sway
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.25),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.25,
        delay: Duration(milliseconds: 700),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.25,
        delay: Duration(milliseconds: 700),
      ),
    ],
    intensity: [
      (0, 0.0),
      (20, 0.45),
      (250, 0.35),
      (500, 0.0),
      (700, 0.0),
      (720, 0.45),
      (950, 0.35),
      (1200, 0.0),
      (1400, 0.0),
      (1420, 0.45),
      (1650, 0.35),
      (1900, 0.0),
    ],
    sharpness: [(0, 0.22), (1900, 0.22)],
  ),
  'sweep': HapticPattern(
    // Sweep
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.7),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.7,
        delay: Duration(milliseconds: 600),
      ),
    ],
    intensity: [
      (0, 0.0),
      (8, 0.4),
      (120, 0.05),
      (400, 0.02),
      (590, 0.0),
      (600, 0.4),
      (720, 0.05),
      (1000, 0.02),
      (1190, 0.0),
      (1200, 0.4),
      (1320, 0.05),
      (1600, 0.02),
      (1790, 0.0),
      (1800, 0.4),
      (1920, 0.05),
      (2100, 0.0),
    ],
    sharpness: [(0, 0.72), (2100, 0.72)],
  ),
  'swell': HapticPattern(
    // Swell
    taps: [
      HapticPulse(intensity: 0.45, sharpness: 0.48),
      HapticPulse(
        intensity: 0.65,
        sharpness: 0.52,
        delay: Duration(milliseconds: 350),
      ),
    ],
    intensity: [(0, 0.0), (10, 0.45), (75, 0.0), (350, 0.65), (425, 0.0)],
    sharpness: [(0, 0.45), (350, 0.52), (425, 0.52)],
  ),
  'syncopate': HapticPattern(
    // Syncopate
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.903,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.513,
        delay: Duration(milliseconds: 191),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.906,
        delay: Duration(milliseconds: 198),
      ),
    ],
  ),
  'throb': HapticPattern(
    // Throb
    taps: [
      HapticPulse(intensity: 0.8, sharpness: 0.65),
      HapticPulse(
        intensity: 0.45,
        sharpness: 0.6,
        delay: Duration(milliseconds: 150),
      ),
    ],
    intensity: [(0, 0.0), (8, 0.8), (80, 0.0), (150, 0.45), (230, 0.0)],
    sharpness: [(0, 0.65), (230, 0.6)],
  ),
  'thud': HapticPattern(
    // Thud
    taps: [HapticPulse(intensity: 0.5, sharpness: 0.42)],
    intensity: [(0, 0.0), (15, 0.45), (80, 0.35), (160, 0.0)],
    sharpness: [(0, 0.42), (160, 0.4)],
  ),
  'thump': HapticPattern(
    // Thump
    taps: [HapticPulse(intensity: 1, sharpness: 0.45)],
  ),
  'thunder': HapticPattern(
    // Thunder
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.15,
        delay: Duration(milliseconds: 600),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.12,
        delay: Duration(milliseconds: 100),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.1,
        delay: Duration(milliseconds: 200),
      ),
      HapticPulse(
        intensity: 0.3,
        sharpness: 0.08,
        delay: Duration(milliseconds: 300),
      ),
    ],
    intensity: [
      (0, 0.0),
      (100, 0.05),
      (300, 0.1),
      (500, 0.2),
      (590, 0.3),
      (600, 1.0),
      (680, 0.7),
      (800, 0.5),
      (1000, 0.3),
      (1300, 0.15),
      (1700, 0.05),
      (2000, 0.0),
    ],
    sharpness: [(0, 0.1), (600, 0.08), (2000, 0.05)],
  ),
  'thunder_roll': HapticPattern(
    // ThunderRoll
    taps: [
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.053,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.122,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.228,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.394,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.613,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.803,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 1,
        delay: Duration(milliseconds: 59),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 0.606,
        sharpness: 0.606,
        delay: Duration(milliseconds: 62),
      ),
      HapticPulse(
        intensity: 0.394,
        sharpness: 0.394,
        delay: Duration(milliseconds: 62),
      ),
      HapticPulse(
        intensity: 0.194,
        sharpness: 0.194,
        delay: Duration(milliseconds: 61),
      ),
      HapticPulse(
        intensity: 0.091,
        sharpness: 0.091,
        delay: Duration(milliseconds: 65),
      ),
    ],
  ),
  'tick_tock': HapticPattern(
    // TickTock
    taps: [
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.4,
        delay: Duration(milliseconds: 399),
      ),
      HapticPulse(
        intensity: 0.8,
        sharpness: 0.8,
        delay: Duration(milliseconds: 400),
      ),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.4,
        delay: Duration(milliseconds: 400),
      ),
    ],
  ),
  'tidal_surge': HapticPattern(
    // TidalSurge
    taps: [
      HapticPulse(
        intensity: 0.594,
        sharpness: 0.594,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.588,
        sharpness: 0.588,
        delay: Duration(milliseconds: 72),
      ),
      HapticPulse(
        intensity: 0.588,
        sharpness: 0.588,
        delay: Duration(milliseconds: 78),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 148),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.303,
        delay: Duration(milliseconds: 81),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.3,
        delay: Duration(milliseconds: 75),
      ),
    ],
  ),
  'tide_swell': HapticPattern(
    // TideSwell
    taps: [
      HapticPulse(
        intensity: 0.775,
        sharpness: 0.053,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.722,
        sharpness: 0.122,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.228,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 0.653,
        sharpness: 0.394,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.638,
        sharpness: 0.613,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 0.622,
        sharpness: 0.803,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 0.606,
        sharpness: 1,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 1,
        delay: Duration(milliseconds: 59),
      ),
      HapticPulse(
        intensity: 0.606,
        sharpness: 0.8,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 0.609,
        sharpness: 0.606,
        delay: Duration(milliseconds: 62),
      ),
      HapticPulse(
        intensity: 0.647,
        sharpness: 0.394,
        delay: Duration(milliseconds: 67),
      ),
      HapticPulse(
        intensity: 0.684,
        sharpness: 0.181,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.728,
        sharpness: 0.075,
        delay: Duration(milliseconds: 65),
      ),
      HapticPulse(
        intensity: 0.775,
        sharpness: 0.034,
        delay: Duration(milliseconds: 57),
      ),
    ],
  ),
  'tremor': HapticPattern(
    // Tremor
    taps: [HapticPulse(intensity: 1, sharpness: 0)],
  ),
  'trigger': HapticPattern(
    // Trigger
    taps: [
      HapticPulse(intensity: 0.872, sharpness: 0.7),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.55,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.25,
        sharpness: 0.45,
        delay: Duration(milliseconds: 120),
      ),
    ],
    intensity: [
      (0, 0.0),
      (4, 1.0),
      (55, 0.35),
      (80, 0.5),
      (140, 0.2),
      (200, 0.25),
      (280, 0.0),
    ],
    sharpness: [(0, 0.72), (80, 0.55), (280, 0.42)],
  ),
  'triumph': HapticPattern(
    // Triumph
    taps: [
      HapticPulse(intensity: 0.4, sharpness: 0.55),
      HapticPulse(
        intensity: 0.55,
        sharpness: 0.6,
        delay: Duration(milliseconds: 120),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.65,
        delay: Duration(milliseconds: 140),
      ),
      HapticPulse(
        intensity: 0.85,
        sharpness: 0.7,
        delay: Duration(milliseconds: 160),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 180),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 150),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 150),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.4),
      (70, 0.0),
      (120, 0.55),
      (180, 0.0),
      (260, 0.7),
      (320, 0.0),
      (420, 0.85),
      (480, 0.0),
      (600, 1.0),
      (660, 0.0),
      (750, 1.0),
      (810, 0.0),
      (900, 1.0),
      (980, 0.4),
      (1100, 0.0),
    ],
    sharpness: [(0, 0.5), (600, 0.75), (1100, 0.85)],
  ),
  'trumpet': HapticPattern(
    // Trumpet
    taps: [
      HapticPulse(intensity: 0.3, sharpness: 0.5),
      HapticPulse(
        intensity: 0.4,
        sharpness: 0.55,
        delay: Duration(milliseconds: 80),
      ),
      HapticPulse(
        intensity: 0.5,
        sharpness: 0.6,
        delay: Duration(milliseconds: 70),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.65,
        delay: Duration(milliseconds: 60),
      ),
      HapticPulse(
        intensity: 0.7,
        sharpness: 0.7,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.85,
        delay: Duration(milliseconds: 50),
      ),
    ],
    intensity: [
      (0, 0.0),
      (10, 0.3),
      (40, 0.0),
      (80, 0.4),
      (110, 0.0),
      (150, 0.5),
      (175, 0.0),
      (210, 0.6),
      (232, 0.0),
      (260, 0.7),
      (278, 0.0),
      (310, 1.0),
      (380, 0.6),
      (460, 0.0),
    ],
    sharpness: [(0, 0.4), (310, 0.7), (460, 0.9)],
  ),
  'typewriter': HapticPattern(
    // Typewriter
    taps: [
      HapticPulse(intensity: 0.88, sharpness: 0.42),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.38,
        delay: Duration(milliseconds: 55),
      ),
      HapticPulse(
        intensity: 0.12,
        sharpness: 0.35,
        delay: Duration(milliseconds: 55),
      ),
    ],
    intensity: [
      (0, 0.0),
      (6, 0.85),
      (40, 0.3),
      (55, 0.38),
      (90, 0.12),
      (110, 0.15),
      (160, 0.04),
      (200, 0.0),
    ],
    sharpness: [(0, 0.42), (55, 0.38), (200, 0.34)],
  ),
  'unfurl': HapticPattern(
    // Unfurl
    taps: [
      HapticPulse(intensity: 0.5, sharpness: 0.28),
      HapticPulse(
        intensity: 0.62,
        sharpness: 0.4,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.74,
        sharpness: 0.49,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 0.86,
        sharpness: 0.62,
        delay: Duration(milliseconds: 90),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.7,
        delay: Duration(milliseconds: 90),
      ),
    ],
    intensity: [
      (0, 0.0),
      (5, 0.5),
      (68, 0.0),
      (93, 0.62),
      (158, 0.0),
      (183, 0.74),
      (248, 0.0),
      (273, 0.86),
      (338, 0.0),
      (363, 1.0),
      (850, 0.6),
      (1050, 0.2),
      (1180, 0.0),
    ],
    sharpness: [
      (0, 0.28),
      (90, 0.4),
      (180, 0.49),
      (270, 0.62),
      (360, 0.7),
      (1180, 0.7),
    ],
  ),
  'vortex': HapticPattern(
    // Vortex
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.8,
        delay: Duration(milliseconds: 1200),
      ),
    ],
    intensity: [
      (0, 0.05),
      (200, 0.08),
      (400, 0.13),
      (600, 0.22),
      (800, 0.35),
      (950, 0.52),
      (1050, 0.72),
      (1150, 0.9),
      (1195, 0.0),
      (1200, 1.0),
      (1250, 0.3),
      (1400, 0.0),
    ],
    sharpness: [
      (0, 0.25),
      (600, 0.4),
      (1000, 0.62),
      (1150, 0.82),
      (1200, 0.9),
      (1400, 0.5),
    ],
  ),
  'wane': HapticPattern(
    // Wane
    intensity: [(0, 0.0), (20, 0.42), (180, 0.22), (450, 0.0)],
    sharpness: [(0, 0.5), (180, 0.4), (450, 0.35)],
  ),
  'war_drum': HapticPattern(
    // WarDrum
    taps: [
      HapticPulse(
        intensity: 1,
        sharpness: 0.106,
        delay: Duration(milliseconds: 10),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.109,
        delay: Duration(milliseconds: 191),
      ),
      HapticPulse(
        intensity: 0.997,
        sharpness: 0.103,
        delay: Duration(milliseconds: 197),
      ),
    ],
  ),
  'waterfall': HapticPattern(
    // Waterfall
    taps: [
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.994,
        delay: Duration(milliseconds: 1),
      ),
      HapticPulse(
        intensity: 0.994,
        sharpness: 0.806,
        delay: Duration(milliseconds: 50),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.597,
        delay: Duration(milliseconds: 49),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.394,
        delay: Duration(milliseconds: 56),
      ),
      HapticPulse(
        intensity: 0.991,
        sharpness: 0.203,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.094,
        delay: Duration(milliseconds: 52),
      ),
      HapticPulse(
        intensity: 1,
        sharpness: 0.072,
        delay: Duration(milliseconds: 49),
      ),
    ],
  ),
  'wave': HapticPattern(
    // Wave
    intensity: [
      (0, 0.0),
      (400, 0.38),
      (800, 0.05),
      (1200, 0.4),
      (1600, 0.05),
      (2000, 0.38),
      (2400, 0.05),
      (2800, 0.0),
    ],
    sharpness: [(0, 0.35), (2800, 0.35)],
  ),
  'wisp': HapticPattern(
    // Wisp
    taps: [HapticPulse(intensity: 0.25, sharpness: 0.48)],
    intensity: [(0, 0.0), (8, 0.22), (60, 0.0)],
    sharpness: [(0, 0.48), (60, 0.48)],
  ),
  'wobble': HapticPattern(
    // Wobble
    intensity: [(0, 0.0), (5, 0.65), (80, 0.5), (180, 0.0)],
    sharpness: [(0, 0.82), (180, 0.75)],
  ),
  'woodpecker': HapticPattern(
    // Woodpecker
    taps: [
      HapticPulse(intensity: 0.75, sharpness: 0.82),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
      HapticPulse(
        intensity: 0.75,
        sharpness: 0.82,
        delay: Duration(milliseconds: 45),
      ),
    ],
    intensity: [(0, 0.0), (5, 0.65), (430, 0.65), (460, 0.0)],
    sharpness: [(0, 0.82), (460, 0.82)],
  ),
  'zipper': HapticPattern(
    // Zipper
    taps: [
      HapticPulse(intensity: 0.35, sharpness: 0.8),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.35,
        sharpness: 0.8,
        delay: Duration(milliseconds: 40),
      ),
      HapticPulse(
        intensity: 0.6,
        sharpness: 0.75,
        delay: Duration(milliseconds: 30),
      ),
    ],
    intensity: [(0, 0.0), (6, 0.234), (432, 0.231), (460, 0.0)],
    sharpness: [(0, 0.616), (358, 0.594), (460, 0.35)],
  ),
};
