# Research log

Research date: 2026-08-18

Source policy: official engine/platform documentation first; original creators and licence pages for assets

## Engine and Android findings

| Topic | Primary source | Finding applied to the project |
|---|---|---|
| Unreal Android requirements | [Epic Games — UE 5.8 Android requirements](https://dev.epicgames.com/documentation/en-us/unreal-engine/android-development-requirements-for-unreal-engine) | UE 5.8 documents SDK 35 recommended, SDK 34 minimum compile, NDK r27c, Build Tools 35.0.1, JDK 21, Android 8+, arm64, GLES 3.2 and Vulkan 1.1 on supported devices. The engine was not available to run here. |
| Unreal mobile rendering | [Epic Games — rendering feature reference](https://dev.epicgames.com/documentation/unreal-engine/rendering-features-reference) | Desktop showcase features cannot be assumed on the mobile renderer. The visual target must be met through measured mobile-compatible techniques. |
| Google Play target API | [Google Play target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en) | New apps and updates must target API 36 from 2026-08-31, with a possible extension to 2026-11-01. M0 therefore targets API 36 now. |
| Godot Android export | [Godot Android export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html) | JDK 17 is the recommended stable setup; Android paths live in editor settings; Play AAB export needs Gradle and release signing. |
| Godot 4.6.3 Android maintenance | [Godot 4.6.3 release](https://godotengine.org/article/maintenance-release-godot-4-6-3/) | The release includes the annual Android version bump and an API 36 back-navigation fix. |
| Godot renderers | [Godot renderer overview](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) | Mobile is intended for newer mobile 3D devices and trades features for simpler/faster scenes. Compatibility remains a possible low-end fallback after device testing. |
| Unity alternative | [Unity 6.5 Android requirements](https://docs.unity3d.com/6000.5/Documentation/Manual/android-requirements-and-compatibility.html) | Unity 6.5 documents API 35/36, Android 8+, Vulkan/GLES and 16 KB support. It was considered, but no editor/licence installation was available to build or test, while Godot was fully verifiable. |
| 16 KB pages | [Android — support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) | Native apps need both package and ELF alignment. M0 checks `zipalign -P 16` and confirms `0x4000` LOAD alignment in both arm64 libraries. Runtime testing on a 16 KB device/emulator is still pending. |
| Thermal adaptation | [Android Dynamic Performance Framework](https://developer.android.com/games/optimize/adpf) | Future adaptive quality should react to sustained thermal/performance signals rather than assuming a device class from marketing names. |
| Frame pacing | [Android Frame Pacing library](https://developer.android.com/games/sdk/frame-pacing) | Stable presentation cadence matters as much as average fps; M1 device profiling will evaluate pacing before graphics expansion. |

## Feasibility conclusion

Godot 4.6.3 was the best technically feasible option **in this environment** because it was the only production-capable 3D engine candidate that could be installed from an official source, checksum-verified, executed, headlessly tested, and used to create a valid Android package. This is an evidence-based local decision, not a claim that Godot always outranks Unreal or Unity for every project.

The production ambition remains high, but the near-term goal is a traversal vertical slice, not premature city-scale content. The engine decision is revisited after representative Android performance data exists.

## Milestone 1 movement and camera findings

| Topic | Primary source | Finding applied to Milestone 1 |
|---|---|---|
| Character floor behavior | [Godot `CharacterBody3D`](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html) | `floor_max_angle`, `floor_snap_length`, `floor_constant_speed`, `floor_stop_on_slope`, `safe_margin`, and `max_slides` are configured from the movement resource rather than scattered constants. |
| Camera obstruction | [Godot `SpringArm3D`](https://docs.godotengine.org/en/stable/classes/class_springarm3d.html) | A sphere-shaped spring arm, collision margin, player RID exclusion, and `get_hit_length()` provide camera compression and deterministic obstruction evidence. |
| Predictive body motion | [Godot `PhysicsServer3D.body_test_motion`](https://docs.godotengine.org/en/stable/classes/class_physicsserver3d.html) | The step solver reuses test-motion parameters/results to verify raised clearance without moving blindly through collision. |
| Motion query parameters/results | [Godot `PhysicsTestMotionParameters3D`](https://docs.godotengine.org/en/stable/classes/class_physicstestmotionparameters3d.html) and [`PhysicsTestMotionResult3D`](https://docs.godotengine.org/en/stable/classes/class_physicstestmotionresult3d.html) | Global start transforms, bounded motion, margins, collision normals/travel, and recovery reporting informed the wall-contact-gated step probe. |
| Multitouch event identity | [Godot input-event guide](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) | Separate `InputEventScreenTouch`/`InputEventScreenDrag` indices are retained for movement and camera so two-thumb input does not cancel across channels. |

The design inference from these APIs was to use the engine's grounded-body and spring-arm systems for broad motion/camera behavior, adding a small explicit step solver only where `move_and_slide()` alone did not satisfy stair acceptance. The solver's 0.38 m limit is game tuning, not a limit imposed by Godot.

## Milestone 2 parkour and traversal findings

| Topic | Primary source | Finding applied to Milestone 2 |
|---|---|---|
| Direct-space queries | [Godot `PhysicsDirectSpaceState3D`](https://docs.godotengine.org/en/stable/classes/class_physicsdirectspacestate3d.html) | Traversal detection uses bounded `intersect_ray()` and contextual `intersect_shape()` calls instead of enumerating all nearby physics bodies. |
| Reusable ray parameters | [Godot `PhysicsRayQueryParameters3D`](https://docs.godotengine.org/en/stable/classes/class_physicsrayqueryparameters3d.html) | A small set of query objects is reused for face, upper, top, and landing probes, with the player RID excluded and collision masks kept explicit. |
| Destination clearance | [Godot `PhysicsShapeQueryParameters3D`](https://docs.godotengine.org/en/stable/classes/class_physicsshapequeryparameters3d.html) | Candidate vault/mantle standing points receive a capsule overlap check only after a viable top or landing is found. |
| Debug geometry | [Godot `ImmediateMesh`](https://docs.godotengine.org/en/stable/classes/class_immediatemesh.html) | Opt-in debug builds can display current probes, normals, and destinations without adding production art assets or release-time query work. |
| Physics process discipline | [Godot physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) | Traversal state transitions and body motion remain in the fixed physics process; camera presentation observes the result without becoming a competing motion owner. |

The project-specific inference is to require explicit `traversal_surface` authoring on stable static geometry, reject invalid/floor/ceiling/tiny/blocked candidates early, and allow exactly one traversal state to own motion. Wall-run duration, climbing distance, chain budget, clearance, and momentum values are game tuning—not copied proprietary traversal data.

## Rendering strategy derived from research

- Start on the Mobile renderer and establish art direction inside real GPU budgets.
- Spend performance first on player silhouette, animation, traversal readability, camera, nearby architecture, and lighting composition.
- Use PBR materials with disciplined texture resolution and shared shader families.
- Build reflection, shadow, weather, traffic, crowd, and interior tiers as independent costs.
- Stream original fictional city cells; never assume an entire dense city remains resident.
- Use Compatibility only if low-tier device evidence justifies the feature trade.

## Free asset-source review

| Source | Licence evidence | Current decision |
|---|---|---|
| [Kenney City Kit (Commercial)](https://kenney.nl/assets/city-kit-commercial) | Product page states CC0 and free download | Suitable as an early proxy candidate; not imported |
| [Kenney City Kit (Roads)](https://kenney.nl/assets/city-kit-roads) | Product page states CC0 and free download | Suitable as an early road proxy candidate; not imported |
| [Poly Haven](https://polyhaven.com/license) | Site states all downloadable HDRIs, textures, and models are CC0 | Strong candidate for specific lighting/material/prop needs; exact items must be logged |
| [ambientCG](https://docs.ambientcg.com/license/) | Site states downloadable assets are CC0 1.0, including commercial use | Strong PBR material candidate; exact items must be logged |
| [Adobe Mixamo](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) | Adobe states characters/animations may be used royalty-free in games | Temporary animation candidate only after current service/redistribution terms are rechecked |
| [OpenStreetMap](https://www.openstreetmap.org/copyright) | ODbL requires attribution and share-alike for adapted database distribution | Not used; an original fictional block plan is cleaner for this universe |

No asset was imported simply because it was searchable or downloadable. `ASSETS.md` is the authoritative usage ledger.

## Deferred research

Research for production character models, final animation sets, city packs, traffic/crowd solutions, audio libraries, and weather systems is deliberately deferred until the traversal prototype defines scale, skeleton, material, performance, and licensing requirements. Collecting attractive assets before those constraints exist would create rework and licence risk.
