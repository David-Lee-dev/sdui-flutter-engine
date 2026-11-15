# model_3d bench

Device measurement and manual showcase app for the `model_3d` widget on the
Filament renderer. It runs against this checkout's engine and renderer
(`dependency_overrides` in `pubspec.yaml`).

## Sample models

`Planet.glb`, `Hat.glb` and `HatRobot.glb` are simple generated test shapes and
are committed. The other samples are third-party and must be fetched once:

```sh
cd assets
curl -fsSLO https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/Fox/glTF-Binary/Fox.glb
curl -fsSLO https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/AnimatedMorphCube/glTF-Binary/AnimatedMorphCube.glb
curl -fsSLO https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/models/gltf/RobotExpressive/RobotExpressive.glb
curl -fsSLO https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/models/gltf/Xbot.glb
```

## Run

- Showcase (manual check of every feature):
  `fvm flutter run --profile -d <device>`
- Automatic measurement, one suite at a time (`base`, `probe`, `look`, `scene`,
  `outfit`, `motion`, `vis`), logging `[bench]` lines every 5 seconds:
  `fvm flutter run --profile -d <device> --dart-define=BENCH_AUTO=true --dart-define=BENCH_SUITE=look`

Android needs `compileSdk = 36` for `thermion_flutter` 0.6.1; see
`android/build.gradle.kts`.
