# Aerial Vanguard: Relay

An original third-person mobile superhero project focused on momentum, parkour, aerial traversal, responsive touch controls, and a dense fictional city. The hero, setting, visual language, mechanics, code, and current procedural test content are original to this project.

> The GitHub repository is named `spiderman` only because that repository name was requested. This project contains no Spider-Man, Marvel, Insomniac, copied map, ripped asset, copied character, copied animation, logo, dialogue, or code.

## Milestone 2 — Superhero parkour and wall traversal

Milestone 2 preserves the accepted Android foundation and core movement, then adds:

- a data-driven, mutually exclusive ten-state traversal architecture layered over the existing movement modules;
- bounded authored-surface detection with wall normal/direction/distance, top/ledge, height, landing, and clearance checks;
- momentum-aware horizontal wall runs, finite vertical wall runs/climbs, wall jumps, contextual vaults, mantles, ledge grabs/climbs/drops/jump-aways, and recovery;
- anti-infinite-climb chain limits, reattachment cooldowns, collision-safe action paths, and clean handoff to ordinary movement;
- subtle parkour camera framing without forced yaw;
- unchanged two-thumb move/look/JUMP controls with no additional parkour button;
- opt-in debug-build traversal rays, normals, targets, state, velocity, surface, and query HUD;
- an 85-feature, 32-marker graybox laboratory with 26 deliberate parkour cases and several linked routes;
- separate full Milestone 1 regression and Milestone 2 acceptance processes;
- a verified API 36 arm64 debug APK with version code 3.

Swinging/tether traversal, combat, enemies, missions, open-world expansion, and final character art/animation are intentionally **not** implemented. Milestone 2 is accepted; no later milestone has been started.

## Download

[Download Milestone 2 debug APK](releases/milestone-2/aerial-vanguard-relay-m2-debug.apk)

- Package: `com.gojocodes.aerialvanguard`
- Version: `0.2.0-m2` (`versionCode 3`)
- Size: 27,880,145 bytes
- SHA-256: `e10051e2992009b867ba5a49a8410861c5de4c734f38a5c85f91ba377013bd7d`
- Android: API 24 minimum, API 36 target/compile, `arm64-v8a`, landscape

Prior immutable checkpoints remain available: [Milestone 1](releases/milestone-1/aerial-vanguard-relay-m1-debug.apk) and [Milestone 0](releases/milestone-0/aerial-vanguard-relay-m0-debug.apk).

These are sideloadable debug-signed development builds, not Play Store releases. M0, M1, and M2 have limited user-reported physical validation. On 2026-08-18, the user reported that the M2 build works fine on their physical Android phone and accepted the milestone. No phone model, Android version, per-action results, or performance measurements were supplied or inferred.

## Controls

| Action | Touch | Desktop development | Controller |
|---|---|---|---|
| Move | Left virtual stick | WASD / arrows | Left stick |
| Look | Drag right side | Hold right mouse and drag | Right stick |
| Sprint | Hold SPRINT | Shift | Left-stick click |
| Jump / contextual traversal | JUMP | Space | South/A button |
| Camera recenter | Automatic | C | Right-stick click |
| Temporary movement probe | BURST | E | Right shoulder |
| Traversal diagnostics | Not exposed on touch | F8 in debug builds | — |

Contextual actions use movement direction, momentum, JUMP, wall angle, obstacle height, and destination clearance. Angled airborne wall approach selects a horizontal run; direct approach selects finite vertical traversal; running at a low clear obstacle selects vault; reachable tops select mantle; falling toward a clear ledge selects grab. JUMP during wall traversal jumps away; JUMP while hanging climbs; holding away drops or jumps away.

## Develop and verify

Use Godot `4.6.3-stable`, open `project.godot`, and run the main scene. The pinned Android toolchain and exact commands are in [DEVELOPMENT.md](DEVELOPMENT.md).

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/verify_project.sh
GODOT_BIN=/absolute/path/to/godot ./scripts/build_android_debug.sh
ANDROID_SDK_ROOT=/absolute/path/to/android-sdk \
  ./scripts/verify_apk.sh releases/milestone-2/aerial-vanguard-relay-m2-debug.apk
```

Project records:

- [Milestone 2 acceptance](docs/M2_ACCEPTANCE.md)
- [Development and tuning](DEVELOPMENT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Test plan](docs/TEST_PLAN.md)
- [Performance evidence and targets](PERFORMANCE.md)
- [Known issues](KNOWN_ISSUES.md)
- [Assets and licences](ASSETS.md)
- [Research log](docs/RESEARCH.md)
- [Original universe](docs/ORIGINAL_UNIVERSE.md)
- [Technical decision](docs/TECHNICAL_DECISION.md)
- [Milestone history](MILESTONES.md)
