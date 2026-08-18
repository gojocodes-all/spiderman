# Known issues

Last verified: 2026-08-18

## Validation limits

- **Milestone 0 has limited user-reported physical validation.** The user manually confirmed M0 install, launch, landscape rendering, movement, right-side camera drag, JUMP, BURST, and no immediate crash on a real phone. This is not a workspace-device or automated result, and the phone model/OS/performance data were not reported.
- **Milestone 1 has not been run on a physical device.** Its APK was built and statically verified, and its controller was exercised headlessly, but touch feel, graphics, and runtime stability still require the user's real-phone test.
- **ADB cannot initialize in this sandbox.** The available ADB process attempts to create `/root/.android`, which is read-only here. This does not invalidate static APK checks, but it prevents one-click deployment from this environment.
- **No mobile GPU measurement exists.** Headless tests validate scene/script/physics behavior, not Vulkan rendering correctness, thermals, battery use, memory pressure, touch feel, or frame pacing.
- **Gradle/AAB path is not verified.** The Gradle wrapper itself ran, but Java could not resolve the Android Gradle Plugin through the sandbox network. Milestones 0 and 1 therefore use Godot's official prebuilt debug APK template. Play submission requires a separately validated Gradle AAB build.

## APK limitations

- Debug signing only. The included APK is not suitable for a store release.
- The APK is arm64-only, so 32-bit-only devices are unsupported by this milestone.
- `aapt2` reports a missing optional themed-icon XML reference in the official template. The standard and adaptive launcher icons are present; Android 13 monochrome themed-icon behavior needs device inspection.
- Godot selects Build Tools 35.0.1 while targeting API 36. The result builds and verifies, but the selection warning remains in the export log.

## Gameplay and presentation limits

- Milestone 1 movement values are a tested first tuning pass, not final game feel. Physical-device latency and thumb ergonomics may require controlled data-only retuning.
- The semantic landing states currently affect control/recovery but have no authored landing animations, effects, audio, or haptics because the hero remains a primitive blockout.
- The automatic step solver is intentionally limited to 0.38 m and uses a conditional surface ray only after wall contact. Thin, moving, curved, or irregular obstacles need physical-device/editor playtesting beyond the deterministic box/stair cases.
- The temporary BURST control remains for Milestone 0 regression testing; it is not the planned swinging system.
- Tether/swing, wall run, climbing, parkour, dive, tricks, melee, aerial combat, missions, progression, customization, AI, crowds, traffic, audio, weather, interiors, and streaming are not implemented.
- The movement laboratory and avatar are procedural/primitives-only blockouts. They do not represent the production visual target.
- Touch control sizing, palm rejection, gesture conflicts, safe areas, accessibility, haptics, and latency need real-device tests.
- Camera collision passed deterministic solid-wall tests, but thin geometry, very low ceilings, rapidly alternating obstructions, and device-specific aspect/safe-area behavior still need hands-on review.

## Required next action

Install the Milestone 1 APK on the same Android phone used for M0 and test the specific checklist in [docs/M1_ACCEPTANCE.md](docs/M1_ACCEPTANCE.md). Report feel/collision/camera defects and, if available, phone model, Android version, quality tier, approximate fps stability, and heat after a sustained run. Do not begin swinging until that feedback is reviewed.
