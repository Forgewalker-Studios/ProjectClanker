class_name ScenePortal
extends Area2D

## Changes scenes when the player enters and optionally advances progression.

const ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

@export_file("*.tscn") var target_scene: String
@export var target_spawn_name: StringName = &"MainSpawn"
@export_range(-1, 9, 1) var progression_state_on_enter: int = -1


var _transition_requested: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if target_scene.is_empty() or not ResourceLoader.exists(target_scene):
		push_error("ScenePortal: target scene is invalid on %s: %s" % [name, target_scene])


func _on_body_entered(body: Node2D) -> void:
	if _transition_requested or not body.is_in_group("player"):
		return
	if target_scene.is_empty() or not ResourceLoader.exists(target_scene):
		return

	_transition_requested = true
	if progression_state_on_enter >= 0 and int(Progression.state) < progression_state_on_enter:
		Progression.set_state(progression_state_on_enter as ProgressionStateScript.State)

	SceneSpawn.next_spawn_name = target_spawn_name

	if not SceneTransition.request_scene_change(target_scene):
		SceneSpawn.next_spawn_name = SceneSpawn.DEFAULT_SPAWN_NAME
		_transition_requested = false
