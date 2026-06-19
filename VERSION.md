# Version History

Current version: **0.0.2.0**

## 0.0.2.0 — Audio, menu, and settings (Chunks 10–11)

- Wired `Systems/` modules into game autoloads: `AudioDirector`, `ClankerSettings`, `SceneTransition`.
- Main menu (`Scenes/UI/MainMenu.tscn`) with Start, Settings (music/SFX/mute via `AudioMixControlSystem`), Controls, and Quit.
- Procedural placeholder audio for music, ambience, SFX, boss, and ending cues; Music/SFX buses in `Audio/default_bus_layout.tres`.
- Imported CC0 SFX/ambience (Freesound) and licensed music tracks (`Audio/*.ogg`); see `Docs/Assets.md`.
- Gameplay HUD, pause menu, boss health bar, ending screen, and high-contrast interaction prompts.
- `BossHealthTarget` demo boss in `Tests/Scenes/Testing.tscn` for boss UI/audio verification.

## 0.0.1.0 — Door hub and dialogue (Chunk 4)

- Added `Scenes/Hub/DoorHub.tscn` with D-0R1, locked routes, and primitive placeholder art.
- Resource-based dialogue: `DialogueEntry`, `DialogueSet`, `DialogueRegistry`, and per-phase `Resources/Dialogue/D0R1_*.tres` files.
- `Progression` autoload (`Autoload/ProgressionState.gd`) drives dialogue sets and route unlocks.
- Dialogue advances with **E** via `DialogueBox`; player interact is suppressed during dialogue to prevent restart-on-close.
- Hub debug: **`[`** advances progression for testing.
- Unit tests for dialogue registry, linear advance, and end-of-set finish.

## 0.0.0.0 — Initial project setup

- Created Godot 4 GDScript project scaffold with standard folder layout.
- Added main scene, autoload service, input map, and test runner scene.
