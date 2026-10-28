// The tap-only (discrete-only) presets of Software Mansion's Pulsar
// (https://github.com/software-mansion/pulsar, commit
// abdee706282598ab0194ba739dce835dc828f164). Names are converted to
// snake_case and absolute event times to per-pulse delays.
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

/// Named tap patterns a `sys_haptic` `variant` can play on a tap-capable device.
const Map<String, List<HapticPulse>> hapticPresets = {
  'afterglow': [
    // Afterglow
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
  'aftershock': [
    // Aftershock
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
  'barrage': [
    // Barrage
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
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 56)),
    HapticPulse(
      intensity: 0.991,
      sharpness: 0.991,
      delay: Duration(milliseconds: 52),
    ),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 52)),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 49)),
  ],
  'bass_drop': [
    // BassDrop
    HapticPulse(intensity: 1, sharpness: 0.509),
    HapticPulse(
      intensity: 1,
      sharpness: 0.069,
      delay: Duration(milliseconds: 71),
    ),
  ],
  'bell_toll': [
    // BellToll
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
  'bongo': [
    // Bongo
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
  'boulder': [
    // Boulder
    HapticPulse(intensity: 1, sharpness: 0.2),
  ],
  'breaking_wave': [
    // BreakingWave
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
  'buildup': [
    // Buildup
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
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 49)),
  ],
  'cadence': [
    // Cadence
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
  'canter': [
    // Canter
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
  'cascade': [
    // Cascade
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
  'castanets': [
    // Castanets
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
  'cat_paw': [
    // CatPaw
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
  'chip': [
    // Chip
    HapticPulse(intensity: 0.75, sharpness: 1),
  ],
  'crescendo': [
    // Crescendo
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
  'fade_out': [
    // FadeOut
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
  'finger_drum': [
    // FingerDrum
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
  'firecracker': [
    // Firecracker
    HapticPulse(intensity: 1, sharpness: 1),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 75)),
  ],
  'gallop': [
    // Gallop
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
  'gavel': [
    // Gavel
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
  'herald': [
    // Herald
    HapticPulse(intensity: 0.497, sharpness: 0.497),
    HapticPulse(
      intensity: 0.497,
      sharpness: 0.497,
      delay: Duration(milliseconds: 89),
    ),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 119)),
  ],
  'hoof_beat': [
    // HoofBeat
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
  'ignition': [
    // Ignition
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
  'jolt': [
    // Jolt
    HapticPulse(intensity: 1, sharpness: 1),
  ],
  'murmur': [
    // Murmur
    HapticPulse(intensity: 0.6, sharpness: 0.303),
    HapticPulse(
      intensity: 0.6,
      sharpness: 0.3,
      delay: Duration(milliseconds: 80),
    ),
  ],
  'patter': [
    // Patter
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
  'piston': [
    // Piston
    HapticPulse(intensity: 1, sharpness: 0.397),
    HapticPulse(
      intensity: 1,
      sharpness: 0.397,
      delay: Duration(milliseconds: 73),
    ),
  ],
  'plunk': [
    // Plunk
    HapticPulse(intensity: 0.5, sharpness: 0.2),
  ],
  'rap': [
    // Rap
    HapticPulse(intensity: 0.6, sharpness: 0.5),
    HapticPulse(
      intensity: 0.4,
      sharpness: 0.5,
      delay: Duration(milliseconds: 120),
    ),
  ],
  'ratchet': [
    // Ratchet
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
  'rebound': [
    // Rebound
    HapticPulse(intensity: 1, sharpness: 1),
    HapticPulse(
      intensity: 1,
      sharpness: 0.3,
      delay: Duration(milliseconds: 80),
    ),
  ],
  'rivet': [
    // Rivet
    HapticPulse(intensity: 1, sharpness: 1),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 75)),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 75)),
  ],
  'stampede': [
    // Stampede
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
  'stomp': [
    // Stomp
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
  'stone_skip': [
    // StoneSkip
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
  'syncopate': [
    // Syncopate
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
  'thump': [
    // Thump
    HapticPulse(intensity: 1, sharpness: 0.45),
  ],
  'thunder_roll': [
    // ThunderRoll
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
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 49)),
    HapticPulse(intensity: 1, sharpness: 1, delay: Duration(milliseconds: 59)),
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
  'tick_tock': [
    // TickTock
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
  'tidal_surge': [
    // TidalSurge
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
  'tide_swell': [
    // TideSwell
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
  'tremor': [
    // Tremor
    HapticPulse(intensity: 1, sharpness: 0),
  ],
  'war_drum': [
    // WarDrum
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
  'waterfall': [
    // Waterfall
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
};
