extends Node

## Tied to EnemyBase.gd when is_boss is checked.

## Stores boss IDs already beaten.
var defeated_bosses: Dictionary = {}


## Tied to Challenge.gd _on_boss_defeated.
## Adds a boss ID to the dictionary.
func mark_boss_defeated(boss_id: StringName) -> void:
	defeated_bosses[boss_id] = true


## In regards to the dictionary above.
## Tied to Challenge.gd _remove_defeated_boss when encounter_completed is met.
## Prevents boss types from respawning.
func is_boss_defeated(boss_id: StringName) -> bool:
	return defeated_bosses.has(boss_id)
