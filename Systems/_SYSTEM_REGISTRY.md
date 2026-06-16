# System registry

Short index for **this** repo. Full API, setup, and **which-system-vs-which** notes: **`README.md`** (same folder).

| System | Files | Status | Notes |
|--------|--------|--------|--------|
| Audio jukebox | `AudioJukeboxSystem.gd` | Stable | Random playlist; internal `AudioStreamPlayer` |
| Audio mix UI | `AudioMixControlSystem.gd` | Stable | Glue: sliders + master mute |
| Dialogue data | `DialogueContentSystem.gd` | Stable | JSON / dict; no UI |
| Dialogue presenter | `TimedDialoguePresenterSystem.gd` | Stable | UI fades + optional Yes/No |
| Stat simulation | `StatSimulationSystem.gd` | Stable | Pure numeric stat math |
| Offline stat save | `OfflineSaveSystem.gd` | Stable | JSON + optional offline drain; not generic RPG save |
| Phase tick | `PhaseTickSystem.gd` | Stable | Ordered phase callbacks |
| Inventory state | `InventoryStateSystem.gd` | Stable | Pure inventory state helper; no UI/save/events |
| Catalog lookup | `CatalogLookupSystem.gd` | Stable | ID-keyed catalog register/query helper |
| Weighted selection | `WeightedSelectionSystem.gd` | Stable | Deterministic weighted picks + filtering |
| Settings persistence | `SettingsPersistenceSystem.gd` | Stable | Defaults/current settings dictionary state |
| JSON file store | `JsonFileStoreSystem.gd` | Stable | Generic JSON read/write/delete + backup/restore |
| Threshold state | `ThresholdStateSystem.gd` | Stable | Numeric threshold band/crossing tracking |
| Interaction target | `InteractionTargetSystem.gd` | Stable | Focus/nearby resolution + generic dispatch |
| Item placement puzzle | `ItemPlacementPuzzleSystem.gd` | Stable | Required-item puzzle rule state only |
| Timed message queue | `TimedMessageQueueSystem.gd` | Stable | Queue/timing state; no UI |
| Scene fade transition | `SceneFadeTransitionSystem.gd` | Stable | Transition phase sequencing state |
| Environment phase presenter | `EnvironmentPhasePresenterSystem.gd` | Stable | Progress-based float/color interpolation |
| Random cue scheduler | `RandomCueSchedulerSystem.gd` | Stable | Random cue selection + delay scheduling |

## Candidate systems to extract later

*(Game-specific scripts that might become reusable — fill during jam postmortems.)*

## New systems

Validate integrated behavior in the **next game or jam** that uses the module; update **`README.md`** when APIs change.

## Phase 3B detailed entries

- System name: `CatalogLookupSystem`
  - File: `Systems/CatalogLookupSystem.gd`
  - Category: Data lookup helper
  - Purpose: ID-based catalog registration and query.
  - Reusable scope: Catalog data only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_catalog_lookup_system.gd`
  - Notes: Supports category/tag filtering and import/export.

- System name: `WeightedSelectionSystem`
  - File: `Systems/WeightedSelectionSystem.gd`
  - Category: Selection utility
  - Purpose: Weighted deterministic selection with optional filtering/repeat control.
  - Reusable scope: Generic weighted pick logic.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_weighted_selection_system.gd`
  - Notes: Accepts seeded RNG for deterministic tests.

- System name: `SettingsPersistenceSystem`
  - File: `Systems/SettingsPersistenceSystem.gd`
  - Category: Persistence/state helper
  - Purpose: Settings defaults/current state get/set/reset/import/export.
  - Reusable scope: Settings dictionary management only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_settings_persistence_system.gd`
  - Notes: Does not directly apply engine settings.

- System name: `JsonFileStoreSystem`
  - File: `Systems/JsonFileStoreSystem.gd`
  - Category: File utility
  - Purpose: Generic JSON read/write/delete and backup/restore.
  - Reusable scope: File operations only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_json_file_store_system.gd`
  - Notes: Schema ownership intentionally external.

- System name: `ThresholdStateSystem`
  - File: `Systems/ThresholdStateSystem.gd`
  - Category: Numeric state helper
  - Purpose: Threshold crossing and band tracking.
  - Reusable scope: Numeric threshold logic only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_threshold_state_system.gd`
  - Notes: Returns event dictionaries; caller handles consequences.

- System name: `InteractionTargetSystem`
  - File: `Systems/InteractionTargetSystem.gd`
  - Category: Interaction helper
  - Purpose: Focus/nearby target resolution and generic prompt/dispatch.
  - Reusable scope: Target resolution only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_interaction_target_system.gd`
  - Notes: No Project Harvest item/puzzle/backpack semantics.

- System name: `ItemPlacementPuzzleSystem`
  - File: `Systems/ItemPlacementPuzzleSystem.gd`
  - Category: Puzzle rule helper
  - Purpose: Required-item placement validation and completion state.
  - Reusable scope: Puzzle rule state only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_item_placement_puzzle_system.gd`
  - Notes: Supports optional target-specific requirements.

- System name: `TimedMessageQueueSystem`
  - File: `Systems/TimedMessageQueueSystem.gd`
  - Category: Queue/state helper
  - Purpose: Timed message sequencing state with skip/advance.
  - Reusable scope: Message queue data only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_timed_message_queue_system.gd`
  - Notes: Complements presenter systems without owning UI.

- System name: `SceneFadeTransitionSystem`
  - File: `Systems/SceneFadeTransitionSystem.gd`
  - Category: Transition helper
  - Purpose: Transition phase ordering for fade and scene-change requests.
  - Reusable scope: Transition state machine only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_scene_fade_transition_system.gd`
  - Notes: Keeps target scene as opaque value.

- System name: `EnvironmentPhasePresenterSystem`
  - File: `Systems/EnvironmentPhasePresenterSystem.gd`
  - Category: Presentation interpolation helper
  - Purpose: Float/color interpolation for environment phases.
  - Reusable scope: Presentation value interpolation only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_environment_phase_presenter_system.gd`
  - Notes: Supports normalized progress clamp.

- System name: `RandomCueSchedulerSystem`
  - File: `Systems/RandomCueSchedulerSystem.gd`
  - Category: Scheduling helper
  - Purpose: Random cue selection and next-delay generation.
  - Reusable scope: Cue scheduling logic only.
  - Project Harvest wiring status: Created and tested. Not wired into Project Harvest production code.
  - Test file: `tests/system/test_random_cue_scheduler_system.gd`
  - Notes: Designed for generic ambience/cue workflows.
