# Milestone 0 acceptance report

Date: 2026-08-18 UTC

Artifact: `releases/milestone-0/aerial-vanguard-relay-m0-debug.apk`

## Artifact identity

| Field | Verified value |
|---|---|
| File size | 27,740,907 bytes |
| SHA-256 | `138fad0e7185daa3fe929d88df77a41db9267932a54ec209f5a912d21cc217a5` |
| Package | `com.gojocodes.aerialvanguard` |
| Label | `Aerial Vanguard Relay` |
| Version | `0.0.1-m0` |
| Version code | 1 |
| Compile SDK | 36 |
| Target SDK | 36 |
| Minimum SDK | 24 |
| Native ABI | `arm64-v8a` |
| Orientation | Landscape |
| Requested Android permissions | None reported by `aapt2 dump permissions` |

## Static acceptance

- `apksigner`: verifies with APK Signature Scheme v2 and v3; one debug signer.
- `zipalign -c -P 16 -v 4`: verification successful.
- `readelf -lW`: every LOAD segment in `libc++_shared.so` and `libgodot_android.so` is aligned to `0x4000` (16 KB).
- `unzip -t`: no archive errors.
- Manifest contains a MAIN/LAUNCHER entry and landscape orientation.
- Only arm64 native libraries are packaged.

## Runtime logic acceptance

Headless main-scene result:

```text
[QUALITY] tier=MEDIUM scale=0.78
[BOOT] Aerial Vanguard Milestone 0 scene ready
[BOOT] renderer=mobile device=GenericDevice
[SMOKE] PASS buildings=16 distance=3.23 jump_v=10.50 burst_speed=22.16
```

This validates project parsing, scene composition, procedural world creation, collision/physics initialization, input routing, locomotion, jump, burst, and clean test exit in the available Linux environment.

## User-reported physical-device validation

On 2026-08-18, the user reported manually downloading this Milestone 0 APK from the GitHub repository, installing it, and running it on a real Android phone.

**Evidence classification: USER-REPORTED PHYSICAL-DEVICE VALIDATION. This was not an automated test, emulator run, or workspace-connected-device run.**

The user confirmed APK installation, application launch, landscape rendering, virtual movement controls, player movement, right-side touch camera control, the JUMP button, the BURST button, and no immediate crash during the initial test.

Milestone 0 is physically validated for exactly those reported behaviors.

## Explicitly not established by that report

- phone model, SoC/GPU, RAM, Android/API version, or display refresh rate;
- sustained Vulkan-driver stability beyond the initial test;
- complex simultaneous-touch combinations or palm rejection;
- audio, lifecycle, suspend/resume, safe-area, and haptic behavior;
- memory, battery, heat, frame pacing, or sustained fps;
- Google Play AAB/release signing.

Milestone 0 is therefore an **Android-capable package checkpoint with limited user-reported physical validation**, not proof of production device performance.
