# Aerial Vanguard: Relay

An original third-person mobile superhero game project focused on momentum, aerial traversal, responsive touch controls, and a dense fictional city. The hero, setting, visual language, mechanics, and code are original to this project.

> The GitHub repository is named `spiderman` only because that repository name was requested. This project contains no Spider-Man, Marvel, Insomniac, copied map, ripped asset, copied character, copied animation, logo, dialogue, or code.

## Milestone 1 — Core third-person movement

Milestone 1 preserves the validated Android foundation and adds:

- centralized data-driven movement and camera tuning;
- modular semantic movement states and bounded step solving;
- walk, jog, sprint, acceleration/deceleration, direction changes, jump, gravity, air steering, slopes, stairs, soft/hard landings, and camera-relative facing;
- smoothed third-person camera with collision, speed response, pitch limits, recentering, touch, mouse, and controller support;
- independent movement/look touch channels plus JUMP, SPRINT, and temporary BURST buttons;
- a 59-feature deterministic graybox movement laboratory;
- automated 30/60 Hz, collision, landing, camera, multitouch, and aspect-ratio acceptance checks;
- a signed API 36 arm64 debug APK with version code 2.

Swinging, wall traversal actions, combat, missions, streaming, traffic, pedestrians, final art, and progression are intentionally **not** implemented. Development stops for physical-device movement feedback before swinging begins.

## Download

[Download Milestone 1 debug APK](releases/milestone-1/aerial-vanguard-relay-m1-debug.apk)

- Package: `com.gojocodes.aerialvanguard`
- Version: `0.1.0-m1` (`versionCode 2`)
- Size: 27,808,805 bytes
- SHA-256: `73653e3e92ac759c019b2d8ab34643827e6881044b28a220af3d6a529bc1f58b`

The accepted Milestone 0 artifact remains available separately: [download M0](releases/milestone-0/aerial-vanguard-relay-m0-debug.apk).

These are sideloadable development builds signed with a debug key, not Play Store releases. M0 has limited user-reported physical validation; M1 has not yet been physically tested.

## Controls

| Action | Touch | Desktop development |
|---|---|---|
| Move | Left-side virtual stick | WASD |
| Look | Drag the right side | Hold right mouse and drag |
| Jump | JUMP button | Space |
| Sprint | Hold SPRINT | Shift |
| Camera recenter | Automatic | C |
| Temporary momentum probe | BURST button | E |

## Start developing

Use Godot `4.6.3-stable`, open `project.godot`, and run the main scene. See [DEVELOPMENT.md](DEVELOPMENT.md) for the pinned Android toolchain and validation commands.

Project records:

- [Technical decision](docs/TECHNICAL_DECISION.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Original universe](docs/ORIGINAL_UNIVERSE.md)
- [Research log](docs/RESEARCH.md)
- [Milestone 0 acceptance](docs/M0_ACCEPTANCE.md)
- [Milestone 1 acceptance](docs/M1_ACCEPTANCE.md)
- [Assets and licences](ASSETS.md)
- [Performance plan](PERFORMANCE.md)
- [Known issues](KNOWN_ISSUES.md)
