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
