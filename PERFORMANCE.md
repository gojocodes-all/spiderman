# Performance plan

Last updated: 2026-08-18

## Current evidence

Milestone 0 has limited user-reported functional validation on one unspecified Android phone, but **no representative device performance numbers**. Milestone 1 passes deterministic headless physics tests and static Android package checks. None of those results may be presented as an on-device frame-rate claim.

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

## Next measurement gate

The Milestone 1 APK must be profiled on physical Android hardware at both a 30 fps cap and a 60 fps target where the phone supports it. Record CPU/GPU frame time, frame pacing, memory, temperature/thermal state, battery behavior, input feel, and any quality-tier changes over a repeatable 15-minute laboratory route. Until then, LOW/MEDIUM/HIGH/ULTRA rows remain targets rather than claims.
