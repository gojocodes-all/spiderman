# Development

## Pinned foundation

| Component | Version used for Milestones 0–2 |
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

## User-reported physical-device validation — Milestone 1

On 2026-08-18, the user reported manually testing Milestone 1 on a physical Android device. The user stated that the game loaded and that the implemented Milestone 1 work was visibly present, then accepted Milestone 1 as passed.

**This is limited USER-REPORTED PHYSICAL-DEVICE VALIDATION. It is not an automated test, emulator result, workspace-connected-device test, detailed movement checklist, or performance profile.**

The report validates application loading and the user's visual confirmation/acceptance of the Milestone 1 implementation. It does not establish results for every movement edge case, sustained frame rate, touch latency, device thermals, memory, phone model, Android version, safe areas, or long-session stability. Those details remain unreported rather than inferred.

## Local setup

1. Install the official Godot 4.6.3 standard editor and matching export templates.
2. Install OpenJDK 17.
3. Install Android SDK Platform 36, Build Tools 35.0.1, and current Platform Tools.
4. In Godot Editor Settings, set the Java SDK and Android SDK paths.
5. Open `project.godot` and let the first import finish.

The current debug APK uses Godot's official prebuilt Android template. A Play Store AAB requires the Gradle build path and a private release keystore; neither is part of Milestones 0–2.

## Run the scene

```bash
godot --path .
```

Select a quality tier for local testing with `AV_QUALITY=low`, `medium`, `high`, or `ultra`.

## Automated gameplay and movement test

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/verify_project.sh
```

The verifier runs the preserved Milestone 1 suite first, followed by the Milestone 2 suite in a fresh process. M1 covers reusable input, movement bands, 30/60 Hz consistency, jumps, landings, slopes/stairs/steps, camera collision, aspect layouts, simultaneous touch, and the M0 movement/JUMP/BURST regression. M2 covers traversal architecture, valid/invalid surface detection, blocked destinations, horizontal and vertical wall traversal, wall jump, limits and recovery, vault, mantle, ledge grab/climb/drop/jump-away, momentum, camera readability, debug visualization, and multitouch. A valid run ends with both milestone smoke markers.

## Build the debug APK

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/build_android_debug.sh
```

Godot's Android editor settings must already point to a valid SDK and JDK. Signing credentials are not stored in this repository. Godot may create or use a local debug keystore.

## Verify an APK

```bash
ANDROID_SDK_ROOT=/absolute/path/to/android-sdk \
  ./scripts/verify_apk.sh releases/milestone-2/aerial-vanguard-relay-m2-debug.apk
```

The verifier checks archive integrity, APK v2/v3 signatures, 16 KB zip alignment, package ID, API 36 target, and arm64 native code.

## Module ownership

| Area | Current location | Responsibility |
|---|---|---|
| Input | `game/scripts/input/` | Converts device input into gameplay intent |
| Movement data | `game/data/movement/` | Central movement and camera tuning resources |
| Movement | `game/scripts/movement/` | Ground/air simulation, semantic states, and bounded step solving |
| Traversal data | `game/data/traversal/` | Central wall-run, vertical, wall-jump, vault, mantle, ledge, recovery, and pose tuning |
| Traversal | `game/scripts/traversal/` | Explicit traversal state, tagged-surface detection, contextual action motion, and opt-in debug visualization |
| Camera | `game/scripts/camera/` | Smoothed orbit/follow, recenter, speed response, and obstruction handling |
| Player | `game/scripts/player/` | Composes player modules; does not own every system |
| Graphics quality | `game/scripts/core/` | Tier selection and viewport settings |
| World | `game/scripts/world/` | Procedural package scene and deliberate movement laboratory |
| UI | `game/scripts/ui/` | Touch input surface and debug HUD |
| Tests | `game/scripts/tests/` | Separate runtime M1 regression and M2 traversal acceptance processes, including the M0 functional probes |
| Parkour lab | `game/scripts/world/movement_traversal_lab.gd` | M1 movement zones plus deliberate M2 routes, valid/invalid surfaces, and edge-case markers |

## Preserved movement controls

| Action | Touch | Desktop | Controller |
|---|---|---|---|
| Move | Left virtual stick | WASD / arrows | Left stick |
| Look | Right-side drag | Hold right mouse and drag | Right stick |
| Walk | Analog stick range | Ctrl | Left shoulder |
| Sprint | SPRINT hold button | Shift | Left-stick click |
| Jump | JUMP button | Space | South/A button |
| Camera recenter | Automatic while travelling | C | Right-stick click |
| Temporary BURST probe | BURST button | E | Right shoulder |

## Preserved Milestone 1 movement tuning

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

## Milestone 2 contextual controls

Milestone 2 adds no touch buttons. Existing input is interpreted contextually:

| Intent | Result when context is valid |
|---|---|
| Sprint/jump toward a wall at an angle | Horizontal wall run |
| Move/jump directly toward a wall while airborne | Finite vertical wall run/climb |
| JUMP during a wall run/climb | Wall jump |
| Run toward a low clear obstacle | Automatic vault |
| Jump toward a reachable clear top | Mantle |
| Fall toward a reachable clear ledge while holding toward it | Ledge grab |
| JUMP while hanging | Ledge climb |
| Hold away from a ledge | Drop |
| Hold away and press JUMP while hanging | Jump away |
| F8 in a debug build | Toggle traversal rays, normals, targets, state, velocity, and surface HUD |

Traversal values are centralized in [`default_traversal_tuning.tres`](game/data/traversal/default_traversal_tuning.tres), backed by [`traversal_tuning.gd`](game/scripts/traversal/traversal_tuning.gd). The traversal state machine is mutually exclusive; when it owns scripted/wall motion, normal ground/air integration pauses for that tick and resumes through explicit recovery.

| Traversal group | Shipped M2 values |
|---|---|
| Horizontal wall run | 5.4 m/s minimum entry; 16.0 m/s cap; 1.45 s maximum; 0.22× gravity; 16 m/s² adhesion; 1.25 m/s² loss |
| Vertical run/climb | 4.2 m/s minimum entry; 8.8 m/s initial rise; 0.88 s and 4.25 m limits; 11 m/s² gravity |
| Wall jump | 8.4 m/s outward; 8.9 m/s upward; 0.76× tangent; 0.26 s reattach cooldown; chain budget 3 |
| Vault | 0.42–1.05 m height; 4.0 m/s minimum; 0.36 s; 0.94× momentum |
| Mantle | 0.78–2.35 m height; 1.35 m range; 0.52 s; 0.78× momentum |
| Ledge | 1.30 m range; 0.90 m vertical tolerance; 0.22 s drop hold; 0.32 s regrab cooldown |
| Detector/recovery | 1.85 m forward probe; maximum 8 ray queries per probe; 0.16 s recovery |

Future swing, animation, combat, ability, customization, AI, mission, audio, save, streaming, and graphics-config systems receive separate modules and tests before integration. Swinging remains absent. The dependency rules live in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

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
