extends Control

## Main scene entry point. Displays project info and handles pause input.


@onready var _version_label: Label = %VersionLabel
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_version_label.text = "ProjectClanker v%s" % GameServices.get_version_string()
	_status_label.text = "Press Escape to pause. Run Tests/Scenes/TestRunner.tscn for unit tests."
	GameServices.pause_changed.connect(_on_pause_changed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	GameServices.toggle_pause()
	get_viewport().set_input_as_handled()


func _on_pause_changed(is_paused: bool) -> void:
	if is_paused:
		_status_label.text = "Paused"
	else:
		_status_label.text = "Running — Press Escape to pause."
