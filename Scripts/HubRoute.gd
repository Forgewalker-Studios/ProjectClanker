class_name HubRoute
extends StaticBody2D

const _ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

## Progression state required before this route unlocks.
@export var required_state: _ProgressionStateScript.State = _ProgressionStateScript.State.START_COMPLETED
## Display name for debug labels and route signs.
@export var route_label: String = "Route"

@onready var blocker: CollisionShape2D = $Blocker
@onready var locked_sign: Label = $LockedSign
@onready var route_sign: Label = $RouteSign


func _ready() -> void:
	Progression.state_changed.connect(_on_progression_state_changed)
	route_sign.text = route_label
	_apply_unlock_state(Progression.state)


## Toggle collision and locked visuals from progression.
## @param state: Current progression phase.
func _apply_unlock_state(state: _ProgressionStateScript.State) -> void:
	var unlocked: bool = int(state) >= int(required_state)
	blocker.disabled = unlocked
	locked_sign.visible = not unlocked
	if unlocked:
		route_sign.modulate = Color(0.7, 1.0, 0.7, 1.0)
	else:
		route_sign.modulate = Color(1.0, 0.5, 0.5, 1.0)


## Refresh the route when progression changes.
## @param new_state: Updated progression state.
func _on_progression_state_changed(new_state: _ProgressionStateScript.State) -> void:
	_apply_unlock_state(new_state)
