# Systems folder — reference

This folder holds **reusable, game-agnostic** GDScript modules. In **this** repo they are **not wired** into the shipped Spud-gotchi game by default; the live game uses `Scripts/`. Copy or reference these when starting a new project or jam repo.

**Engine:** Godot 4.x (GDScript), same major version as this project.

**Related:** See `GAME_JAM_SEED.md` (repo root or copy in `Systems/`) for `Systems/` vs `Scripts/` rules.

---

## Validation (smoke / integration)

New or changed reusable systems **do not** require an in-repo demo scene or automated smoke test in this repository.

**Instead:** validate them when you **use them in a new game or jam project** — hook the system into real gameplay or a minimal harness there, run through export if relevant, and fix issues before treating the module as stable.

Optional: add project-level tests under `Tests/` when a system gains critical math or serialization logic.

---

## Extending vs adding a new system

When you need behavior that is *similar* to an existing system:

1. **Decide deliberately:** Is this a **narrow extension** of one module’s contract, or a **different responsibility** that happens to overlap?
2. **Default when in doubt:** Add a **new** system (even if it duplicates some helpers). Duplication is cheaper than the wrong abstraction across games.
3. **Document the choice** in this README: add a **“Choosing … vs …”** note under each affected system so future-you and agents know which to pick.

Avoid ballooning a single system into a grab-bag (e.g. one “save” type that handles slots, offline sim, and cloud sync). Prefer separate modules and glue in `Scripts/`.

### Example (hypothetical future)

| Need | Use |
|------|-----|
| Stat-shaped payload, offline elapsed drain, single save path | `OfflineSaveSystem` |
| Multiple named slots, no real-time offline simulation, arbitrary blob per slot | A future **`SlotSaveSystem`** (or similar) — **not** a subclass of `OfflineSaveSystem` unless the API stays coherent |

If both exist, this table should be expanded with real class names and paths.

---

## `_SYSTEM_REGISTRY.md` vs this file

- **`Systems/_SYSTEM_REGISTRY.md`** (optional, per `GAME_JAM_SEED.md`): short index — status, last used in, links. Lightweight for “what exists?”
- **`Systems/README.md` (this file):** full API summary, dependencies, and **when to use which** overlaps.

Maintain both if you use the registry pattern; at minimum keep **this** file updated when systems change.

---

## AudioJukeboxSystem

| | |
|---|---|
| **File** | `AudioJukeboxSystem.gd` |
| **Type** | `class_name AudioJukeboxSystem` · `extends Node` |
| **Purpose** | Random playlist playback with an internal `AudioStreamPlayer`; optional immediate-repeat avoidance between tracks. |
| **Does not** | Sync to gameplay beats, crossfade, or own asset loading beyond the array you pass in. |

**Public API**

- `configure(bus_name, volume_db, process_mode)` — default bus `Music`, default `process_mode` `PROCESS_MODE_ALWAYS` (keeps playing when tree is paused unless you change it). If `bus_name` is missing, falls back to `Master`.
- `start_with_tracks(streams: Array)` — filters to `AudioStream`; uses deferred start + sequence token so rapid restarts do not leave stale plays.
- `stop()` — invalidates pending deferred plays and clears the playlist.

**Dependencies:** Godot `AudioServer`, `AudioStreamPlayer`.

**Setup:** Add node to scene, call `configure()`, then `start_with_tracks()` with your streams.

**ProjectClanker:** Wired via `Autoload/AudioDirector.gd` for menu, exploration, boss, and ending playlists.

---

## AudioMixControlSystem

| | |
|---|---|
| **File** | `AudioMixControlSystem.gd` |
| **Type** | `class_name AudioMixControlSystem` · `extends Control` |
| **Purpose** | **UI glue:** two `Range` sliders (music / SFX) and a master mute button; writes linear volume to named buses. |
| **Does not** | Persist settings, localize button labels, or discover UI nodes automatically. |

**Public API**

- `setup(music_slider, sfx_slider, mute_button, music_bus_name, sfx_bus_name, master_bus_name)` — disconnects previous controls if `setup` runs again; connects signals once; reads current bus volumes and mute state instead of forcing 100%. Clamps written linear volume to 0..1.

**Dependencies:** Project must define buses (e.g. `Music`, `SFX`, `Master`) in `default_bus_layout` or equivalent.

**Setup:** Build UI with two sliders and a button; pass nodes into `setup()`. Override mute button text externally if you need localization.

**ProjectClanker:** Wired in `Scripts/MainMenu.gd` settings panel; volumes persist through `ClankerSettings`.

---

## DialogueContentSystem

