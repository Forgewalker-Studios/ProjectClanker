extends Node

## Global cross-cutting services: version info, pause state, and shared game flags.
##
## Registered as an autoload singleton in project.godot.

signal pause_changed(is_paused: bool)

var is_paused: bool = false


## Returns the application version string from project settings.
func get_version_string() -> String:
	return ProjectSettings.get_setting("application/config/version", "0.0.0.0")


## Sets global pause state and emits pause_changed when the value changes.
func set_paused(paused: bool) -> void:
	if is_paused == paused:
		return
	is_paused = paused
	get_tree().paused = paused
	pause_changed.emit(paused)


## Toggles global pause state.
func toggle_pause() -> void:
	set_paused(not is_paused)
