# Milestone 1 acceptance report

Date: 2026-08-18 UTC

Status: **accepted; implementation/package complete and limited user-reported physical-device validation recorded**

Artifact: `releases/milestone-1/aerial-vanguard-relay-m1-debug.apk`

## Artifact identity

| Field | Verified value |
|---|---|
| File size | 27,808,805 bytes |
| SHA-256 | `73653e3e92ac759c019b2d8ab34643827e6881044b28a220af3d6a529bc1f58b` |
| Package | `com.gojocodes.aerialvanguard` |
| Label | `Aerial Vanguard Relay` |
| Version | `0.1.0-m1` |
| Version code | 2 |
| Compile SDK | 36 |
| Target SDK | 36 |
| Minimum SDK | 24 |
| Native ABI | `arm64-v8a` |
| Orientation | Landscape |
| Requested Android permissions | None reported by `aapt2 dump permissions` |

Milestone 0's APK was neither overwritten nor reconstructed. This is a distinct version-code 2 artifact.

## Automated movement acceptance

The real main scene passed the Godot 4.6.3 headless suite:

```text
[M1 TEST] PASS architecture_data states=9 reusable_input_snapshot=true features=59
[M1 TEST] PASS speed_bands walk=2.43 jog=7.20 sprint=11.80
[M1 TEST] PASS camera_relative delta=(4.66, 0.00)
[M1 TEST] PASS fixed_tick_30_60 distance30=16.060 distance60=15.965 delta=0.095
[M1 TEST] PASS rapid_direction_changes max_speed=2.53 drift=0.52
[M1 TEST] PASS jump_air_control_spam jump_v=9.93 sprint=11.80 air_dx=0.51 jumps=5
[M1 TEST] PASS landing_and_edges soft=12.35 hard=24.05 runoff=true
[M1 TEST] PASS steps_stairs_slopes short=2.23 long=4.21 ramp18=5.28 ramp38=7.12 ramp55=0.97
[M1 TEST] PASS walls_platform_camera_collision obstructed=0.38 clear=1.00
[M1 TEST] PASS aspect_ratios 16:9 20:9 19.5:9 16:10 4:3
[M1 TEST] PASS simultaneous_touch move+look+jump retained
[M1 TEST] PASS camera_limits_recenter pitch=[-55.0, 24.0] arm=7.13>6.21 fov=76.5>70.1
[M1 TEST] PASS milestone_0_regression distance=2.26 jump=9.93 burst=19.44
[M1 TEST] PASS suite_ms=35230.5 distance_30=16.060 distance_60=15.965 features=59
[SMOKE] PASS milestone=1 movement_lab=true camera_collision=true multitouch=true
```

This checks project parsing, module composition, data ordering, input snapshot reuse, all nine movement states, speed transitions, non-snapping deceleration, camera-relative travel, fixed-tick consistency, rapid reversals, sprint jump momentum, air steering, jump buffering/spam, roof edges, soft/hard landing classification and recovery, supported/rejected step heights, stairs, slopes, walls, narrow platforms, camera obstruction/recovery, layout geometry, concurrent touch channels, pitch limits/recentering, and the Milestone 0 functional regression.

## Android package acceptance

- `apksigner`: APK Signature Scheme v2 and v3 verified; one debug signer.
- `zipalign -c -P 16 -v 4`: verification successful.
- `readelf -lW`: every `LOAD` segment in both arm64 shared libraries reports `0x4000` alignment.
- `aapt2`: expected package, version code 2, API 24 minimum, API 36 target, and arm64 ABI.
- `unzip -t`: no archive errors.
- No Android permissions were reported.

## User-reported physical-device validation

On 2026-08-18, the user reported manually running Milestone 1 on a physical Android device. The user stated that the game loaded, the implemented Milestone 1 work was visibly present, and Milestone 1 passed.

**This is limited USER-REPORTED PHYSICAL-DEVICE VALIDATION. It is not an automated test, emulator result, workspace-connected-device test, detailed movement matrix, or performance profile.**

The report establishes launch and the user's visual confirmation/acceptance of the milestone. It does not establish individual outcomes for every movement, collision, camera, multitouch, 30/60 fps, aspect-ratio, thermal, memory, or long-session case. The phone model and Android version were not reported. Those items remain unverified rather than inferred.
