# Asset ledger

Last reviewed: 2026-08-18

Every imported visual, animation, audio, map, font, or code-bearing asset must be recorded here before it enters a milestone build. “Downloadable” is not a licence. Source files with unclear ownership are rejected.

## Assets used in Milestone 0

| Asset name | Source | Creator | Licence | Attribution requirements | Cost | Where it is used | Modified |
|---|---|---|---|---|---|---|---|
| Relay application icon | [`game/art/ui/app_icon.svg`](game/art/ui/app_icon.svg) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | Android launcher and project icon | No; authored for this project |
| Procedural city blockout meshes and materials | [`procedural_city_blockout.gd`](game/scripts/world/procedural_city_blockout.gd) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | Milestone 0 test ground, roads, towers, facade accents, beacons | Generated at runtime from original code |
| Relay blockout avatar | [`relay_avatar.tscn`](game/scenes/player/relay_avatar.tscn) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | Temporary player collision/visual silhouette | Built from Godot primitives; not a final model |
| Godot Engine Android runtime and export template | [Godot 4.6.3](https://godotengine.org/article/maintenance-release-godot-4-6-3/) | Godot Engine contributors | MIT, with separately licensed bundled third-party components | Preserve applicable copyright and licence notices; see `THIRD_PARTY_NOTICES.md` | Free | Engine runtime inside the APK, Android template resources, fallback adaptive-icon background | Project data packaged into the unmodified official debug template |

No third-party city model, character, texture, animation, sound, map, or commercial marketplace asset is used in Milestone 0.

## Assets used in Milestone 1

| Asset name | Source | Creator | Licence | Attribution requirements | Cost | Where it is used | Modified |
|---|---|---|---|---|---|---|---|
| Movement traversal laboratory | [`movement_traversal_lab.gd`](game/scripts/world/movement_traversal_lab.gd) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | M1 flat lanes, alleys, ramps, stairs, rooftops, walls, gaps, narrow platforms, pipes, collision bays | Generated at runtime from original code and Godot primitives |
| Movement and camera tuning resources | [`game/data/movement/`](game/data/movement/) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | M1 player and camera configuration | Authored for M1; data-only resources |
| Godot Engine Android runtime and export template, M1 package | [Godot 4.6.3](https://godotengine.org/article/maintenance-release-godot-4-6-3/) | Godot Engine contributors | MIT, with separately licensed bundled third-party components | Preserve applicable copyright and licence notices; see `THIRD_PARTY_NOTICES.md` | Free | Engine runtime inside the M1 APK | Project data packaged into the unmodified official debug template |

Milestone 1 imports no third-party model, texture, material, animation, sound, map, logo, or marketplace pack. The M0 original icon and primitive Relay blockout remain in use unchanged.

## Assets used in Milestone 2

| Asset name | Source | Creator | Licence | Attribution requirements | Cost | Where it is used | Modified |
|---|---|---|---|---|---|---|---|
| Parkour test laboratory expansion | [`movement_traversal_lab.gd`](game/scripts/world/movement_traversal_lab.gd) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | M2 wall-run lanes, vertical routes, vault/mantle/ledge stations, parallel walls, blocked cases, invalid surfaces, and chained route | Generated at runtime from original code and Godot primitives |
| Traversal system and tuning data | [`game/scripts/traversal/`](game/scripts/traversal/) and [`game/data/traversal/`](game/data/traversal/) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | Surface detection, traversal states/actions, debug visualization, and centralized M2 tuning | Authored for M2; code and data resources |
| Procedural traversal presentation | [`parkour_traversal.gd`](game/scripts/traversal/parkour_traversal.gd) | Aerial Vanguard project | Original project work; no third-party asset | None | Free/in-house | Temporary lean/pose feedback on the primitive hero during traversal actions | Original procedural transforms; no copied or imported animation |
| Godot Engine Android runtime and export template, M2 package | [Godot 4.6.3](https://godotengine.org/article/maintenance-release-godot-4-6-3/) | Godot Engine contributors | MIT, with separately licensed bundled third-party components | Preserve applicable copyright and licence notices; see `THIRD_PARTY_NOTICES.md` | Free | Engine runtime inside the M2 APK | Project data packaged into the unmodified official debug template |

Milestone 2 imports no third-party model, texture, material, animation, sound, map, logo, code pack, or marketplace asset. All traversal behavior, test geometry, state data, and temporary presentation are original project work.

## Free candidates researched but not imported

These are candidates, not approvals. Record the exact asset/download/version and recheck its page on the import date.

| Asset name | Source | Creator | Licence | Attribution requirements | Cost | Where it may be used | Modified |
|---|---|---|---|---|---|---|---|
| City Kit (Commercial) | [Kenney](https://kenney.nl/assets/city-kit-commercial) | Kenney | CC0 | None required; credit appreciated | Free | Early modular city proxy set | Not used |
| City Kit (Roads) | [Kenney](https://kenney.nl/assets/city-kit-roads) | Kenney | CC0 | None required; credit appreciated | Free | Early roads, signs, and traffic-light proxies | Not used |
| Selected HDRIs, textures, or models | [Poly Haven licence](https://polyhaven.com/license) | Poly Haven staff and contributing artists | CC0 | None required; credit appreciated | Free | Lighting reference, material prototypes, rooftop props | Not used; exact assets not selected |
| Selected PBR materials | [ambientCG licence](https://docs.ambientcg.com/license/) | ambientCG | CC0 1.0 | None required; credit appreciated | Free | Asphalt, concrete, metal, roofing prototypes | Not used; exact assets not selected |
| Selected humanoid animations | [Adobe Mixamo FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html) | Adobe/Mixamo | Adobe's stated royalty-free use for video games; service terms still apply | Recheck current terms and raw-file redistribution rules before import | Free with Adobe ID | Temporary animation retargeting tests only | Not used |

## Sources considered and rejected for now

| Source | Decision | Reason |
|---|---|---|
| Ripped assets, extracted maps, fan recreations, or uploads with unknown provenance | Permanently prohibited | Copyright, trademark, quality, and chain-of-title risk |
| OpenStreetMap city data | Not used | ODbL attribution/share-alike obligations need a deliberate data pipeline and legal review; a fictional procedural city better protects the original setting at this stage |
| Marketplace downloads without an explicit commercial-game licence | Rejected | Availability does not grant redistribution or release rights |

## Import checklist

1. Save the exact product URL, creator, licence name/version, price paid, and acquisition date.
2. Store a copy or screenshot of the licence terms with production records when allowed.
3. Confirm commercial game use, modification rights, platform use, and whether cooked redistribution is permitted.
4. Scan for trademarked logos, real brands, copied architecture, or third-party material bundled by the uploader.
5. Add the asset to this ledger before committing it.
6. Record every material change and the final in-game locations.
