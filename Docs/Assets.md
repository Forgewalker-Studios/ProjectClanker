# Asset Credits and Provenance

This register covers third-party, commissioned, user-provided, and AI-assisted assets bundled with ProjectClanker. Source pages were checked on 2026-06-22. AI-assisted research is not a licensing judgment; a human release owner must approve the final credits and distribution rights.

The Windows export currently uses `export_filter="all_resources"`. Consequently, source packs under `Assets/` may be distributed even when no scene references them.

## Release review required

- **2D Sci-Fi Industrial Platform Builder:** The downloaded pack contains no license file, and its itch.io page does not state a license. The pack is credited to LeavarioxStudios, but distribution rights must be confirmed before release.
- **Industrial Parallax Background:** The bundled `public-license.pdf` states CC0, while the current itch.io page labels the asset CC BY 4.0 and also says attribution is not required. Treat the current CC BY 4.0 label as the conservative requirement until a human resolves the conflict.
- **Undocumented loose images:** `Assets/baddies1.png`, `Assets/d041f27d-f01e-4b22-b3fc-bd696f54787f.png`, and `Assets/d60698a5-8b36-42f0-9a32-fb9620dd6f0b.png` have no recorded creator, source, or license. Confirm ownership or exclude them from the release export.
- **AI-assisted material:** Human review must confirm that the listed input materials, tool terms, and final outputs are acceptable for release.

## Art and UI

| Asset | Creator/source | License status | Project use and modifications |
|-------|----------------|----------------|-------------------------------|
| 2D Sci-Fi Industrial Platform Builder | [LeavarioxStudios](https://leavarioxstudios.itch.io/2d-sci-fi-industrial-platform-builder) | **Not supplied; verify before release** | Source pack under `Assets/2d-sci-fi-industrial-platform-builder/`; environment tiles and props were converted to silhouettes under `Art/Environment/Silhouettes/` and assembled into `Art/Environment/LevelPaintAtlas.png`. |
| Industrial Parallax Background | [Luis Zuno / Ansimuz](https://ansimuz.itch.io/industrial-parallax-background) | Conflicting metadata: bundled PDF says CC0; current page says CC BY 4.0 | Source layers and Industrial Theme music under `Assets/industrial-parallax-background/`; `bg.png` was recolored/remapped into `Art/Environment/Parallax/BgLevelPaint.png`. |
| Complete UI Essential Pack | [Crusenho Agus Hennihuno / Crusenho](https://crusenho.itch.io/complete-ui-essential-pack) | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) | UI source sprites under `Assets/complete-ui-essential-pack/`; project menus and HUD use an adapted visual treatment. Credit and modification notice are required. |
| Godot default icon | [Godot Engine contributors](https://godotengine.org/) | MIT | Adapted as `Art/Icon.svg`. |
| Midground industrial silhouettes | User-provided project art | Project-owned claim; human confirmation required | `Assets/midground.png`; processed into `Art/Environment/Parallax/MidgroundLevel.png`. |
| Boss and enemy sprite sheet | AI-assisted procedural generation using Cursor | Project-owned claim; human confirmation required | `Assets/baddies.png`; 64x64 silhouette grid for enemies, bosses, and effects. |
| D-0R1 expression sheet | AI-assisted procedural generation using Cursor | Project-owned claim; human confirmation required | `Assets/dori.png`; 128x128 expression grid used by `Scenes/Dori.tscn`. |
| Player and enemy placeholder state art | OpenAI image generation from user prompts | Project records describe output as user-owned under applicable OpenAI terms; human confirmation required | `Art/Placeholders/PlayerStates/` and `Art/Placeholders/EnemyStates/`; generated placeholders, some subsequently edited. |
| Loose image sources | Creator/source not documented | **Unknown; verify or exclude before release** | `Assets/baddies1.png`, its Krita autosave, and the two UUID-named PNG files. No runtime references were found, but `all_resources` may still package recognized resources. |

## Music

| Asset | Creator/source | License status | Project use |
|-------|----------------|----------------|-------------|
| Forgotten Circuits | Created with ElevenLabs by Jazhikho | Project-controlled claim; human confirmation required | `Audio/ForgottenCircuits.ogg`; ending music. |
| Protocol of the Clanker | Created with ElevenLabs by Jazhikho | Project-controlled claim; human confirmation required | `Audio/ProtocolOfTheClanker.ogg`; main-menu music. |
| Rust and Retribution | Created with ElevenLabs by Jazhikho | Project-controlled claim; human confirmation required | `Audio/RustAndRetribution.ogg`; boss music. |
| Sci-Fi Music Pack Vol. 1 | [Talon Trueblood](https://talontrueblood.itch.io/sci-fi-music-pack-vol1) | Commercial use permitted with required credit: **Music: Talon Trueblood** | Ten OGG tracks under `Assets/sci-fi-music-pack-vol1/`; bundled but not currently referenced by scenes. |
| Industrial Theme | [Luis Zuno / Ansimuz](https://ansimuz.itch.io/industrial-parallax-background) | Same conflicting pack metadata described above | MP3, OGG, and WAV copies under the parallax source pack; bundled but not currently referenced by scenes. |
| horror ambient factory #3 | [ZHRØ on Freesound](https://freesound.org/s/521232/) | CC0 | `Audio/factory_ambiance1.ogg`; exploration ambience. |
| Horror ambient factory #2 | [ZHRØ on Freesound](https://freesound.org/s/516895/) | CC0 | `Audio/factory_ambiance2.ogg`; exploration ambience. |

Bundled Talon Trueblood tracks: Tears of Oil; We the Machines; Discourse Between 1 and 0; Bit Rate Pawns; Breaking Beat; Through; Bolted Lug Nuts; Sick Pump; Static Abyss; and Frameworks.

## Sound Effects

| Asset | Creator/source | License | Project use |
|-------|----------------|---------|-------------|
| Jump_C_04 | [cabled_mess on Freesound](https://freesound.org/s/350906/) | CC0 | `Audio/jump.ogg`; player jump. |
| Hit Impact | [MadPanCake on Freesound](https://freesound.org/s/660770/) | CC0 | `Audio/impact.ogg`; player attack. |
| male_hurt9 | [micahlg on Freesound](https://freesound.org/s/413186/) | CC0 | `Audio/hurt.ogg`; player damage. |
| blip | [Ethraiel on Freesound](https://freesound.org/s/351569/) | CC0 | `Audio/blip.ogg`; D-0R1 interaction. |
| Menu Select | [pumodi on Freesound](https://freesound.org/s/150222/) | CC0 | `Audio/menu_select.ogg`; menu/exploration cue. |
| Fire Magic | [qubodup on Freesound](https://freesound.org/s/442872/) | CC0 | `Audio/hit.ogg`; hit/ending cue. |

## Bundled license files

- UI pack: `Assets/complete-ui-essential-pack/Complete_UI_Essential_Pack_Free/License.txt`
- Parallax pack: `Assets/industrial-parallax-background/parallax-industrial-web/public-license.pdf`
- Sci-Fi music pack: `Assets/sci-fi-music-pack-vol1/Sci-Fi Music Pack/Read Me.txt`

## Adding assets

Before committing external art, audio, fonts, or code:

1. Record the exact asset name, creator, source URL, license, and local path here.
2. Preserve the original license or receipt alongside the source asset when redistribution permits it.
3. Record transformations and whether the asset is referenced at runtime or merely bundled by the export preset.
4. Add large binaries to `.gitattributes` or Git LFS before committing.
5. Require human approval for licensing, cultural representation, factual claims, and final release decisions.