| | |
|---|---|
| **File** | `DialogueContentSystem.gd` |
| **Type** | `class_name DialogueContentSystem` · `extends RefCounted` |
| **Purpose** | **Data-only** dialogue / random line pools from JSON or an in-memory dictionary; optional Yes/No question packs with timings. |
| **Does not** | Show UI, run tweens, or branch gameplay. |

**Public API**

- `load_from_json_file(path)` / `create_from_dictionary(data)`
- `pick_line_with_timing(category_key, rng)` → `{ "text", "seconds" }`
- `get_display_seconds`, `get_reply_display_seconds`, `get_question_hold_seconds`
- `has_question_items(category_key)`
- `pick_question_pack(category_key, rng, avoid_item_index = -1)` → includes `valid_item_index` (filtered list), `source_item_index` (original JSON array index), plus `question` / `yes` / `no` and timing fields. Invalid line/item entries are filtered out before random pick.

**Schema:** See the block comment at the top of `DialogueContentSystem.gd` for a concrete JSON example.

**Dependencies:** None beyond `FileAccess` / `JSON` for file load.

---

## TimedDialoguePresenterSystem

| | |
|---|---|
| **File** | `TimedDialoguePresenterSystem.gd` |
| **Type** | `class_name TimedDialoguePresenterSystem` · `extends Node` |
| **Purpose** | **Presentation:** fade in/out on a `PanelContainer`, timed plain text, optional Yes/No flow with follow-up lines. |
| **Does not** | Load dialogue data; identify which question is active beyond what the caller tracks. |

**Signals**

- `dialogue_hidden` — after a full hide sequence, or immediately from `hide_immediate()`.
- `yes_no_choice_made(picked_yes: bool)` — only the boolean; **caller must track question/context.**

**Public API**

- `setup(panel, label, question_row, yes_button, no_button)`
- `show_line(text, hold_seconds)` — negative holds clamped to 0.
- `show_yes_no(question, yes_reply, no_reply, question_hold_seconds, reply_hold_seconds)`
- `hide_immediate()` — cancels tweens and handlers; emits `dialogue_hidden`.

**Dependencies:** Caller-supplied Control tree; uses `Tween` and `create_timer`.

**Pairing:** Use with `DialogueContentSystem` in glue code: content picks strings/timings, presenter shows them.

---

## StatSimulationSystem

| | |
|---|---|
| **File** | `StatSimulationSystem.gd` |
| **Type** | `class_name StatSimulationSystem` · `extends RefCounted` |
| **Purpose** | Pure numeric stat state: named values, per-stat max, passive drain from a rate profile, deltas, clamps. |
| **Does not** | Decide win/loss, fire signals, or touch nodes. |

**Nested types**

- `StatState` — `values` / `max_values` dictionaries (String keys). **Missing current value defaults to max; missing max defaults to 100.**
- `DrainProfile` — `rates_per_second` dictionary; lookup uses the **original** dictionary key variant for rates.

**Public API (static)**

- `apply_passive_drain(state, profile, delta_sec)` — no-op if `delta_sec <= 0`
- `apply_stat_delta`, `set_stat_value_clamped`, `get_stat_value`, `get_max_value`
- `rate_from_percent_interval(max_value, percent, interval_seconds)`
- `any_empty(state, stat_keys)`

**Dependencies:** None.

---

## OfflineSaveSystem

| | |
|---|---|
| **File** | `OfflineSaveSystem.gd` |
| **Type** | `class_name OfflineSaveSystem` · `extends RefCounted` |
| **Purpose** | **Stat-focused** JSON save/load/delete under `user://` (or any path you pass); optional **offline elapsed** application via `StatSimulationSystem.apply_passive_drain`. Not a full RPG/world save framework. |
| **Does not** | Migrations beyond storing `version`; complex entity graphs belong in `metadata` at your own risk. |

**Nested type**

- `SavePayload` — `version`, `saved_unix`, `stats`, `max_stats`, `metadata`, `flags`

**Public API (static)**

- `load_or_fallback(save_path, fallback_payload)`
- `write_payload(save_path, payload)` — ensures parent directory exists when possible; refreshes `saved_unix`
- `apply_offline_drain(payload, drain_profile)` — advances `saved_unix` after simulating so elapsed time is not double-applied
- `delete_save(save_path)`

**Dependencies:** `StatSimulationSystem` for offline drain.

**Choosing persistence (future overlaps)**

| Scenario | Prefer |
|----------|--------|
| Idle/virtual-pet style stats + offline time drift | `OfflineSaveSystem` |
| Named slots, profiles, or unrelated blobs per slot **without** offline drain as part of the module | A **separate** slot-oriented save system — document it here when added |

