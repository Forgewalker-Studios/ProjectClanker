# ProjectClanker

A GDScript Godot 4 game project scaffolded to follow the project's standard layout and coding conventions.

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
3. To run unit tests, open and run `Tests/Scenes/TestRunner.tscn`.

## Input map

Movement and interaction actions are defined in **Project Settings → Input Map**:

- `move_up`, `move_down`, `move_left`, `move_right` — WASD / arrow keys
- `interact` — E
- `pause` — Escape

## Version

See [VERSION.md](VERSION.md) for release history. Current version: **0.0.0.0**.

## License

MIT — see [LICENSE](LICENSE).
