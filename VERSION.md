# Version History

Current version: **0.0.1.0**

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
