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

Status: **accepted with device-runtime validation pending**

Delivered:

- original project/universe boundary;
- modular Godot project;
- procedural package-smoke scene;
- touch and desktop development input;
- basic movement/jump/burst probes;
- four quality-tier hooks;
- signed API 36 arm64 debug APK;
- deterministic headless test and static APK verification.

Not delivered: real-device runtime results, production visuals, or any major gameplay system beyond the locomotion probe.

## M1 — Traversal mechanics laboratory (planned, not started)

Entry gate: M0 APK must run on at least one ordinary modern Android phone and one weaker target-class phone, with touch input, orientation, thermals, frame pacing, and resume behavior recorded.

Planned isolated prototypes:

- physics-driven tether constraint;
- anchor query and validation;
- release velocity and momentum conservation;
- dive/air-control model;
- camera response at low and high speed;
- deterministic traversal tests and first on-device frametime captures.

No combat, missions, progression, final city, or final hero art should depend on traversal until M1 passes its device gate.
