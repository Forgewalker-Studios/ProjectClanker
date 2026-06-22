# ProjectClanker — The Door Remembers

A short 2D metroidvania-style platformer for a one-week Godot jam. You play a small maintenance robot (**Clanker**) exploring an ashen factory while a sentient door (**D-0R1**) asks for help recovering its memory.

Design docs: [Docs/GDD.md](Docs/GDD.md) · Chunk workflow: [Docs/ChunkWorkflow.md](Docs/ChunkWorkflow.md)

## Requirements

- [Godot Engine 4.4+](https://godotengine.org/download)

## Project layout

| Folder | Purpose |
|--------|---------|
| `Scenes/` | Game and UI scenes (`.tscn`) |
| `Scripts/` | Gameplay scripts |
| `Autoload/` | Global singleton services |
| `Resources/` | Tunable data assets (`.tres`) |
| `Shaders/` | Shader assets |
| `Audio/` | Audio buses and source files |
| `Art/` | Models, textures, and materials |
| `Tests/` | Test scenes and scripts |
| `Docs/` | Design docs and asset tracking |

## Getting started

1. Open the project folder in Godot 4.4+.
2. Press **F5** to run the main scene (`Scenes/UI/MainMenu.tscn`).
3. To run unit tests, open and run `Tests/Scenes/UnitTestRunner.tscn`.
4. To play-test movement in a small sandbox, run `Tests/Scenes/TestRunner.tscn`.
5. For the full combat/health test level, run `Tests/Scenes/Testing.tscn`.
6. For the door hub and dialogue chunk, run `Scenes/Hub/DoorHub.tscn`.

## Hub and dialogue (Chunk 4)

See [Docs/ChunkWorkflow.md](Docs/ChunkWorkflow.md) § *Chunk 4 — Door Hub and Dialogue* for architecture, route unlock table, and acceptance verification.

**Quick test:** F6 → `Scenes/Hub/DoorHub.tscn` → **E** at D-0R1 → **E** through lines until the panel closes → **`[`** to advance story phase for route/dialogue checks.

## Input map

Movement and interaction actions are defined in **Project Settings → Input Map**:

- `move_left`, `move_right` — AD / Arrow Keys
- `jump` — W / Space
- `interact` — E
- `melee_attack` — J
- `pause` — Escape
- `test_damage` — U
- `test_heal` — I
- `test_full_heal` — O
- `test_death` — P
- `debug_advance_state` — `[` (hub debug: advance `Progression` one phase)

## Version

See [VERSION.md](VERSION.md) for release history. Current version: **0.0.8.0**.

## Credits

- A ForgeWalker Studios Production
- Produced by Jazhikho
- Written and Directed by KennyLumpia
- Detailed art, UI, music, sound, license, and AI-assistance credits are available in the in-game Credits panel.
- Full third-party source URLs, modification notes, and unresolved provenance: [Docs/Assets.md](Docs/Assets.md)

## Systems integration

Reusable modules live in `Systems/`. Game glue autoloads:

| Autoload | Systems used |
|----------|----------------|
| `AudioDirector` | `AudioJukeboxSystem`, `RandomCueSchedulerSystem` |
| `ClankerSettings` | `SettingsPersistenceSystem`, `JsonFileStoreSystem` |
| `SceneTransition` | `SceneFadeTransitionSystem` |

Menu settings UI uses `AudioMixControlSystem` via `Scripts/MainMenu.gd`.

## License

MIT — see [LICENSE](LICENSE).
