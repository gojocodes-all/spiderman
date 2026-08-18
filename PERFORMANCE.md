# Performance plan

Last updated: 2026-08-18

## Current evidence

Milestone 0 has **no representative device performance numbers**. The scene passes deterministic headless physics tests, and the APK passes static Android checks. Those results must not be presented as a mobile frame-rate claim.

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
