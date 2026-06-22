# Version History

Current version: **0.0.7.2**

## 0.0.7.2 - Non-blocking hub route triggers

- Converted all hub route roots from static bodies to area triggers.
- Locked routes no longer physically block travel across the hub floor.
- Unlocked routes monitor player entry and transition through the shared portal behavior.
- Added regression coverage ensuring every route has a zero collision layer.

## 0.0.7.1 - Dialogue completion input fix

- Prevented the final dialogue E press from immediately restarting D0R1 interaction.
- Ignored keyboard auto-repeat events while advancing dialogue.
- Added regression coverage for the dialogue interaction release latch.

## 0.0.7.0 - Hub presentation and grounded routes

- Added the level parallax and gradient background system to the hub.
- Grounded all four hub routes and moved the player spawn clear of portals.
- Separated and styled the health and progression overlays for readability.
- Removed redundant persistent control hints and hid interaction prompts during dialogue.
- Added regression coverage for grounded routes and separated HUD placement.

## 0.0.6.0 - Main menu UI polish

- Added a dark industrial menu theme with cyan and amber accents.
- Added a framed menu card, consistent button states, spacing, and keyboard focus.
- Made Settings, Controls, and Credits true opaque modals with background dimming.
- Added Escape-to-close behavior and regression coverage for modal readability.

## 0.0.5.0 - Playable route and Windows export

- Wired all hub routes and authored `MoveTo*` areas through reusable scene portals.
- Added forward-only area progression and final-dialogue completion behavior.
- Made the final ending overlay return to the hub view on interact.
- Added a Windows Desktop release export preset.
- Excluded macOS resource-fork metadata from Godot imports.
- Added regression coverage for portal targets and export configuration.

## 0.0.4.2 - Production credits

- Added player-visible production credits to the main menu.
- Documented production credits and linked third-party asset attribution in the README.

## 0.0.4.1 - Enemy pursuit and ledge safety

- Reduced ground and flying pursuit acquisition and leash ranges.
- Added a forward floor probe so grounded patrol and charge enemies stop at platform edges.
- Added regression coverage for bounded pursuit ranges and repaired the player test fixture.
- Assigned Region 02 a unique scene UID.
- Restored the missing D0R1 hub actor and fixed its dialogue binding.

## 0.0.4.0 — Enemy archetypes and prefab scenes

- Added `EnemyConfig` resource and per-type configs under `Resources/Enemies/`.
- Added `EnemyBase` with contact hurtbox, attack hitbox, line-of-sight ray, and composable behavior scripts.
- Implemented six enemy behaviors: roaming patrol, pursuing charge, flying fixed, flying pursuit, latched projectile, and boss.
- Added prefab scenes under `Scenes/Enemies/` for each enemy type plus `EnemyProjectile.tscn`.
- Unit tests cover enemy config load, damage, and boss-style invulnerability.

## 0.0.3.0 — Silhouette art and Level1 paint scene

- Added boss, enemy, and D-0R1 silhouette sprite sheets (`Assets/baddies.png`, `Assets/dori.png`).
- Imported industrial platform-builder, parallax, UI, and sci-fi music asset packs under `Assets/`.
- Generated environment silhouettes, paint atlas, and parallax midground cutout in `Art/Environment/`.
- Added `Scenes/Level1.tscn` with 10:3 paint grid, gradient sky, and parallax midground.
- Added art generation and TileSet build tools under `Tools/`.

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
