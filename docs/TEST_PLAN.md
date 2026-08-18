# Test plan

## Test order

```mermaid
flowchart TD
    A["Pure module tests"] --> B["Scene integration"]
    B --> C["Android package checks"]
    C --> D["Physical device function"]
    D --> E["Sustained performance"]
    E --> F["Dependent gameplay systems"]
```

Do not build systems represented to the right of a failed gate.

## Milestone 0 checks

| Check | Method | Result |
|---|---|---|
| Engine launch | Godot 4.6.3 headless version/editor startup | Pass |
| Project import | Headless editor import, all scripts/scenes loaded | Pass |
| Scene boot | Main scene in headless Mobile rendering mode | Pass |
| World setup | Count nodes in `city_building` group | Pass: 16 |
| Quality setup | Find quality manager and apply default tier | Pass: MEDIUM, scale 0.78 |
| Locomotion | Drive touch intent for 24 physics frames | Pass: 3.23 m |
| Jump | Request touch jump and inspect upward velocity | Pass: 10.50 m/s |
| Burst probe | Request touch burst and inspect horizontal speed | Pass: 22.16 m/s |
| APK build | Godot official prebuilt Android debug template | Pass |
| Manifest | `aapt2 dump badging/xmltree` | Pass: expected package, API 36 target, landscape launcher |
| ABI | `aapt2 dump badging` and ZIP listing | Pass: arm64 only |
| Signature | `apksigner verify --verbose` | Pass: v2 and v3 |
| ZIP/page packaging | `zipalign -c -P 16 -v 4` | Pass |
| Native LOAD alignment | `readelf -lW` | Pass: all LOAD segments `0x4000` |
| Archive | `unzip -t` | Pass |
| Physical install/launch and basic controls | Manual user test on a real Android phone | User-reported pass: install, launch, landscape, movement, right drag, JUMP, BURST, no immediate crash; hardware/performance details not reported |

## Device functional matrix

Run on at least one LOW-class and one MEDIUM-class arm64 phone:

- clean install and launch;
- correct landscape orientation and safe-area layout;
- multitouch movement/look/action-button combinations;
- suspend, resume, screen lock, incoming interruption, and relaunch;
- no unintended permissions;
- controller connection/disconnection if supported;
- thermal state and battery behavior over 15 minutes;
- 4 KB and, when available, 16 KB page-size runtime;
- uninstall/reinstall and signing-key behavior.

Record model, SoC/GPU, RAM, OS/API, refresh rate, page size, build hash, quality tier, test duration, average/percentile frame time, peak memory, and every defect.

## Milestone 1 core-movement automated matrix

| Area | Probe | Accepted result |
|---|---|---|
| Architecture | Required modules, nine states, tuning resource, reusable input snapshot | Pass |
| Walk/jog/sprint | Analog 0.30, full input, sprint hold | 2.43 / 7.20 / 11.80 m/s |
| Acceleration/deceleration | First stopping frame then settle | Pass: no snap; settles below 0.15 m/s |
| Camera-relative movement | Camera faces world-right, stick forward | Pass: 4.66 m primarily world +X |
| Fixed physics rate | Identical 1.5 s sprint at 30 and 60 Hz | 16.060 / 15.965 m; 0.095 m delta |
| Direction reversal | 24 alternating four-frame inputs | Pass: 2.53 m/s peak, 0.52 m drift |
| Jump/air | Sprint jump, air steer, repeated buffered requests | Pass: 9.93 m/s vertical, 11.80 m/s horizontal, 0.51 m steer, five jumps |
| Landing | Medium/high drop and roof run-off | Pass: 12.35 m/s soft, 24.05 m/s hard, falling/landing states |
| Steps/stairs/slopes | 0.10/0.20/0.32/0.48 m steps, stairs, 18°/38°/55° ramps | Pass: supported heights climb; 0.48 m and 55° reject |
| Walls/platforms | Blocking wall and 1.35 m narrow platform | Pass: no penetration or material lateral drift |
| Camera collision | Three-wall compression bay then open flat | Pass: arm ratio 0.38 obstructed / 1.00 clear |
| Aspect layout | 16:9, 20:9, 19.5:9, 16:10, 4:3 | Pass: controls remain in bounds and separated |
| Simultaneous touch | Independent move/look IDs plus jump one-shot | Pass |
| Camera orbit | Extreme pitch inputs and requested recenter | Pass: -55° to +24°, stable travel-target recenter |
| M0 regression | Move, jump, temporary BURST | Pass: 2.26 m / 9.93 m/s / 19.44 m/s |

## Milestone 1 physical-device gate

Milestone 1 received limited user-reported physical validation on 2026-08-18: the game loaded, the implemented work was visibly present, and the user accepted the milestone. This was not a detailed movement or performance matrix. See [M1_ACCEPTANCE.md](M1_ACCEPTANCE.md).

## Milestone 2 parkour automated matrix

| Area | Probe | Accepted result |
|---|---|---|
| Architecture | Required modules/resources, ten exclusive states, legal transitions, M1 composition retained | Pass |
| Surface policy | Tagged wall versus explicit invalid wall, tiny geometry, shallow surface, blocked top | Pass: valid accepted; unsuitable candidates rejected |
| Query budget | Clear intent and selected obstacle/wall paths | Pass: detector cap 8; observed action-test peak 4 |
| Horizontal wall run | Angled airborne entry, along-wall travel, wall jump | Pass: 9.20 m/s entry, 2.31 m travel, 4.67 m/s away component |
| Horizontal edge cases | Slow entry, high entry, invalid wall, sudden wall end | Pass: slow/invalid reject, high speed clamps, end exits cleanly |
| Vertical traversal | Direct wall entry, rise, climb transition, duration/distance exhaustion | Pass: 3.45 m rise under 4.25 m configured limit; climb visited; returns to air |
| Wall-jump exploit guard | Repeated close-wall attachment attempts | Pass: chain budget enforced and resets only on grounding |
| Vault | Low obstacle, forward intent, landing clearance, momentum handoff | Pass: contextual entry and 7.74 m/s preserved exit speed |
| Mantle | Reachable top, blocked destination, collision-safe two-phase path | Pass: valid reaches 2.45 m top; blocked target rejected |
| Ledge | Falling grab, hang, climb, hold-away drop, away+jump | Pass: grab at 5.99 m, both exits recover without state lock |
| Camera | Wall-run observation, subtle FOV/offset, orbit ownership | Pass: traversal FOV response; no forced yaw |
| Debug | Default release state and F8 debug-build toggle | Pass: disabled by default; debug-only toggle works |
| Multitouch | Move + look + JUMP through the shared input router | Pass: independent channels retained |
| M1 regression | Full M1 suite in a separate Godot process | Pass: all M0/M1 acceptance markers preserved |

The deterministic lab contains 85 total collision features, 32 markers, and 26 parkour-specific features. It deliberately includes corners, dead ends, parallel walls, blocked tops, invalid surfaces, tiny objects, gaps, and chained routes.

## Milestone 2 physical-device gate

On 2026-08-18, the user reported that the M2 build works fine on their physical Android phone and accepted the milestone. This is limited user-reported validation: the user did not provide a phone/OS, separate action-by-action results, sustained frame pacing, thermal data, or a defect matrix. Detailed frame pacing, thermal, aspect-ratio, and edge-case profiling is deferred until the later extensive-test phase.

Swinging and combat remain unstarted. Automated/headless results and the limited user report are not presented as measured phone-performance evidence.
