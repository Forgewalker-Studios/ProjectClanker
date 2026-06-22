extends CanvasLayer

## Readable ending overlay when the final progression state is reached.

@onready var _panel: PanelContainer = %EndingPanel
@onready var _body_label: Label = %EndingBodyLabel


func _ready() -> void:
	_panel.visible = false
	Progression.state_changed.connect(_on_progression_state_changed)
	_check_current_state()


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible or not event.is_action_pressed("interact"):
		return
	_panel.visible = false
	get_viewport().set_input_as_handled()


func _check_current_state() -> void:
	const ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")
	if Progression.state == ProgressionStateScript.State.FINAL_COMPLETED:
		_show_ending()


func _on_progression_state_changed(new_state: int) -> void:
	const ProgressionStateScript = preload("res://Autoload/ProgressionState.gd")
	if new_state == ProgressionStateScript.State.FINAL_COMPLETED:
		_show_ending()


func _show_ending() -> void:
	_panel.visible = true
	_body_label.text = (
		"D-0R1 remembers.\n\n"
		+ "The factory falls quiet. Clanker stands in the ash-light "
		+ "while the door hums a gentle, knowing song.\n\n"
		+ "Press [E] to return to the hub."
	)
	AudioDirector.play_ending_sequence()
