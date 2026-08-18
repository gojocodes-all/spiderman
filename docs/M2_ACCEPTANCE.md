# Milestone 2 acceptance report

Date: 2026-08-18 UTC

Status: **accepted; implementation/package complete and limited user-reported physical-device validation recorded**

Artifact: `releases/milestone-2/aerial-vanguard-relay-m2-debug.apk`

## Artifact identity

| Field | Verified value |
|---|---|
| File size | 27,880,145 bytes |
| SHA-256 | `e10051e2992009b867ba5a49a8410861c5de4c734f38a5c85f91ba377013bd7d` |
| Package | `com.gojocodes.aerialvanguard` |
| Label | `Aerial Vanguard Relay` |
| Version | `0.2.0-m2` |
| Version code | 3 |
| Compile/target SDK | 36 / 36 |
| Minimum SDK | 24 |
| Native ABI | `arm64-v8a` |
| Orientation | Landscape |
| Requested Android permissions | None reported by `aapt2 dump permissions` |

M0 and M1 APKs were neither overwritten nor reconstructed. M2 is a distinct version-code 3 artifact stored in its own release directory.

## Delivered traversal scope

- Ten mutually exclusive traversal states: idle, horizontal wall run, vertical wall run, wall climb, wall jump, vault, mantle, ledge grab, ledge climb, and recovery.
- A reusable, bounded detector for authored stable surfaces, wall geometry, tops, obstacle height, landing space, and destination clearance.
- Contextual horizontal/vertical wall traversal, wall jump, vault, mantle, ledge hang/climb/drop/jump-away, momentum handoff, finite climb limits, cooldowns, and anti-chain budget.
- Subtle camera framing without forced player-view rotation.
- Debug-build-only visualization/HUD, disabled by default.
- An 85-feature/32-marker parkour lab containing 26 dedicated parkour cases, multiple routes, valid/invalid geometry, blocked tops, corners, parallel walls, gaps, alleys, and roof transitions.

No swinging/tether traversal, combat, enemies, missions, large-world expansion, or copied/proprietary animation was added.

## Automated acceptance

The exact Godot 4.6.3 main scene passed the preserved M1 process and the M2 process independently:

```text
[M1 TEST] PASS architecture_data states=9 reusable_input_snapshot=true features=85
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
[M1 TEST] PASS camera_limits_recenter pitch=[-55.0, 24.0] arm=7.14>6.21 fov=76.5>70.1
[M1 TEST] PASS milestone_0_regression distance=2.26 jump=9.93 burst=19.44
[M1 TEST] PASS suite_ms=35196.5 distance_30=16.060 distance_60=15.965 features=85
[SMOKE] PASS milestone=1 movement_lab=true camera_collision=true multitouch=true
[M2 TEST] PASS architecture_state states=10 parkour_features=26 debug_default=false
[M2 TEST] PASS surface_detection valid=true invalid_rejected=true tiny_rejected=true blocked_rejected=true queries<=8
[M2 TEST] PASS horizontal_wall_run_jump entry=9.20 travel=2.31 away=4.67 direction=(-0.28,-0.96)
[M2 TEST] PASS vertical_limit rise=3.45 limit=4.25 climb_visited=true
[M2 TEST] PASS wall_edge_cases slow_rejected invalid_rejected high_clamped end_exit_clean chain_budget_enforced
[M2 TEST] PASS vault_mantle_ledge vault_speed=7.74 mantle_y=2.45 ledge_y=5.99 momentum=true
[M2 TEST] PASS ledge_drop_jump hold_away=drop away+jump=wall_jump no_lock=true
[M2 TEST] PASS camera_debug_multitouch fov=72.6>70.2 forced_yaw=false debug_toggle=true move+look+jump=true
[M2 TEST] PASS suite_ms=8661.5 features=85 markers=32 peak_probe_queries=4
[SMOKE] PASS milestone=2 parkour=true wall_traversal=true m1_preserved=true
```

These are deterministic headless/scene-integration results, not physical-device frame-rate or touch-feel claims.

## Important tuning values

| System | Key values |
|---|---|
| Detection | 1.85 m forward range; wall up-dot ≤ 0.22; 8-query hard cap |
| Horizontal wall run | 5.4 m/s minimum entry; 16.0 m/s entry cap; 1.45 s maximum; 0.22× gravity; 16 m/s² adhesion; 1.25 m/s² loss; 3.8 m/s exit floor |
| Vertical traversal | 4.2 m/s entry; 8.8 m/s initial up; 0.88 s / 4.25 m limits; 11 m/s² gravity; climb phase after 0.38 s |
| Wall jump | 8.4 m/s outward; 8.9 m/s upward; 0.76× tangent preservation; 0.26 s reattach cooldown; three-jump airborne chain budget |
| Vault | 0.42–1.05 m obstacle; 4.0 m/s minimum; 1.75 m forward; 0.36 s; 0.94× momentum handoff |
| Mantle | 0.78–2.35 m top; 1.35 m range; 0.52 s; 0.78× momentum handoff |
| Ledge | 1.30 m range; 0.90 m vertical tolerance; 0.22 s away-hold drop; 0.32 s regrab cooldown |
| Recovery | 0.16 s traversal recovery |

All values are centralized in `game/data/traversal/default_traversal_tuning.tres`; they are not scattered through action code.

## Android package acceptance

- `apksigner`: APK Signature Scheme v2 and v3 verified; one debug signer.
- `zipalign -c -P 16 -v 4`: verification successful.
- `readelf -lW`: every `LOAD` segment in `libc++_shared.so` and `libgodot_android.so` reports `0x4000` alignment.
- `aapt2`: expected package, version code 3, API 24 minimum, API 36 target/compile, and arm64 ABI.
- `aapt2 dump permissions`: no requested Android permissions reported.
- `unzip -t`: no archive errors.

ADB cannot initialize its configuration directory in this managed workspace, so no workspace-connected phone run is claimed.

## User-reported physical-device validation

On 2026-08-18, the user reported that this Milestone 2 build works fine on their physical Android phone and accepted the milestone.

**This is limited USER-REPORTED PHYSICAL-DEVICE VALIDATION. It is not an automated test, emulator result, workspace-connected-device test, detailed traversal checklist, or performance profile.**

The report establishes that the user successfully ran and accepted M2. It does not establish the phone model, Android version, separate results for every parkour action, sustained 30/60 fps, touch latency, thermals, memory behavior, or long-session stability. Those details remain unreported rather than inferred. Detailed testing is deferred, and no swinging work has started.
