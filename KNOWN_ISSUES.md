# Known issues

## Distribution

- M1/M2 source, documentation, checksums, tags, and GitHub release pages are published. The connected repository API cannot ingest APKs from the managed workspace file path without a separately staged binary reference, while Base64 transfer is intentionally prohibited. The two verified local APKs still need normal attachment to their matching GitHub release pages.

Last verified: 2026-08-18

## Validation limits

- **Milestone 0 has limited user-reported physical validation.** The user manually confirmed M0 install, launch, landscape rendering, movement, right-side camera drag, JUMP, BURST, and no immediate crash on a real phone. This is not a workspace-device or automated result, and the phone model/OS/performance data were not reported.
- **Milestone 1 has limited user-reported physical validation.** The user reported that M1 loaded on a physical Android device, visibly contained the implemented work, and was accepted as passed. No phone/OS details, per-action checklist, sustained performance, or defect observations were supplied.
- **Milestone 2 has limited user-reported physical validation.** The user reported that the M2 build works fine on their physical Android phone and accepted the milestone. No phone/OS details, per-action checklist, sustained performance, or defect observations were supplied.
- **ADB cannot initialize in this sandbox.** The available ADB process attempts to create `/root/.android`, which is read-only here. This does not invalidate static APK checks, but it prevents one-click deployment from this environment.
- **No mobile GPU measurement exists.** Headless tests validate scene/script/physics behavior, not Vulkan rendering correctness, thermals, battery use, memory pressure, touch feel, or frame pacing.
- **Gradle/AAB path is not verified.** The Gradle wrapper itself ran, but Java could not resolve the Android Gradle Plugin through the sandbox network. Milestones 0–2 therefore use Godot's official prebuilt debug APK template. Play submission requires a separately validated Gradle AAB build.

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
- Tether/swing, dive, aerial tricks, melee, aerial combat, enemies, missions, progression, customization, AI, crowds, traffic, audio, weather, interiors, and streaming are not implemented. Milestone 2 wall running, finite climbing, wall jumping, vaulting, mantling, and ledge traversal are implemented as graybox systems.
- The movement laboratory and avatar are procedural/primitives-only blockouts. They do not represent the production visual target.
- Touch control sizing, palm rejection, gesture conflicts, safe areas, accessibility, haptics, and latency need real-device tests.
- Camera collision passed deterministic solid-wall tests, but thin geometry, very low ceilings, rapidly alternating obstructions, and device-specific aspect/safe-area behavior still need hands-on review.
- Milestone 2 uses authored traversal tags and currently accepts stable `StaticBody3D` geometry only. Untagged city geometry, moving platforms, dynamic bodies, separate facade/roof colliders, deeply concave tops, and production curved architecture need an explicit authoring contract before use.
- Wall and ledge transitions use original procedural pose lean and collision-safe motion paths, not production skeletal animations, IK, hand placement, root motion, effects, audio, or haptics. Visual contact will look approximate on the primitive avatar.
- Vaults are tuned for roughly 0.42–1.05 m obstacles and mantles for roughly 0.78–2.35 m tops. Very thin, moving, deforming, or irregular obstacles remain outside M2 acceptance.
- Ledge shimmy is intentionally minimal. It collision-checks lateral motion but does not yet turn exterior corners, transfer around concave corners, or support authored ledge networks.
- The detector caps ray work per probe and rejects blocked/foreign top surfaces. A wall and its traversable top currently need to be the same collider; production modular buildings will need explicit linked-surface metadata.
- The three-wall-jump chain budget prevents indefinite close-wall height gain. Progression-based chain extensions, if ever added, require new exploit tests.
- Traversal debug drawing and HUD are disabled by default and available only in debug builds through F8; there is no on-screen debug button.

## Next action

Milestone 2 is accepted on the basis of the user's limited phone report. Detailed hardware/performance testing remains intentionally deferred. Do not begin swinging until the user explicitly starts the next milestone.
