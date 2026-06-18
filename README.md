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
2. Press **F5** to run the main scene (`Scenes/Main.tscn`).
3. To run unit tests, open and run `Tests/Scenes/UnitTestRunner.tscn`.
4. To play-test movement in a small sandbox, run `Tests/Scenes/TestRunner.tscn`.
5. For the full combat/health test level, run `Tests/Scenes/Testing.tscn`.

## Input map

Movement and interaction actions are defined in **Project Settings → Input Map**:

- `move_left`, `move_right` — AD / Arrow Keys
- `jump` — W / Space
- `interact` — E
- `pause` — Escape
- `test_damage` — U
- `test_heal` — I
- `test_full_heal` — O
- `test_death` — P

## Version

See [VERSION.md](VERSION.md) for release history. Current version: **0.0.0.0**.

## License

MIT — see [LICENSE](LICENSE).
