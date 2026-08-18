# Technical decision: engine and Android foundation

Decision date: 2026-08-18

Status: accepted for the foundation and first traversal vertical slice; reassess after on-device M1 profiling

## Decision

Use **Godot 4.6.3 with the Mobile renderer and GDScript** for the runnable project in this environment.

Unreal Engine 5.8 remains the preferred comparison point for a future production-engine reassessment, but it was not selected here because it could not be installed, built, launched, packaged, or tested with the available workspace and credentials. Shipping an untested Unreal folder would not satisfy the requirement to verify what genuinely runs.

## Environment evidence

Initial inspection found:

- no Unreal Editor or Unreal build toolchain;
- no Unreal source checkout or Epic entitlement available to the workspace;
- no Unity editor/licence installation;
- Java 17 available;
- no Android SDK or ADB-ready user configuration;
- enough disk space for a compact engine/toolchain, but not a verified Unreal installation workflow.

An official Godot 4.6.3 editor and matching export templates could be downloaded, checksum-verified, launched headlessly, and used to import, test, package, align, and sign the project. An official Android command-line SDK was also installed and checksum-checked in temporary tooling storage.

## Unreal 5.8 assessment

Epic's current Android requirements identify UE 5.8, JDK 21.0.3, Android Build Tools 35.0.1, NDK r27c, recommended target SDK 35, minimum Android 8/API 26, arm64, OpenGL ES 3.2, and Vulkan 1.1 on supported Android 10+ hardware.

That stack could be appropriate on a provisioned workstation, but two immediate risks block an honest selection here:

1. The editor and its platform toolchain were unavailable, so no source, scene, cook, package, launch, or performance test could be run.
2. Google Play requires new apps and updates to target API 36 starting 2026-08-31, while Epic's UE 5.8 requirements page currently recommends target 35. That does not prove UE 5.8 cannot target 36, but it creates a release-timing risk that would need direct package validation.

## Why Godot is the feasible choice

- The exact engine binary and templates were available from the official project and verified against published checksums.
- Godot's stable Android workflow supports OpenJDK 17 and native Android export.
- Godot 4.6.3 includes the 2026 Android version bump and an API 36 back-navigation fix.
- The Mobile renderer is designed for mobile-class GPUs and exposes a practical route to scale resolution, antialiasing, lights, shadows, and content density.
- Open-source/MIT licensing avoids an editor-seat or build-service dependency for this prototype.
- The small GDScript foundation can be automated headlessly, while hotspots can later move to native GDExtension code only when profiling justifies it.

## Verified result

The selected stack produced:

- a parsed/imported Godot project with no script errors;
- a deterministic headless gameplay pass;
- a signed `arm64-v8a` APK;
- package `com.gojocodes.aerialvanguard`;
- compile/target API 36 and minimum API 24;
- v2 and v3 APK signatures;
- successful 16 KB ZIP alignment;
- `0x4000` LOAD alignment for both included arm64 native libraries;
- valid ZIP/archive contents.

The APK has **not** been installed or run on a physical Android device in this workspace. That is a separate gate, not an implied result.

## Build-path detail

Godot's Gradle template was installed and reached dependency resolution, but the sandbox's Java network path could not resolve Android Gradle Plugin 8.6.1. Milestone 0 uses Godot's official prebuilt debug APK template instead. Godot 4.6.3's template targets API 36, which the manifest inspection confirmed.

Production Play delivery requires an AAB, Gradle, a private release key, Play signing setup, and another full test pass. None is claimed here.

## Reassessment triggers

Reconsider the engine before major content production if any of these occur:

- M1 cannot sustain target frame time on representative devices after reasonable optimization;
- required animation, streaming, tooling, or graphics work would cost more to build than migration;
- Unreal 5.8+ becomes genuinely runnable in the development environment with API 36 packaging verified;
- production staffing or licensed assets strongly favor another engine;
- the project requires a capability that cannot be implemented or maintained reliably in Godot.

An engine change must preserve the original universe and system boundaries; it is not permission to import protected content.
