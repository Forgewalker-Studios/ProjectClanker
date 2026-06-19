extends CanvasLayer

const _ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")

@onready var state_label: Label = $Panel/VBox/StateLabel
@onready var hint_label: Label = $Panel/VBox/HintLabel


func _ready() -> void:
	Progression.state_changed.connect(_on_progression_state_changed)
	_update_labels(Progression.state)


## Advance progression for hub testing with bracket keys.
## @param event: Input event from the viewport.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("debug_advance_state"):
		return
	Progression.advance_state()
	get_viewport().set_input_as_handled()


## Refresh debug labels when progression changes.
## @param new_state: Updated progression state.
func _on_progression_state_changed(new_state: _ProgressionStateScript.State) -> void:
	_update_labels(new_state)


## Update on-screen progression debug text.
## @param state: Current progression phase.
func _update_labels(state: _ProgressionStateScript.State) -> void:
	state_label.text = "Progression: %s" % _ProgressionStateScript.State.keys()[state]
	hint_label.text = "[ ] Advance state (debug) | E Talk | WASD Move"
