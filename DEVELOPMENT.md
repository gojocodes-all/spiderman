# Development

## Pinned foundation

| Component | Version used for Milestone 0 |
|---|---|
| Engine | Godot `4.6.3.stable.official.7d41c59c4` |
| Scripting | GDScript |
| Renderer | Godot Mobile renderer |
| Java | OpenJDK 17 |
| Android platform | API 36 |
| Android Build Tools | 35.0.1 |
| Android Platform Tools | 37.0.1 |
| APK ABI | `arm64-v8a` |
| Orientation | Landscape |

The engine selection is explained in [docs/TECHNICAL_DECISION.md](docs/TECHNICAL_DECISION.md). Do not silently upgrade the engine or Android toolchain. Open a dedicated upgrade change, rebuild the APK, and repeat every acceptance check.

## Local setup

1. Install the official Godot 4.6.3 standard editor and matching export templates.
2. Install OpenJDK 17.
3. Install Android SDK Platform 36, Build Tools 35.0.1, and current Platform Tools.
4. In Godot Editor Settings, set the Java SDK and Android SDK paths.
5. Open `project.godot` and let the first import finish.

The current debug APK uses Godot's official prebuilt Android template. A Play Store AAB requires the Gradle build path and a private release keystore; neither is part of Milestone 0.

## Run the scene

```bash
godot --path .
```

Select a quality tier for local testing with `AV_QUALITY=low`, `medium`, `high`, or `ultra`.

## Automated gameplay smoke test

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/verify_project.sh
```

The test creates the main scene, waits for physics initialization, verifies the procedural city and quality manager, then probes locomotion, jump velocity, and burst speed. A valid run ends with `[SMOKE] PASS`.

## Build the debug APK

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/build_android_debug.sh
```

Godot's Android editor settings must already point to a valid SDK and JDK. Signing credentials are not stored in this repository. Godot may create or use a local debug keystore.

## Verify an APK

```bash
ANDROID_SDK_ROOT=/absolute/path/to/android-sdk \
  ./scripts/verify_apk.sh build/android/aerial-vanguard-m0-debug.apk
```

The verifier checks archive integrity, APK v2/v3 signatures, 16 KB zip alignment, package ID, API 36 target, and arm64 native code.

## Module ownership

| Area | Current location | Responsibility |
|---|---|---|
| Input | `game/scripts/input/` | Converts device input into gameplay intent |
| Movement | `game/scripts/movement/` | Pure locomotion simulation on a supplied body |
| Camera | `game/scripts/camera/` | Orbit/follow camera behavior |
| Player | `game/scripts/player/` | Composes player modules; does not own every system |
| Graphics quality | `game/scripts/core/` | Tier selection and viewport settings |
| World | `game/scripts/world/` | Procedural test environment |
| UI | `game/scripts/ui/` | Touch input surface and debug HUD |
| Tests | `game/scripts/tests/` | Runtime acceptance probes |

Future traversal, swing, parkour, animation, combat, ability, customization, AI, mission, audio, save, streaming, and graphics-config systems receive separate modules and tests before integration. The dependency rules live in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Definition of done for a major system

1. A written behavior contract and measurable acceptance criteria exist.
2. The system is isolated behind a small interface.
3. Automated deterministic tests cover the core state changes.
4. The feature is profiled on representative Android hardware before downstream systems rely on it.
5. Low/Medium/High/Ultra behavior is recorded.
6. New assets and licences are added to `ASSETS.md` before merge.
7. Limitations are added to `KNOWN_ISSUES.md` rather than hidden.

## Original-IP rule

Reference games may be studied only for high-level design principles. Never import ripped content or reproduce protected characters, names, suit designs, iconography, maps, stories, dialogue, animation data, code, or logos. The repository name is not permission to use the Spider-Man property.
