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

## Explicitly not accepted yet

- APK installation and launch on a real phone;
- Vulkan driver/device compatibility;
- physical multitouch behavior;
- audio, lifecycle, safe-area, and haptic behavior;
- memory, battery, heat, frame pacing, or sustained fps;
- Google Play AAB/release signing.

Milestone 0 is therefore an **Android-capable package checkpoint**, not proof of production device performance.
