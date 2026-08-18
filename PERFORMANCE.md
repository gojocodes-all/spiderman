# Performance plan

Last updated: 2026-08-18

## Current evidence

Milestones 0, 1, and 2 have limited user-reported functional validation on an unspecified Android phone, but **no representative device performance numbers**. Milestones 1 and 2 pass deterministic headless physics tests and static Android package checks. None of those results may be presented as an on-device frame-rate claim.

## Milestone 1 deterministic evidence

The same 1.5-second sprint probe was run through the real player scene at two fixed physics rates:

| Physics rate | Distance |
|---:|---:|
| 30 Hz | 16.060 m |
| 60 Hz | 15.965 m |
| Absolute difference | 0.095 m (0.59%) |

The final full headless suite completed in 35.23 seconds in this workspace and covered 59 laboratory collision features. That suite duration is a CI/runtime metric, **not** Android CPU/GPU performance evidence.

Movement/camera implementation policies applied in M1:

- the input router reuses one typed snapshot rather than allocating a dictionary every physics tick;
- acceleration, gravity, state updates, camera smoothing, and rotation use delta-time-aware calculations;
- the step solver reuses physics-query parameter/result objects and only performs collision/surface probes after the previous slide reported wall contact;
- `SpringArm3D` owns the camera shape cast instead of a duplicate scripted camera query;
- procedural graybox materials are cached and shared by color;
- no production crowds, traffic, animation graph, particles, audio, or streaming cost was added.

## Milestone 2 traversal evidence

The preserved M1 regression suite still reports the same 30/60 Hz distances and movement/camera results after M2 integration. The M2 scene suite exercises 85 total lab collision features, 32 deterministic markers, and 26 parkour-specific features.

The final M2 process completed its focused scene suite in 8.66 seconds in this workspace and observed a peak of four traversal ray queries in the tested action paths. The detector's configured per-probe hard cap is eight. Suite duration is a regression/CI metric, not Android performance evidence.

Measured query policy in headless acceptance:

| Situation | Traversal query behavior |
|---|---|
| No movement intent | Traversal detector is skipped |
| Clear movement direction | Two forward rays; no shape clearance query |
| Selected wall/obstacle | Bounded upper/lower/top/landing rays as applicable |
| Candidate mantle/vault destination | One-result capsule overlap check only after a candidate top/landing exists |
| Hard cap | At most 8 ray queries per detector probe; observed peak 4 in action filters |
| Debug disabled | No `ImmediateMesh` rebuild and no debug HUD string construction |

Traversal performance policies applied in M2:

- query parameter objects and the typed `TraversalProbeResult` are reused;
- the detector searches only the current camera-relative intent direction rather than enumerating nearby colliders;
- stable explicitly tagged `StaticBody3D` surfaces avoid dynamic-body bookkeeping and unstable attachment cost;
- wall and vertical actions share the same detector rather than running competing sensors;
- destination shape checks occur contextually, not on every clear-space frame;
- the state machine owns exactly one action, preventing duplicate movement integration;
- debug geometry is opt-in, debug-build-only, and disabled in normal gameplay;
- procedural lab materials remain cached/shared, and all M2 geometry uses primitive meshes.

Headless suite duration and query counts are CPU-side regression indicators only. They do not measure Android GPU load, touch latency, power, thermal throttling, or rendered frame pacing.

## Product targets

| Tier | Intended hardware | Frame target | Frame budget | Current 3D scale | Current AA |
|---|---|---:|---:|---:|---|
| LOW | Weaker supported Android | Locked 30 fps | 33.33 ms | 0.62 | FXAA, no MSAA |
| MEDIUM | Ordinary modern Android | Stable 30 fps; 45/60 only if sustained | 33.33 ms baseline | 0.78 | FXAA, no MSAA |
| HIGH | Powerful Android | Stable 60 fps | 16.67 ms | 1.00 | FXAA + 2× MSAA |
| ULTRA | Flagship hardware where practical | Stable 60 fps with added quality | 16.67 ms | 1.00 | FXAA + 4× MSAA |

The present quality manager only applies render scale and antialiasing. Shadow distance, light count, reflection strategy, crowd/traffic density, particles, material complexity, streaming radius, animation update rate, and audio voice count will join the same tier contract only after profiling shows their cost.

## Non-negotiable method

1. Capture CPU and GPU frame time separately; averages alone are insufficient.
2. Record 1%, 0.1%, and worst-frame behavior during traversal stress routes.
3. Test for at least 15 minutes to expose thermal throttling and memory growth.
4. Measure from Android builds on physical devices, not from desktop editor timing.
5. Change one expensive feature at a time and keep before/after captures.
6. Prefer reducing the dominant bottleneck to enabling a fashionable rendering feature.

## Planned device matrix

| Class | Minimum evidence before content scale-up |
|---|---|
| LOW | One older/entry arm64 device; 30 fps, memory, heat, input latency |
| MEDIUM | One ordinary modern arm64 device; default tier sustained route |
| HIGH | One upper-tier device; 60 fps route plus reflections/shadows comparison |
| ULTRA | One current flagship; optional enhancements with thermal fallback |

No specific phone models are claimed until devices are actually available.

## Profiling stack

- Godot profiler and rendering statistics for script, physics, draw, and memory triage.
- Android GPU Inspector/Perfetto where device support allows.
- Android Dynamic Performance Framework and thermal APIs for future adaptive quality.
- Frame pacing library or engine-equivalent pacing validation where useful.
- Reproducible city routes and encounter captures checked into test documentation.

## Early technical policies

- Mobile renderer is the baseline; expensive features are opt-in by tier.
- Use fictional modular cells and hierarchical detail rather than loading a whole dense city.
- Reuse materials, instance repeated geometry, and author LOD/HLOD from asset intake.
- Treat hero/camera/traversal animation as high priority, but cap off-camera animation work.
- Reflections use the cheapest technique that survives side-by-side review on the target tier.
- Crowd and traffic simulation must degrade independently from traversal physics.
- Gameplay physics stays deterministic enough for automated probes; visual secondary motion may scale down.

## Deferred measurement gate

At the later extensive-test phase, the accepted Milestone 2 traversal baseline should be profiled on physical Android hardware at both a 30 fps cap and a 60 fps target where the phone supports it. That later pass should record CPU/GPU frame time, frame pacing, memory, thermal state, battery behavior, input feel, contextual-action predictability, and quality-tier changes over a repeatable parkour route. Until measured, LOW/MEDIUM/HIGH/ULTRA rows remain targets rather than claims.
