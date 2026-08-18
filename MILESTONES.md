# Milestones

## Artifact rule

Every accepted milestone must include:

- a versioned, debug- or release-qualified APK under `releases/milestone-N/`;
- a SHA-256 checksum file;
- package, SDK, ABI, signing, alignment, and archive verification;
- automated test results;
- an honest device-test status;
- updated `ASSETS.md`, `KNOWN_ISSUES.md`, and `PERFORMANCE.md`.

Never overwrite an accepted milestone APK. Increase `versionCode`, create a new milestone directory, and preserve the prior artifact.

## M0 — Foundation and Android package smoke test

Status: **accepted; limited user-reported physical-device validation recorded**

Delivered:

- original project/universe boundary;
- modular Godot project;
- procedural package-smoke scene;
- touch and desktop development input;
- basic movement/jump/burst probes;
- four quality-tier hooks;
- signed API 36 arm64 debug APK;
- deterministic headless test and static APK verification.

User-reported physical-device validation on 2026-08-18 confirmed install, launch, landscape rendering, virtual movement, player movement, right-side camera drag, JUMP, BURST, and no immediate crash on a real Android phone. This was a manual user report, not an automated/workspace-device test, and it contains no hardware or performance data. See [docs/M0_ACCEPTANCE.md](docs/M0_ACCEPTANCE.md).

Not delivered: production visuals, sustained device performance results, or any major gameplay system beyond the original locomotion probe.

## M1 — Core third-person movement

Status: **accepted; implementation/package complete and limited user-reported physical-device validation recorded**

Delivered:

- data-driven walk, jog, sprint, acceleration, deceleration, direction changes, jump, gravity, air steering, slopes, stairs, bounded step traversal, and landing recovery;
- semantic idle/walking/jogging/sprinting/jumping/rising/falling/soft-landing/hard-landing state machine;
- camera-relative movement and data-driven 720/540-degree-per-second grounded/air facing;
- smooth orbit/follow camera with touch, mouse, controller, pitch limits, speed-sensitive arm/FOV, recentering, sphere-cast collision, and player exclusion;
- independent touch IDs for movement and camera plus JUMP, SPRINT, and temporary BURST controls;
- 59-feature, 17-marker movement laboratory covering flat lanes, alleys, ramps, stairs, rooftops, walls, gaps, elevations, narrow platforms, pipes, step limits, collision corners, and camera obstruction;
- deterministic 30/60 Hz and scene-integration acceptance suite;
- version-code 2, API 36, arm64 debug APK with signature/alignment/archive verification.

- Artifact: `releases/milestone-1/aerial-vanguard-relay-m1-debug.apk`
- Size: 27,808,805 bytes
- SHA-256: `73653e3e92ac759c019b2d8ab34643827e6881044b28a220af3d6a529bc1f58b`

On 2026-08-18, the user reported that M1 loaded on a physical Android device, the implemented work was visibly present, and Milestone 1 passed. This is limited manual user-reported validation, not a detailed action matrix or performance profile; hardware, OS, sustained frame rate, thermals, and per-feature observations were not supplied.

Not delivered in M1: production character animation/art, swinging, wall running/climbing, parkour actions, combat, missions, progression, or final-world content. The temporary BURST remains only as a regression/probe control.

Acceptance evidence is in [docs/M1_ACCEPTANCE.md](docs/M1_ACCEPTANCE.md).

## M2 — Superhero parkour and wall traversal

Status: **accepted; implementation/package complete and limited user-reported physical-device validation recorded**

Delivered:

- dedicated data-driven traversal tuning, reusable probe result, bounded surface detector, exclusive ten-state traversal state machine, action controller, and opt-in debug visualizer;
- explicit idle/wall-run/vertical-wall-run/wall-climb/wall-jump/vault/mantle/ledge-grab/ledge-climb/recovery transitions layered over the preserved nine M1 movement states;
- authored valid/invalid traversal-surface policy with wall normal/angle/direction/distance, separated height probes, top/ledge detection, obstacle height, standing-capsule clearance, and vault landing checks;
- momentum-aware horizontal wall running, finite vertical traversal, wall jumps, automatic vaults, two-phase mantles, ledge hang/climb/drop/jump-away, and limited lateral ledge movement;
- three-wall-jump chain budget, reattachment/regrab cooldowns, duration/distance/speed exits, collision-safe scripted paths, and recovery to ordinary movement;
- subtle traversal camera look-ahead/vertical framing/FOV/arm response without forced yaw;
- F8 debug rays, normals, targets, state, speed, velocity, surface, action, exit reason, and query count; disabled by default and excluded from normal release behavior;
- expanded 85-feature/32-marker laboratory with 26 parkour-specific features, several routes, corners, parallel walls, dead ends, gaps, blocked mantles, tiny geometry, and explicit invalid surfaces;
- separate M1 regression and M2 acceptance processes covering detection, invalid/blocked rejection, wall entry/exit/jump, vertical limits, slow/high-speed cases, anti-chain rules, vault/mantle/ledge actions, momentum, recovery, camera, debug toggle, and multitouch.

- Artifact: `releases/milestone-2/aerial-vanguard-relay-m2-debug.apk`
- Size: 27,880,145 bytes
- SHA-256: `e10051e2992009b867ba5a49a8410861c5de4c734f38a5c85f91ba377013bd7d`
- Package result: version code 3 / `0.2.0-m2`, API 24–36, arm64, v2/v3 signed, 16 KB ZIP aligned, `0x4000` native LOAD aligned, clean archive, no requested permissions reported.

Not delivered: swinging/tether traversal, combat, enemies, missions, open-world expansion, production skeletal traversal animation/IK, final art, or final customization.

On 2026-08-18, the user reported that M2 works fine on their physical Android phone and accepted the milestone. This is limited manual user-reported validation, not a detailed traversal/performance matrix; hardware, OS, sustained frame rate, thermals, and per-feature observations were not supplied.

Acceptance evidence is in [docs/M2_ACCEPTANCE.md](docs/M2_ACCEPTANCE.md). Development remains stopped after M2; no swinging work has started.

## M3 — Swinging/tether traversal (future; not started)

The user has accepted the M2 phone checkpoint. Swinging remains unstarted and begins only on explicit instruction. No combat, missions, progression, final city, or final hero art should depend on traversal until its later detailed physical/performance gates pass.
