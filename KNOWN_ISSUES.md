# Known issues

Last verified: 2026-08-18

## Validation limits

- **No physical Android runtime test yet.** The APK was built, signed, aligned, inspected, and archive-tested, but this workspace had no connected Android device or emulator available for install/run validation.
- **ADB cannot initialize in this sandbox.** The available ADB process attempts to create `/root/.android`, which is read-only here. This does not invalidate static APK checks, but it prevents one-click deployment from this environment.
- **No mobile GPU measurement exists.** Headless tests validate scene/script/physics behavior, not Vulkan rendering correctness, thermals, battery use, memory pressure, touch feel, or frame pacing.
- **Gradle/AAB path is not verified.** The Gradle wrapper itself ran, but Java could not resolve the Android Gradle Plugin through the sandbox network. Milestone 0 therefore uses Godot's official prebuilt debug APK template. Play submission requires a separately validated Gradle AAB build.

## APK limitations

- Debug signing only. The included APK is not suitable for a store release.
- The APK is arm64-only, so 32-bit-only devices are unsupported by this milestone.
- `aapt2` reports a missing optional themed-icon XML reference in the official template. The standard and adaptive launcher icons are present; Android 13 monochrome themed-icon behavior needs device inspection.
- Godot selects Build Tools 35.0.1 while targeting API 36. The result builds and verifies, but the selection warning remains in the export log.

## Gameplay and presentation limits

- Movement, jump, air control, and burst are engineering probes, not final traversal tuning.
- Tether/swing, wall run, climbing, parkour, dive, tricks, melee, aerial combat, missions, progression, customization, AI, crowds, traffic, audio, weather, interiors, and streaming are not implemented.
- The city and avatar are procedural/primitives-only blockouts. They do not represent the production visual target.
- Touch control sizing, palm rejection, gesture conflicts, safe areas, accessibility, haptics, and latency need real-device tests.
- The camera has only basic orbit/follow behavior; obstruction handling and high-speed cinematic behavior are future systems.

## Required next action

Before Milestone 1, run the M0 APK on at least two physical Android tiers, record install/launch/resume/orientation/touch results, capture sustained CPU/GPU/frame-time/thermal data, and update `PERFORMANCE.md` and this file.
