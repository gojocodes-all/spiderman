# Contributing to Aerial Vanguard: Relay

Thank you for helping improve the project. Keep changes focused on the accepted
Milestone 0–2 foundation unless a later milestone has been explicitly started.
Swinging, combat, enemies, missions, open-world expansion, and final character
art or animation are not part of the current implementation.

## Before you start

Read the records that govern the area you plan to change:

- [Development and tuning](DEVELOPMENT.md) for the pinned engine, Android
  toolchain, commands, module ownership, and definition of done.
- [Architecture](docs/ARCHITECTURE.md) for motion ownership, dependency rules,
  and traversal-surface contracts.
- [Test plan](docs/TEST_PLAN.md) for the automated and device-validation gates.
- [Known issues](KNOWN_ISSUES.md) for accepted limitations and deferred work.
- [Asset ledger](ASSETS.md) before adding any visual, animation, audio, map,
  font, or code-bearing asset.
- [Original universe](docs/ORIGINAL_UNIVERSE.md) for the project's original-IP
  boundary.

Do not silently upgrade Godot or the Android toolchain. Toolchain changes need a
dedicated pull request, rebuilt artifacts, and renewed acceptance evidence.

## Local setup

Use the versions recorded in `DEVELOPMENT.md`:

- Godot `4.6.3.stable.official.7d41c59c4` with matching export templates;
- OpenJDK 17;
- Android SDK Platform 36 and Build Tools 35.0.1 when building Android.

Open `project.godot` in Godot and allow the first import to finish. The
automated verifier performs its own headless import for clean-clone validation.

## Make a focused change

Follow the existing module boundaries rather than placing unrelated behavior in
the player composition root:

- input: `game/scripts/input/`;
- movement and camera tuning: `game/data/movement/`;
- ground and air movement: `game/scripts/movement/`;
- traversal tuning and behavior: `game/data/traversal/` and
  `game/scripts/traversal/`;
- camera: `game/scripts/camera/`;
- touch and debug UI: `game/scripts/ui/`;
- deterministic milestone coverage: `game/scripts/tests/`.

Prefer data-only tuning when behavior does not require a new system. Preserve
the single motion-owner contract described in `docs/ARCHITECTURE.md`, and add
deterministic coverage for new states, transitions, collision rules, or input
paths.

## Validate the change

Run the complete clean-clone-compatible gate for shell tooling, gameplay,
scene, input, tuning, or project-configuration changes:

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/validate.sh
```

A successful run must pass shell syntax checks, both command-wrapper regression
suites, and both milestone pass markers. GitHub Actions runs the same entry
point on pull requests and updates to `main`.

If the change affects Android packaging, also build and verify the debug APK:

```bash
GODOT_BIN=/absolute/path/to/godot ./scripts/build_android_debug.sh

ANDROID_SDK_ROOT=/absolute/path/to/android-sdk \
  ./scripts/verify_apk.sh build/android/aerial-vanguard-m2-debug.apk
```

The APK verifier checks the signature, 16 KB alignment, package identity, SDK
levels, ABI, permissions, archive integrity, and native segment alignment.

Documentation-only changes should still verify every relative link and command
against the current tree. Do not claim device, performance, accessibility, or
packaging results that were not actually observed.

## Assets, security, and generated files

- Use only original or clearly licensed assets and record them in `ASSETS.md`
  before merge.
- Never import protected characters, names, logos, maps, dialogue, animation
  data, code, or ripped assets.
- Never commit signing keys, keystores, credentials, generated Godot state, or
  local Android build output.
- Keep APK publication separate from source changes. Release artifacts require
  their own verified checksums and acceptance record.

## Pull request checklist

Before opening a pull request:

1. Keep the change within one clear purpose and the current milestone scope.
2. Add or update deterministic tests when runtime behavior changes.
3. Run the relevant validation above and record the exact result.
4. Update affected architecture, test-plan, tuning, asset, known-issue, or
   acceptance documentation.
5. Add a dated entry to `.github/maintenance-log.md` with the rationale, files
   changed, validation performed, risk level, and rollback note.
6. Review the complete diff for original-IP compliance, security, mobile input,
   performance implications, backward compatibility, and generated files.

Physical-device evidence must identify what was tested and what remains
unknown. A successful headless suite or Android build is not a substitute for
measured device behavior.
