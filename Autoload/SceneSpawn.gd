extends Node

## The fallback spawn point.
const DEFAULT_SPAWN_NAME: StringName = &"MainSpawn"

## The spawn point used the next time a scene loads.
var next_spawn_name: StringName = DEFAULT_SPAWN_NAME


## Saves the spawn name, then resets future spawns back to default.
func consume_spawn_name() -> StringName:
	var spawn_name: StringName = next_spawn_name
	next_spawn_name = DEFAULT_SPAWN_NAME
	return spawn_name
