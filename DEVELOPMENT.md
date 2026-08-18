# Development

## Pinned foundation

| Component | Version used for Milestones 0–1 |
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

## User-reported physical-device validation — Milestone 0

On 2026-08-18, the user reported manually downloading the published Milestone 0 APK from `gojocodes-all/spiderman`, installing it, and running it on a real Android phone.

**This is USER-REPORTED PHYSICAL-DEVICE VALIDATION. It is not an automated test, emulator result, or workspace-connected-device test.**

The user specifically confirmed:

- APK installation;
- application launch;
- landscape rendering;
- virtual movement controls;
- player movement;
- right-side touch camera control;
- the JUMP button;
- the BURST button;
- no immediate crash during the initial test.

Milestone 0 is physically validated for those behaviors only. The report did not include the phone model, SoC/GPU, Android version, frame pacing, sustained 30/60 fps, thermals, memory, suspend/resume, safe areas, or complex simultaneous-touch combinations. Those unreported items remain unverified rather than inferred.

## Local setup

1. Install the official Godot 4.6.3 standard editor and matching export templates.
2. Install OpenJDK 17.
3. Install Android SDK Platform 36, Build Tools 35.0.1, and current Platform Tools.
4. In Godot Editor Settings, set the Java SDK and Android SDK paths.
5. Open `project.godot` and let the first import finish.

The current debug APK uses Godot's official prebuilt Android template. A Play Store AAB requires the Gradle build path and a private release keystore; neither is part of Milestones 0–1.

## Run the scene

```bash
godot --path .
```

Select a quality tier for local testing with `AV_QUALITY=low`, `medium`, `high`, or `ultra`.

## Automated gameplay and movement test

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/verify_project.sh
```

The Milestone 1 suite creates the movement laboratory and verifies architecture, reusable input snapshots, walk/jog/sprint bands, acceleration/deceleration, camera-relative movement, 30/60 Hz consistency, rapid reversals, sprint jumping, air steering, jump spam, falling, soft/hard landings, roof run-off, step limits, stairs, walkable/rejected ramps, walls, narrow platforms, camera collision, five aspect-ratio layouts, simultaneous move/look/jump touch intent, camera pitch/recentering, and the Milestone 0 movement/jump/BURST regression. A valid run ends with `[M1 TEST] PASS` and `[SMOKE] PASS`.

## Build the debug APK

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/build_android_debug.sh
```

Godot's Android editor settings must already point to a valid SDK and JDK. Signing credentials are not stored in this repository. Godot may create or use a local debug keystore.

## Verify an APK

```bash
ANDROID_SDK_ROOT=/absolute/path/to/android-sdk \
  ./scripts/verify_apk.sh build/android/aerial-vanguard-m1-debug.apk
```

The verifier checks archive integrity, APK v2/v3 signatures, 16 KB zip alignment, package ID, API 36 target, and arm64 native code.

## Module ownership

| Area | Current location | Responsibility |
|---|---|---|
| Input | `game/scripts/input/` | Converts device input into gameplay intent |
| Movement data | `game/data/movement/` | Central movement and camera tuning resources |
| Movement | `game/scripts/movement/` | Ground/air simulation, semantic states, and bounded step solving |
| Camera | `game/scripts/camera/` | Smoothed orbit/follow, recenter, speed response, and obstruction handling |
| Player | `game/scripts/player/` | Composes player modules; does not own every system |
| Graphics quality | `game/scripts/core/` | Tier selection and viewport settings |
| World | `game/scripts/world/` | Procedural package scene and deliberate movement laboratory |
| UI | `game/scripts/ui/` | Touch input surface and debug HUD |
| Tests | `game/scripts/tests/` | Runtime Milestone 0 regression and Milestone 1 acceptance probes |

## Milestone 1 controls

| Action | Touch | Desktop | Controller |
|---|---|---|---|
| Move | Left virtual stick | WASD / arrows | Left stick |
| Look | Right-side drag | Hold right mouse and drag | Right stick |
| Walk | Analog stick range | Ctrl | Left shoulder |
| Sprint | SPRINT hold button | Shift | Left-stick click |
| Jump | JUMP button | Space | South/A button |
| Camera recenter | Automatic while travelling | C | Right-stick click |
| Temporary BURST probe | BURST button | E | Right shoulder |

## Milestone 1 movement tuning

The authoritative values are in [`default_movement_tuning.tres`](game/data/movement/default_movement_tuning.tres), backed by [`movement_tuning.gd`](game/scripts/movement/movement_tuning.gd). Key values in the shipped M1 build are:

| Parameter | Value |
|---|---:|
| Walk / jog / sprint speed | 3.4 / 7.2 / 11.8 m/s |
| Ground acceleration / deceleration | 38 / 48 m/s² |
| Direction-change acceleration | 68 m/s² |
| Jump velocity | 10.8 m/s |
| Gravity | 26 m/s² |
| Falling gravity multiplier | 1.35× |
| Air acceleration / control | 12 m/s² / 0.72 |
| Coyote time / jump buffer | 0.11 / 0.12 s |
| Grounded / air turn speed | 720 / 540 degrees/s |
| Maximum walkable slope | 48 degrees |
| Floor snap | 0.48 m |
| Maximum automatic step | 0.38 m |
| Soft / hard landing impact | 6.5 / 14.0 m/s |
| Soft / hard recovery | 0.12 / 0.36 s |

Camera tuning is separately centralized in [`default_camera_tuning.tres`](game/data/movement/default_camera_tuning.tres); it is not embedded in the player controller.

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
