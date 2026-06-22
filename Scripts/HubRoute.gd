class_name HubRoute
extends ScenePortal

const _ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

## Progression state required before this route unlocks.
@export var required_state: _ProgressionStateScript.State = _ProgressionStateScript.State.START_COMPLETED
## Display name for debug labels and route signs.
@export var route_label: String = "Route"

@onready var locked_sign: Label = $LockedSign
@onready var route_sign: Label = $RouteSign


func _ready() -> void:
	super._ready()
	Progression.state_changed.connect(_on_progression_state_changed)
	_style_route_label(route_sign)
	_style_route_label(locked_sign)
	route_sign.text = route_label
	_apply_unlock_state(Progression.state)


func _style_route_label(label: Label) -> void:
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 1.0))
	label.add_theme_font_size_override("font_size", 18)


## Toggle collision and locked visuals from progression.
## @param state: Current progression phase.
func _apply_unlock_state(state: _ProgressionStateScript.State) -> void:
	var unlocked: bool = int(state) >= int(required_state)
	set_deferred("monitoring", unlocked)
	locked_sign.visible = not unlocked
	if unlocked:
		route_sign.modulate = Color(0.7, 1.0, 0.7, 1.0)
	else:
		route_sign.modulate = Color(1.0, 0.5, 0.5, 1.0)


## Refresh the route when progression changes.
## @param new_state: Updated progression state.
func _on_progression_state_changed(new_state: _ProgressionStateScript.State) -> void:
	_apply_unlock_state(new_state)
