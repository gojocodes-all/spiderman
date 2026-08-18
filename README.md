# Aerial Vanguard: Relay

An original third-person mobile superhero game project focused on momentum, aerial traversal, responsive touch controls, and a dense fictional city. The hero, setting, visual language, mechanics, and code are original to this project.

> The GitHub repository is named `spiderman` only because that repository name was requested. This project contains no Spider-Man, Marvel, Insomniac, copied map, ripped asset, copied character, copied animation, logo, dialogue, or code.

## Milestone 0 — Android package smoke test

Milestone 0 deliberately stops at the first validated foundation:

- Godot 4.6.3 Mobile renderer project
- modular input, movement, camera, player composition, quality, world, and touch UI scripts
- landscape touch controls plus keyboard/mouse development controls
- deterministic procedural 16-building test block
- grounded movement, air control, jump, and a temporary momentum-burst probe
- Low/Medium/High/Ultra render-scale hooks
- signed, arm64 Android debug APK targeting API 36
- automated headless gameplay smoke test

Swinging, wall traversal, combat, missions, streaming, traffic, pedestrians, final art, and progression are intentionally **not** implemented yet. Those systems must wait for device validation of this foundation.

## Download

[Download Milestone 0 debug APK](releases/milestone-0/aerial-vanguard-relay-m0-debug.apk)

- Package: `com.gojocodes.aerialvanguard`
- Version: `0.0.1-m0` (`versionCode 1`)
- SHA-256: `138fad0e7185daa3fe929d88df77a41db9267932a54ec209f5a912d21cc217a5`

This is a sideloadable development build signed with a debug key. It is not a Play Store release and has not been run on a physical Android device in this workspace.

## Controls

| Action | Touch | Desktop development |
|---|---|---|
| Move | Left-side virtual stick | WASD |
| Look | Drag the right side | Hold right mouse and drag |
| Jump | JUMP button | Space |
| Momentum probe | BURST button | Shift |

## Start developing

Use Godot `4.6.3-stable`, open `project.godot`, and run the main scene. See [DEVELOPMENT.md](DEVELOPMENT.md) for the pinned Android toolchain and validation commands.

Project records:

- [Technical decision](docs/TECHNICAL_DECISION.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Original universe](docs/ORIGINAL_UNIVERSE.md)
- [Research log](docs/RESEARCH.md)
- [Milestone 0 acceptance](docs/M0_ACCEPTANCE.md)
- [Assets and licences](ASSETS.md)
- [Performance plan](PERFORMANCE.md)
- [Known issues](KNOWN_ISSUES.md)
