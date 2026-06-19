# Third-Party Assets

Track external assets used in ProjectClanker. Update this file before committing any new third-party content.

| Asset | Source | License | Used in | Notes |
|-------|--------|---------|---------|-------|
| Godot default icon (adapted) | Godot Engine | MIT | `Art/Icon.svg` | Placeholder project icon |
| Feminine android idle placeholder | ChatGPT / OpenAI image generation (user prompt) | OpenAI Output / user-owned per OpenAI Terms | `Art/Placeholders/PlayerStates/IDLE.png` | AI-generated placeholder; review/replace before final release |
| Feminine android move placeholder | ChatGPT / OpenAI image generation (user prompt) | OpenAI Output / user-owned per OpenAI Terms | `Art/Placeholders/PlayerStates/MOVE.png` | AI-generated placeholder; review/replace before final release |
| Feminine android jump placeholder | ChatGPT / OpenAI image generation (user prompt) | OpenAI Output / user-owned per OpenAI Terms | `Art/Placeholders/PlayerStates/JUMP.png` | AI-generated placeholder; review/replace before final release |
| Feminine android fall placeholder | ChatGPT / OpenAI image generation (user prompt) | OpenAI Output / user-owned per OpenAI Terms | `Art/Placeholders/PlayerStates/FALL.png` | AI-generated placeholder; review/replace before final release |
| Feminine android attack placeholder | ChatGPT / OpenAI image generation (user prompt) | OpenAI Output / user-owned per OpenAI Terms | `Art/Placeholders/PlayerStates/ATTACK.png` | AI-generated placeholder; review/replace before final release |
| Jump_C_04 | [cabled_mess on Freesound](https://freesound.org/s/350906/) | CC0 | `Audio/jump.ogg` | Player jump SFX |
| Hit Impact | [MadPanCake on Freesound](https://freesound.org/s/660770/) | CC0 | `Audio/impact.ogg` | Player attack SFX |
| male_hurt9 | [micahlg on Freesound](https://freesound.org/s/413186/) | CC0 | `Audio/hurt.ogg` | Player hurt SFX |
| blip | [Ethraiel on Freesound](https://freesound.org/s/351569/) | CC0 | `Audio/blip.ogg` | Door interact + exploration ambience |
| Menu Select | [pumodi on Freesound](https://freesound.org/s/150222/) | CC0 | `Audio/menu_select.ogg` | Exploration ambience one-shot |
| Fire Magic | [qubodup on Freesound](https://freesound.org/s/442872/) | CC0 | `Audio/hit.ogg` | Ending stinger SFX |
| horror ambient factory #3 | [ZHRØ on Freesound](https://freesound.org/s/521232/) | CC0 | `Audio/factory_ambiance1.ogg` | Exploration music |
| Horror ambient factory #2 | [ZHRØ on Freesound](https://freesound.org/s/516895/) | CC0 | `Audio/factory_ambiance2.ogg` | Exploration music |
| Forgotten Circuits | ElevenLabs — Jazhikho | Standard license (all rights reserved) | `Audio/ForgottenCircuits.ogg` | Ending music |
| Protocol of the Clanker | ElevenLabs — Jazhikho | Standard license (all rights reserved) | `Audio/ProtocolOfTheClanker.ogg` | Main menu music |
| Rust and Retribution | ElevenLabs — Jazhikho | Standard license (all rights reserved) | `Audio/RustAndRetribution.ogg` | Boss fight music |

## Adding assets

When importing third-party art, audio, fonts, or code:

1. Record the asset name, source URL, and license here.
2. Add large binaries to `.gitattributes` (or Git LFS) before committing.
3. Prefer assets with licenses compatible with the project MIT license.