---

## PhaseTickSystem

| | |
|---|---|
| **File** | `PhaseTickSystem.gd` |
| **Type** | `class_name PhaseTickSystem` · `extends Node` |
| **Purpose** | Deterministic **phase-ordered** callbacks (`pre_sim`, `sim`, `post_sim`, `presentation` by default); duplicate callback registration is ignored; iteration uses a snapshot of callbacks per phase. |
| **Does not** | Auto-run; glue must call `run_tick(delta_sec)` from `_process` or `_physics_process`. |

**Public API**

- `register_callback(phase, callback)` — warns if phase not in order; skips duplicate `Callable`
- `unregister_callback(phase, callback)`
- `set_phase_order(order)` — **deduplicates** phases; warns on duplicates in input
- `run_tick(delta_sec)`

**Dependencies:** None.

---

## Quick dependency graph

```text
DialogueContentSystem (data)
        ↑
        │ strings / timings
TimedDialoguePresenterSystem (view)

StatSimulationSystem (sim)
        ↑
        │ offline drain
OfflineSaveSystem (persistence)

AudioJukeboxSystem (audio playback)
AudioMixControlSystem (audio UI glue)
InventoryStateSystem (inventory state)

PhaseTickSystem (scheduler — optional glue)
```

---

## InventoryStateSystem

| | |
|---|---|
| **File** | `InventoryStateSystem.gd` |
| **Type** | `class_name InventoryStateSystem` · `extends RefCounted` |
| **Purpose** | Pure reusable inventory state (item IDs, capacity limit, duplicate policy, import/export). |
| **Does not** | Apply item effects, trigger game events, own save files, or control UI. |

**Use when:** a project needs simple inventory ownership checks and state operations without game-specific glue.

**Do not use when:** inventory behavior is tightly coupled to game-specific categories/effects/story progression.

**Owned state**

- Internal item list (`Array[String]`)
- Capacity (`max_items`, `-1` = unlimited)
- Duplicate policy (`ALLOW` or `REJECT`)

**Caller responsibilities**

- Provide valid item IDs.
- Handle UI updates, audio, and game events.
- Persist state using save systems.
- Apply game-specific item effects or category logic.

**Public API summary**

- `add_item(item_id, count = 1) -> bool`
- `remove_item(item_id, count = 1) -> bool`
- `has_item(item_id, count = 1) -> bool`
- `get_item_count(item_id) -> int`
- `get_items() -> Array[String]`
- `get_unique_items() -> Array[String]`
- `is_full() -> bool`
- `clear() -> void`
- `size() -> int`
- `export_state() -> Dictionary`
- `import_state(state: Dictionary) -> void`

**Example usage**

```gdscript
var inventory_state: InventoryStateSystem = InventoryStateSystem.new(20, InventoryStateSystem.DuplicatePolicy.REJECT)
inventory_state.add_item("flashlight")
if inventory_state.has_item("flashlight"):
	print("Player owns flashlight")
var snapshot: Dictionary = inventory_state.export_state()
```

**Current Project Harvest migration status**

Created but not wired into Project Harvest yet.  
Project Harvest still uses `scripts/systems/PlayerInventory.gd`.  
Future migration requires explicit approval and must preserve the characterization tests.

---

## CatalogLookupSystem

| | |
|---|---|
| **File** | `CatalogLookupSystem.gd` |
| **Type** | `class_name CatalogLookupSystem` · `extends RefCounted` |
| **Purpose** | ID-keyed catalog registration and lookup with optional category/tag queries. |
| **Does not** | Spawn scenes, apply effects, emit project events, or own save behavior. |

**API summary:** `register_entry`, `register_entries`, `get_entry`, `has_id`, `get_ids`, `get_entries_by_category`, `get_entries_by_tag`, `export_state`, `import_state`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## WeightedSelectionSystem

| | |
|---|---|
| **File** | `WeightedSelectionSystem.gd` |
| **Type** | `class_name WeightedSelectionSystem` · `extends RefCounted` |
| **Purpose** | Deterministic weighted random selection with optional filter and repeat-avoidance. |
| **Does not** | Own game spawn rules, scene instantiation, or content semantics. |

**API summary:** `set_entries`, `add_entry`, `pick`, `get_last_selected_id`, `list_entries`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## SettingsPersistenceSystem

| | |
|---|---|
| **File** | `SettingsPersistenceSystem.gd` |
| **Type** | `class_name SettingsPersistenceSystem` · `extends RefCounted` |
| **Purpose** | Default/current settings dictionary storage with get/set/reset/import/export. |
| **Does not** | Apply values to InputMap, AudioServer, rendering APIs, or UI controls. |

