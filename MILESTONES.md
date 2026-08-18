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

Status: **implementation, automated acceptance, and Android package complete; physical-device validation pending**

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

Not delivered: physical-device testing of M1, production character animation/art, swinging, wall running/climbing, parkour actions, combat, missions, progression, or final-world content. The temporary BURST remains only as a regression/probe control.

Acceptance evidence is in [docs/M1_ACCEPTANCE.md](docs/M1_ACCEPTANCE.md). Development stops here until the user reports physical-device feedback.

## M2 — Superhero traversal mechanics (future; not started)

M2 may prototype tether/swing, wall traversal, parkour, diving, momentum, and aerial tricks only after Milestone 1 physical-device feedback is reviewed and major movement/camera defects are fixed.

No combat, missions, progression, final city, or final hero art should depend on traversal until its own test gates pass.
