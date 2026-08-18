# Milestone 1 acceptance report

Date: 2026-08-18 UTC

Status: **implementation, automated acceptance, and Android package complete; physical-device validation pending**

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

## Physical-device test requested

This Milestone 1 APK has **not** been run on a physical device by the workspace. On the Android phone used for Milestone 0, please specifically test:

1. Install over M0 if Android permits the matching debug signature; otherwise uninstall M0 and install M1. Confirm launch and landscape layout.
2. Slowly tilt the left stick through walk and jog, then hold SPRINT. Check transitions, stopping distance, rapid left/right reversals, and diagonal movement.
3. Rotate the camera, then push the stick forward. Confirm movement follows the camera's horizontal facing.
4. Move while dragging the camera; move while tapping JUMP; drag the camera while jumping; then combine move + look + JUMP repeatedly.
5. Sprint-jump, steer in the air, run off roof edges, and land from several heights. Note whether soft versus hard recovery feels readable and responsive.
6. Traverse the 0.10/0.20/0.32 m step lane, short and long stairs, the green 18° ramp, the amber 38° ramp, and the red 55° rejected ramp. Report snagging, popping, jitter, or unexpected climbing.
7. Run through both alleys, press into walls/corners, and cross the narrow platforms. Check for penetration, sticking, lateral drift, or unstable grounded state.
8. Enter the three-wall camera bay and rotate the camera against every wall. Confirm it compresses instead of clipping through geometry, then recovers on exit.
9. Hold SPRINT while moving and looking, then release it. Confirm no touch remains stuck. Check JUMP and temporary BURST independently.
10. If possible, compare 30 fps and 60 fps device modes, then play continuously for 15 minutes and report frame pacing, heat, battery behavior, and any crash or freeze.

Please report phone model, Android version, selected quality tier, display refresh rate if known, and exact reproduction steps for defects. Swinging and combat remain intentionally absent until this feedback is reviewed.