**API summary:** `configure_defaults`, `get_value`, `set_value`, `reset_to_defaults`, `export_state`, `import_state`.

**ProjectClanker:** Wired via `Autoload/ClankerSettings.gd` with `JsonFileStoreSystem` persistence.

**Migration status:** Wired into ProjectClanker audio settings glue.

---

## JsonFileStoreSystem

| | |
|---|---|
| **File** | `JsonFileStoreSystem.gd` |
| **Type** | `class_name JsonFileStoreSystem` · `extends RefCounted` |
| **Purpose** | Generic JSON dictionary read/write/delete and optional backup/restore helpers. |
| **Does not** | Own game-specific schema or migration rules. |

**API summary:** `exists`, `write_dictionary`, `read_dictionary`, `delete`, `backup`, `restore`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## ThresholdStateSystem

| | |
|---|---|
| **File** | `ThresholdStateSystem.gd` |
| **Type** | `class_name ThresholdStateSystem` · `extends RefCounted` |
| **Purpose** | Generic threshold band + crossing detection for numeric values. |
| **Does not** | Trigger gameplay/audio/UI consequences directly. |

**API summary:** `configure_thresholds`, `evaluate`, `get_current_band`, `reset`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## InteractionTargetSystem

| | |
|---|---|
| **File** | `InteractionTargetSystem.gd` |
| **Type** | `class_name InteractionTargetSystem` · `extends RefCounted` |
| **Purpose** | Reusable focus/nearby target resolution and optional generic interact dispatch. |
| **Does not** | Know project-specific item/puzzle/backpack routing or UI/event semantics. |

**API summary:** `set_focus_target`, `register_nearby_target`, `resolve_target`, `resolve_prompt`, `dispatch_interact`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## ItemPlacementPuzzleSystem

| | |
|---|---|
| **File** | `ItemPlacementPuzzleSystem.gd` |
| **Type** | `class_name ItemPlacementPuzzleSystem` · `extends RefCounted` |
| **Purpose** | Pure rules for required-item placement, duplicate rejection, wrong-attempt tracking, completion. |
| **Does not** | Own puzzle UI, rewards, scene flow, save calls, or narrative behavior. |

**API summary:** `configure_required_items`, `configure_target_requirements`, `place_item`, `is_completed`, `export_state`, `import_state`, `reset_state`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## TimedMessageQueueSystem

| | |
|---|---|
| **File** | `TimedMessageQueueSystem.gd` |
| **Type** | `class_name TimedMessageQueueSystem` · `extends RefCounted` |
| **Purpose** | Queue/state helper for timed messages separate from UI presenter logic. |
| **Does not** | Own controls, tweens, or project-specific message triggers. |

**API summary:** `enqueue`, `advance`, `skip_current`, `clear`, `apply_tokens`, `export_state`, `import_state`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## SceneFadeTransitionSystem

| | |
|---|---|
| **File** | `SceneFadeTransitionSystem.gd` |
| **Type** | `class_name SceneFadeTransitionSystem` · `extends RefCounted` |
| **Purpose** | Generic transition phase sequencing (`fade_out -> scene_change -> fade_in -> finished`). |
| **Does not** | Hardcode scene paths or directly run project-specific scene managers. |

**API summary:** `request_transition`, `next_step`, `cancel`, `get_state`, `get_request`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## EnvironmentPhasePresenterSystem

| | |
|---|---|
| **File** | `EnvironmentPhasePresenterSystem.gd` |
| **Type** | `class_name EnvironmentPhasePresenterSystem` · `extends RefCounted` |
| **Purpose** | Interpolate float/color presentation values over normalized progress by phase. |
| **Does not** | Own game time simulation or direct node application logic. |

**API summary:** `configure_phases`, `has_phase`, `get_phase_value`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## RandomCueSchedulerSystem

| | |
|---|---|
| **File** | `RandomCueSchedulerSystem.gd` |
| **Type** | `class_name RandomCueSchedulerSystem` · `extends RefCounted` |
| **Purpose** | Random cue selection and delay scheduling with deterministic RNG support. |
| **Does not** | Play audio or own project-specific threshold/semantic logic. |

**API summary:** `set_cues`, `select_next_cue`, `next_delay_seconds`, `get_last_cue_id`, `list_cues`.

**Migration status:** Created and tested. Not wired into Project Harvest production code.

---

## Maintenance

When you add or change a system:

1. Update **this file** (`Systems/README.md`).
2. Optionally mirror short entries in `Systems/_SYSTEM_REGISTRY.md`.
3. Keep game-specific wiring in `Scripts/`; avoid hardcoded scene paths inside `Systems/` modules.
